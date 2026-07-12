import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _smartPosDisplayChannel = MethodChannel('pos_dual_screen');

Future<String?> showSmartPosUpiQr({
  required String qr,
  String? orderNumber,
  double? amount,
  String? payeeName,
  String? upiId,
  int? timeoutSeconds,
}) async {
  if (!Platform.isAndroid) {
    debugPrint('[UPI_QR][DISPLAY] skip: platform is not Android');
    return null;
  }
  debugPrint(
    '[UPI_QR][DISPLAY] invoke showUpiQr '
    'qrLen=${qr.length} upi=${qr.startsWith('upi://')} '
    'order=$orderNumber amount=$amount timeout=$timeoutSeconds',
  );
  final result = await _smartPosDisplayChannel
      .invokeMethod<String>('showUpiQr', <String, Object?>{
        'qrData': qr,
        'orderNumber': orderNumber,
        'amount': amount,
        'payeeName': payeeName,
        'upiId': upiId,
        'timeoutSeconds': timeoutSeconds,
      });
  debugPrint('[UPI_QR][DISPLAY] showUpiQr result=$result');
  return result;
}

Future<void> clearSmartPosCustomerDisplay() async {
  if (!Platform.isAndroid) {
    debugPrint('[UPI_QR][DISPLAY] clear skipped: platform is not Android');
    return;
  }
  debugPrint('[UPI_QR][DISPLAY] clearSubDisplay invoke');
  await _smartPosDisplayChannel.invokeMethod<void>('clearSubDisplay');
  debugPrint('[UPI_QR][DISPLAY] clearSubDisplay done');
}
