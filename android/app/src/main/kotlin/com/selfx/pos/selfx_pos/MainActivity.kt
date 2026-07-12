package com.selfx.pos.selfx_pos

import android.app.Presentation
import android.graphics.Bitmap
import android.graphics.Color
import android.hardware.display.DisplayManager
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Bundle
import android.util.Log
import android.view.Display
import android.view.Gravity
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.MultiFormatWriter
import com.zcs.sdk.DriverManager
import com.zcs.sdk.SdkResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val logTag = "SELFX_UPI_QR"
    private val smartPosChannelName = "selfx_pos/smartpos_printer"
    private val dualScreenChannelName = "pos_dual_screen"
    private val deviceSoundChannelName = "selfx_pos/device_sound"
    private val driverManager: DriverManager by lazy { DriverManager.getInstance() }
    private var sdkReady = false
    private var customerPresentation: Presentation? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smartPosChannelName)
            .setMethodCallHandler(::handleSmartPosCall)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, dualScreenChannelName)
            .setMethodCallHandler(::handleSmartPosCall)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceSoundChannelName)
            .setMethodCallHandler(::handleDeviceSoundCall)
        Thread {
            val ready = warmUpSmartPos()
            Log.d(logTag, "startup warmUpSmartPos ready=$ready")
        }.start()
    }

    override fun onDestroy() {
        customerPresentation?.dismiss()
        customerPresentation = null
        super.onDestroy()
    }

    @Synchronized
    private fun ensureSdkReady(): Int {
        if (sdkReady) {
            return SdkResult.SDK_OK
        }
        val sys = driverManager.getBaseSysDevice()
        var status = sys.sdkInit()
        Log.d(logTag, "sdkInit status=$status")
        if (status != SdkResult.SDK_OK) {
            sys.sysPowerOn()
            Thread.sleep(1000)
            status = sys.sdkInit()
            Log.d(logTag, "sdkInit after sysPowerOn status=$status")
        }
        if (status == SdkResult.SDK_OK) {
            sys.showDetailLog(true)
            sdkReady = true
        }
        return status
    }

    private fun printEscPos(bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val initStatus = ensureSdkReady()
            if (initStatus != SdkResult.SDK_OK) {
                finishWithError(
                    result,
                    "SMARTPOS_INIT_FAILED",
                    "SmartPOS SDK initialization failed: $initStatus",
                )
                return
            }

            val printer = driverManager.getPrinter()
            val printerStatus = printer.getPrinterStatus()
            if (printerStatus == SdkResult.SDK_PRN_STATUS_PAPEROUT) {
                finishWithError(result, "SMARTPOS_PAPER_OUT", "Printer is out of paper.")
                return
            }
            if (printerStatus == SdkResult.SDK_PRN_STATUS_TOOHEAT) {
                finishWithError(result, "SMARTPOS_OVERHEATED", "Printer is overheated.")
                return
            }
            if (printerStatus == SdkResult.SDK_PRN_STATUS_FAULT) {
                finishWithError(result, "SMARTPOS_PRINTER_FAULT", "Printer is in a fault state.")
                return
            }

            val printStatus = printer.printEpson(bytes)
            if (printStatus != SdkResult.SDK_OK) {
                finishWithError(
                    result,
                    "SMARTPOS_PRINT_FAILED",
                    "SmartPOS print failed: $printStatus",
                )
                return
            }

            runOnUiThread { result.success(bytes.size) }
        } catch (error: Throwable) {
            finishWithError(
                result,
                "SMARTPOS_EXCEPTION",
                error.message ?: error.javaClass.simpleName,
            )
        }
    }

    private fun warmUpSmartPos(): Boolean {
        return try {
            val initStatus = ensureSdkReady()
            if (initStatus != SdkResult.SDK_OK) {
                Log.e(logTag, "warmUpSmartPos init failed status=$initStatus")
                return false
            }
            driverManager.getPrinter()
            Log.d(logTag, "warmUpSmartPos ready")
            true
        } catch (_: Throwable) {
            Log.e(logTag, "warmUpSmartPos exception")
            false
        }
    }

    private fun handleSmartPosCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "warmUpPrinter", "warmUpSmartPos" -> {
                Thread {
                    val ready = warmUpSmartPos()
                    Log.d(logTag, "warmUp method=${call.method} ready=$ready")
                    runOnUiThread { result.success(ready) }
                }.start()
            }
            "printEscPos" -> {
                val bytes = call.arguments as? ByteArray
                if (bytes == null || bytes.isEmpty()) {
                    result.error(
                        "SMARTPOS_EMPTY_DATA",
                        "Receipt did not contain printable data.",
                        null,
                    )
                    return
                }
                Thread {
                    printEscPos(bytes, result)
                }.start()
            }
            "showUpiQrOnCustomerDisplay", "showUpiQr" -> {
                val arguments = call.arguments as? Map<*, *>
                val qr = (
                    arguments?.get("qr")
                        ?: arguments?.get("qrData")
                        ?: arguments?.get("upiQrData")
                )?.toString()?.trim()
                if (qr.isNullOrEmpty()) {
                    Log.e(logTag, "showUpiQr empty payload")
                    result.error(
                        "SMARTPOS_EMPTY_QR",
                        "UPI QR payload was empty.",
                        null,
                    )
                    return
                }
                Log.d(
                    logTag,
                    "showUpiQr received qrLen=${qr.length} upi=${qr.startsWith("upi://")}",
                )
                showUpiQrOnCustomerDisplay(arguments ?: emptyMap<Any, Any>(), qr, result)
            }
            "clearCustomerDisplay", "clearSubDisplay" -> {
                Log.d(logTag, "clear display method=${call.method}")
                clearCustomerDisplay(result)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleDeviceSoundCall(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "playClick", "playClickSound" -> {
                Thread {
                    val played = playNativeClickSound()
                    runOnUiThread { result.success(played) }
                }.start()
            }
            else -> result.notImplemented()
        }
    }

    private fun playNativeClickSound(): Boolean {
        return try {
            val initStatus = ensureSdkReady()
            if (initStatus == SdkResult.SDK_OK) {
                val beepStatus = driverManager.getBeeper().beep(4000, 60)
                if (beepStatus == SdkResult.SDK_OK) {
                    return true
                }
            }
            val tone = ToneGenerator(AudioManager.STREAM_MUSIC, 80)
            try {
                tone.startTone(ToneGenerator.TONE_PROP_BEEP, 60)
                Thread.sleep(70)
            } finally {
                tone.release()
            }
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun showUpiQrOnCustomerDisplay(
        arguments: Map<*, *>,
        qr: String,
        result: MethodChannel.Result,
    ) {
        try {
            val orderNumber = arguments["orderNumber"]?.toString()?.trim()
            val payeeName = arguments["payeeName"]?.toString()?.trim()
            val upiId = arguments["upiId"]?.toString()?.trim()
            val amount = when (val value = arguments["amount"]) {
                is Number -> value.toDouble()
                else -> value?.toString()?.toDoubleOrNull()
            }
            val timeoutSeconds = when (val value = arguments["timeoutSeconds"]) {
                is Number -> value.toInt()
                else -> value?.toString()?.toIntOrNull()
            }
            Log.d(
                logTag,
                "show customer display order=$orderNumber amount=$amount upiId=$upiId timeout=$timeoutSeconds",
            )

            Thread {
                try {
                    val lcdResult = tryShowOnLcd(qr)
                    Log.d(logTag, "tryShowOnLcd result=$lcdResult")
                    if (lcdResult == SdkResult.SDK_OK) {
                        runOnUiThread { result.success("lcd") }
                        return@Thread
                    }

                    val qrBitmap = createQrBitmap(qr, 520)
                    runOnUiThread {
                        if (
                            showOnSecondaryDisplay(
                                qrBitmap = qrBitmap,
                                orderNumber = orderNumber,
                                amount = amount,
                                payeeName = payeeName,
                                upiId = upiId,
                                timeoutSeconds = timeoutSeconds,
                            )
                        ) {
                            Log.d(logTag, "secondary presentation shown")
                            result.success("secondary_display")
                            return@runOnUiThread
                        }

                        Log.e(logTag, "LCD and secondary display failed lcdResult=$lcdResult")
                        result.error(
                            "SMARTPOS_LCD_FAILED",
                            "SmartPOS LCD display failed: $lcdResult",
                            null,
                        )
                    }
                } catch (error: Throwable) {
                    Log.e(logTag, "showUpiQr exception", error)
                    finishWithError(
                        result,
                        "SMARTPOS_LCD_EXCEPTION",
                        error.message ?: error.javaClass.simpleName,
                    )
                }
            }.start()
        } catch (error: Throwable) {
            finishWithError(
                result,
                "SMARTPOS_QR_FAILED",
                error.message ?: error.javaClass.simpleName,
            )
        }
    }

    private fun clearCustomerDisplay(result: MethodChannel.Result) {
        runOnUiThread {
            customerPresentation?.dismiss()
            customerPresentation = null
            Thread {
                try {
                    val initStatus = ensureSdkReady()
                    if (initStatus == SdkResult.SDK_OK) {
                        driverManager.getBaseSysDevice().showLcdMainScreen()
                    }
                } catch (_: Throwable) {
                    // Clearing the fallback LCD should not block POS checkout.
                }
                runOnUiThread { result.success(null) }
            }.start()
        }
    }

    private fun showOnSecondaryDisplay(
        qrBitmap: Bitmap,
        orderNumber: String?,
        amount: Double?,
        payeeName: String?,
        upiId: String?,
        timeoutSeconds: Int?,
    ): Boolean {
        val display = findCustomerDisplay() ?: return false
        Log.d(logTag, "secondary display id=${display.displayId} name=${display.name}")
        return try {
            customerPresentation?.dismiss()
            customerPresentation = UpiQrPresentation(
                display,
                qrBitmap,
                orderNumber,
                amount,
                payeeName,
                upiId,
                timeoutSeconds,
            )
            customerPresentation?.show()
            true
        } catch (_: Throwable) {
            Log.e(logTag, "secondary presentation failed")
            customerPresentation = null
            false
        }
    }

    private fun findCustomerDisplay(): Display? {
        val displayManager = getSystemService(DISPLAY_SERVICE) as DisplayManager
        val presentationDisplays =
            displayManager.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)
        if (presentationDisplays.isNotEmpty()) {
            return presentationDisplays[0]
        }
        val defaultDisplayId = windowManager.defaultDisplay.displayId
        return displayManager.getDisplays().firstOrNull { display ->
            display.displayId != defaultDisplayId
        }
    }

    private fun tryShowOnLcd(qr: String): Int {
        val initStatus = ensureSdkReady()
        if (initStatus != SdkResult.SDK_OK) {
            Log.e(logTag, "LCD init failed status=$initStatus")
            return initStatus
        }
        val bitmap = createLcdQrBitmap(qr)
        val status = driverManager.getBaseSysDevice().showBitmapOnLcd(bitmap, true)
        Log.d(logTag, "showBitmapOnLcd status=$status")
        if (status != SdkResult.SDK_OK) {
            val textStatus = driverManager.getBaseSysDevice().showStringOnLcd(
                0,
                0,
                "Scan UPI QR\non main screen",
                true,
            )
            Log.d(logTag, "showStringOnLcd fallback status=$textStatus")
        }
        return status
    }

    private fun createQrBitmap(text: String, size: Int): Bitmap {
        val hints = mapOf(EncodeHintType.MARGIN to 1)
        val matrix = MultiFormatWriter().encode(
            text,
            BarcodeFormat.QR_CODE,
            size,
            size,
            hints,
        )
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        for (x in 0 until size) {
            for (y in 0 until size) {
                bitmap.setPixel(x, y, if (matrix[x, y]) Color.BLACK else Color.WHITE)
            }
        }
        return bitmap
    }

    private fun createLcdQrBitmap(text: String): Bitmap {
        val lcdWidth = 128
        val lcdHeight = 56
        val qrSize = 56
        val qrBitmap = createQrBitmap(text, qrSize)
        val bitmap = Bitmap.createBitmap(lcdWidth, lcdHeight, Bitmap.Config.ARGB_8888)
        bitmap.eraseColor(Color.WHITE)
        val offsetX = (lcdWidth - qrSize) / 2
        for (x in 0 until qrSize) {
            for (y in 0 until qrSize) {
                bitmap.setPixel(offsetX + x, y, qrBitmap.getPixel(x, y))
            }
        }
        return bitmap
    }

    private fun finishWithError(
        result: MethodChannel.Result,
        code: String,
        message: String,
    ) {
        runOnUiThread { result.error(code, message, null) }
    }

    private inner class UpiQrPresentation(
        display: Display,
        private val qrBitmap: Bitmap,
        private val orderNumber: String?,
        private val amount: Double?,
        private val payeeName: String?,
        private val upiId: String?,
        private val timeoutSeconds: Int?,
    ) : Presentation(this@MainActivity, display) {
        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            val density = resources.displayMetrics.density
            val root = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(Color.WHITE)
                setPadding(
                    (40 * density).toInt(),
                    (28 * density).toInt(),
                    (40 * density).toInt(),
                    (28 * density).toInt(),
                )
            }

            root.addView(textView("Scan to Pay", 34f, true, Color.rgb(15, 23, 42)))
            orderNumber?.takeIf { it.isNotEmpty() }?.let {
                root.addView(textView("Order $it", 18f, false, Color.rgb(71, 85, 105)))
            }
            amount?.let {
                root.addView(
                    textView(
                        "Rs ${String.format("%.2f", it)}",
                        42f,
                        true,
                        Color.rgb(2, 44, 34),
                    ),
                )
            }

            val imageSize = (360 * density).toInt().coerceAtMost(520)
            val image = ImageView(context).apply {
                setImageBitmap(qrBitmap)
                scaleType = ImageView.ScaleType.FIT_CENTER
                adjustViewBounds = true
                setBackgroundColor(Color.WHITE)
            }
            root.addView(
                image,
                LinearLayout.LayoutParams(imageSize, imageSize).apply {
                    topMargin = (20 * density).toInt()
                    bottomMargin = (18 * density).toInt()
                    gravity = Gravity.CENTER_HORIZONTAL
                },
            )

            payeeName?.takeIf { it.isNotEmpty() }?.let {
                root.addView(textView(it, 20f, true, Color.rgb(15, 23, 42)))
            }
            upiId?.takeIf { it.isNotEmpty() }?.let {
                root.addView(textView(it, 16f, false, Color.rgb(71, 85, 105)))
            }
            timeoutSeconds?.takeIf { it > 0 }?.let {
                root.addView(textView("Valid for ${it}s", 15f, false, Color.rgb(100, 116, 139)))
            }

            setContentView(
                root,
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
        }

        private fun textView(
            text: String,
            sizeSp: Float,
            bold: Boolean,
            color: Int,
        ): TextView {
            return TextView(context).apply {
                this.text = text
                textSize = sizeSp
                setTextColor(color)
                gravity = Gravity.CENTER
                if (bold) {
                    typeface = android.graphics.Typeface.DEFAULT_BOLD
                }
                includeFontPadding = true
            }
        }
    }
}
