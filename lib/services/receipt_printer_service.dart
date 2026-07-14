import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image;

import '../models/order_models.dart';

final receiptPrinterServiceProvider = Provider<ReceiptPrinterService>((ref) {
  return ReceiptPrinterService();
});

class ReceiptPrinterService {
  static const _receiptReminder = 'THANK YOU FOR YOUR ORDER!';
  static const _poweredBy = 'Powered By';
  static const _footerBrand = 'SELFX POS';
  static Future<CapabilityProfile>? _profileFuture;
  static final Dio _assetDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  static final Map<String, Future<image.Image?>> _logoImageCache =
      <String, Future<image.Image?>>{};

  Future<List<int>> buildEscPos(
    ReceiptPrintObject receipt, {
    String? currencyCode,
    String? paperWidth,
  }) async {
    final profile = await _profile();
    final selectedPaper = paperWidth ?? receipt.paper;
    final paperSize = _paperSize(selectedPaper);
    final lineChars = _paperLineChars(selectedPaper, paperSize);
    final generator = Generator(paperSize, profile);
    final bytes = <int>[];

    if (receipt.commands.isEmpty) {
      bytes.addAll(
        _fallbackReceipt(
          generator,
          receipt,
          lineChars,
          currencyCode: currencyCode,
        ),
      );
      return bytes;
    }

    final commands = _productionReceiptCommands(receipt.commands);

    var hasInit = false;
    var hasCut = false;
    for (final command in commands) {
      final type = _commandType(command);
      hasInit = hasInit || type == 'init';
      hasCut = hasCut || type == 'cut';
    }

    if (!hasInit) {
      bytes.addAll(generator.reset());
    }
    await _precacheLogoCommands(commands);
    for (final command in commands) {
      bytes.addAll(
        await _renderCommand(
          generator,
          command,
          lineChars,
          currencyCode: currencyCode,
        ),
      );
    }
    if (!hasCut) {
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());
    }

    return bytes;
  }

  Future<void> _precacheLogoCommands(
    List<Map<String, dynamic>> commands,
  ) async {
    final urls = <String>{};
    for (final command in commands) {
      final type = _commandType(command);
      if (type != 'logo' && type != 'image') {
        continue;
      }
      final url = _stringValue(command['url'] ?? command['src']);
      if (_isHttpUrl(url)) {
        urls.add(url);
      }
    }
    if (urls.isEmpty) {
      return;
    }
    await Future.wait(
      urls.map((url) async {
        try {
          await _loadLogoImage(url);
        } catch (_) {
          // Logo failures should not delay or fail the receipt.
        }
      }),
    );
  }

  static Future<CapabilityProfile> _profile() {
    final existing = _profileFuture;
    if (existing != null) {
      return existing;
    }
    final future = CapabilityProfile.load();
    _profileFuture = future;
    return future.catchError((Object error, StackTrace stackTrace) {
      if (identical(_profileFuture, future)) {
        _profileFuture = null;
      }
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  List<int> _fallbackReceipt(
    Generator generator,
    ReceiptPrintObject receipt,
    int lineChars, {
    String? currencyCode,
  }) {
    final bytes = <int>[];
    final order = receipt.order;
    bytes.addAll(generator.reset());
    bytes.addAll(
      _renderTextLines(
        generator,
        [
          _firstText(receipt.raw, const [
            'restaurant_name',
            'restaurant.name',
            'branch.restaurant_name',
          ], fallback: 'SELFX POS'),
        ],
        lineChars: lineChars,
        styles: const PosStyles(align: PosAlign.center, bold: true),
        currencyCode: currencyCode,
      ),
    );
    final number = _firstText(order, const [
      'order_number',
      'order_no',
      'invoice_number',
      'number',
      'token',
      'id',
    ]);
    if (number.isNotEmpty) {
      bytes.addAll(
        _renderTextLines(
          generator,
          ['Receipt $number'],
          lineChars: lineChars,
          styles: const PosStyles(align: PosAlign.center),
          currencyCode: currencyCode,
        ),
      );
    }
    bytes.addAll(generator.hr());

    final items = _asMapList(
      order['items'] ??
          order['order_items'] ??
          order['lines'] ??
          receipt.raw['items'] ??
          receipt.raw['order_items'],
    );
    for (final item in items) {
      final quantity = _stringValue(
        item['quantity'] ?? item['qty'],
        fallback: '1',
      );
      final name = _itemName(item);
      final amount = _amountText(
        item['total'] ??
            item['line_total'] ??
            item['amount'] ??
            item['price'] ??
            item['unit_price'],
        currencyCode: currencyCode,
      );
      bytes.addAll(
        _renderTextLines(
          generator,
          _twoColumnLines(
            '$quantity x $name',
            amount,
            lineChars,
            currencyCode: currencyCode,
          ),
          currencyCode: currencyCode,
        ),
      );
    }

    if (items.isNotEmpty) {
      bytes.addAll(generator.hr());
    }
    final subtotal = _amountText(
      order['subtotal'] ?? order['sub_total'] ?? receipt.raw['subtotal'],
      currencyCode: currencyCode,
    );
    if (subtotal.isNotEmpty) {
      bytes.addAll(
        _renderTextLines(
          generator,
          _twoColumnLines(
            'Subtotal',
            subtotal,
            lineChars,
            currencyCode: currencyCode,
          ),
          currencyCode: currencyCode,
        ),
      );
    }
    final total = _amountText(
      order['total'] ??
          order['grand_total'] ??
          order['payable_amount'] ??
          receipt.raw['total'],
      currencyCode: currencyCode,
    );
    if (total.isNotEmpty) {
      bytes.addAll(
        _renderTextLines(
          generator,
          _twoColumnLines(
            'Total',
            total,
            lineChars,
            currencyCode: currencyCode,
          ),
          styles: const PosStyles(bold: true),
          currencyCode: currencyCode,
        ),
      );
    }
    bytes.addAll(generator.feed(2));
    bytes.addAll(
      _renderReceiptFooter(generator, lineChars, currencyCode: currencyCode),
    );
    bytes.addAll(generator.cut());
    return bytes;
  }

  List<int> _renderReceiptFooter(
    Generator generator,
    int lineChars, {
    String? currencyCode,
  }) {
    final bytes = <int>[];
    bytes.addAll(
      _renderTextLines(
        generator,
        _wrappedPrinterLines(
          _receiptReminder,
          lineChars,
          currencyCode: currencyCode,
        ),
        lineChars: lineChars,
        styles: const PosStyles(align: PosAlign.center),
        currencyCode: currencyCode,
      ),
    );
    bytes.addAll(
      _renderTextLines(
        generator,
        const [_poweredBy],
        lineChars: lineChars,
        styles: const PosStyles(align: PosAlign.center, bold: true),
        currencyCode: currencyCode,
      ),
    );
    bytes.addAll(
      _renderTextLines(
        generator,
        const [_footerBrand],
        lineChars: lineChars,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
        currencyCode: currencyCode,
      ),
    );
    return bytes;
  }

  List<Map<String, dynamic>> _productionReceiptCommands(
    List<Map<String, dynamic>> commands,
  ) {
    final normalized = <Map<String, dynamic>>[];
    final hasServerFooter = _hasServerReceiptFooter(commands);
    var footerInjected = false;
    var skipNextRestaurantTitle = false;
    for (final original in commands) {
      final command = Map<String, dynamic>.from(original);
      final type = _commandType(command);
      if (skipNextRestaurantTitle && _isRestaurantTitleCommand(command)) {
        skipNextRestaurantTitle = false;
        continue;
      }
      if (skipNextRestaurantTitle && type != 'feed' && type != 'blank') {
        skipNextRestaurantTitle = false;
      }
      if (_isRestaurantLogoCommand(command)) {
        normalized.add(command);
        skipNextRestaurantTitle = true;
        continue;
      }
      if (!hasServerFooter && _isFooterCommand(command)) {
        continue;
      }
      if (type == 'cut') {
        if (!hasServerFooter && !footerInjected) {
          normalized.add(_footerCommand());
          footerInjected = true;
        }
        normalized.add(command);
        continue;
      }
      normalized.add(command);
    }
    if (!hasServerFooter && !footerInjected) {
      normalized.add(_footerCommand());
    }
    return normalized;
  }

  bool _hasServerReceiptFooter(List<Map<String, dynamic>> commands) {
    return commands.any((command) {
      if (_isFooterCommand(command)) {
        return true;
      }
      final type = _commandType(command);
      if (type != 'logo' && type != 'image') {
        return false;
      }
      final url = _stringValue(command['url'] ?? command['src']).toLowerCase();
      return _isFooterLogoUrl(url);
    });
  }

  Map<String, dynamic> _footerCommand() {
    return const <String, dynamic>{'type': '_selfx_footer'};
  }

  bool _isRestaurantLogoCommand(Map<String, dynamic> command) {
    final type = _commandType(command);
    if (type != 'logo' && type != 'image') {
      return false;
    }
    final url = _stringValue(command['url'] ?? command['src']).toLowerCase();
    if (url.isEmpty) {
      return false;
    }
    return !_isFooterLogoUrl(url);
  }

  bool _isFooterLogoUrl(String url) {
    return url.contains('admin-branding') ||
        url.contains('receipt-logo') ||
        url.contains('powered');
  }

  bool _isRestaurantTitleCommand(Map<String, dynamic> command) {
    final type = _commandType(command);
    if (type != 'text' && type != 'line') {
      return false;
    }
    final style = _stringValue(command['style']).toLowerCase();
    return style.contains('title');
  }

  bool _isFooterCommand(Map<String, dynamic> command) {
    final type = _commandType(command);
    if (type != 'text' && type != 'line') {
      return false;
    }
    final text = _stringValue(
      command['text'] ?? command['value'] ?? command['content'],
    );
    return _isThankYouFooter(text) || _isProductionFooter(text);
  }

  bool _isThankYouFooter(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return normalized.contains('thankyouforyourorder') ||
        normalized.contains('thanksforyourorder');
  }

  bool _isProductionFooter(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return normalized == 'checkyourbelongingsbeforeyouleave' ||
        normalized == 'thankyouforyourorder' ||
        normalized == 'poweredby' ||
        normalized == 'selfxpos';
  }

  Future<List<int>> _renderCommand(
    Generator generator,
    Map<String, dynamic> command,
    int lineChars, {
    String? currencyCode,
  }) {
    final type = _commandType(command);
    switch (type) {
      case '_selfx_footer':
        return Future.value(
          _renderReceiptFooter(
            generator,
            lineChars,
            currencyCode: currencyCode,
          ),
        );
      case 'init':
        return Future.value(generator.reset());
      case 'divider':
      case 'separator':
        return Future.value(generator.hr(ch: _dividerChar(command)));
      case 'line':
        final text = _stringValue(
          command['text'] ?? command['value'] ?? command['content'],
        );
        if (text.isEmpty) {
          return Future.value(generator.hr(ch: _dividerChar(command)));
        }
        final styles = _styles(command);
        return Future.value(
          _renderTextLines(
            generator,
            _wrappedPrinterLines(
              text,
              _styledLineChars(lineChars, styles),
              currencyCode: currencyCode,
            ),
            lineChars: lineChars,
            styles: styles,
            currencyCode: currencyCode,
          ),
        );
      case 'row':
        return Future.value(
          _renderRow(generator, command, lineChars, currencyCode: currencyCode),
        );
      case 'qr':
      case 'qrcode':
        final data = _stringValue(
          command['data'] ?? command['text'] ?? command['value'],
        );
        return Future.value(
          data.isEmpty
              ? const <int>[]
              : generator.qrcode(
                  data,
                  align: PosAlign.center,
                  size: _qrSize(command['size'] ?? command['qr_size']),
                  cor: _qrCorrection(
                    command['correction'] ?? command['error_correction'],
                  ),
                ),
        );
      case 'barcode':
        final data = _stringValue(
          command['data'] ?? command['text'] ?? command['value'],
        );
        if (data.isEmpty) {
          return Future.value(const <int>[]);
        }
        return Future.value(
          generator.text(
            _centerAlign(
              _printerText(data, currencyCode: currencyCode),
              lineChars,
            ),
            styles: const PosStyles(align: PosAlign.left),
          ),
        );
      case 'feed':
      case 'space':
      case 'blank':
        return Future.value(
          generator.feed(_intValue(command['lines'] ?? command['n']) ?? 1),
        );
      case 'drawer':
      case 'open_drawer':
        return Future.value(generator.drawer());
      case 'cut':
        return Future.value(generator.cut(mode: _cutMode(command['mode'])));
      case 'logo':
      case 'image':
        return _renderLogoCommand(generator, command, lineChars);
      case 'text':
      default:
        final text = _stringValue(
          command['text'] ?? command['value'] ?? command['content'],
        );
        if (text.isEmpty) {
          return Future.value(const <int>[]);
        }
        final styles = _styles(command);
        return Future.value(
          _renderTextLines(
            generator,
            _wrappedPrinterLines(
              text,
              _styledLineChars(lineChars, styles),
              currencyCode: currencyCode,
            ),
            lineChars: lineChars,
            styles: styles,
            currencyCode: currencyCode,
          ),
        );
    }
  }

  Future<List<int>> _renderLogoCommand(
    Generator generator,
    Map<String, dynamic> command,
    int lineChars,
  ) async {
    final url = _stringValue(command['url'] ?? command['src']);
    if (url.isEmpty) {
      return const <int>[];
    }
    if (!_isHttpUrl(url)) {
      return const <int>[];
    }
    try {
      final decoded = await _loadLogoImage(url);
      if (decoded == null) {
        return const <int>[];
      }
      final maxWidth = _logoMaxWidth(lineChars, command['max_width_dots']);
      final resized = image.copyResize(
        decoded,
        width: math.min(maxWidth, decoded.width),
        interpolation: image.Interpolation.average,
      );
      final canvasWidth = _printableDotWidth(lineChars);
      final canvas = image.Image(
        width: canvasWidth,
        height: resized.height + 8,
      );
      image.fill(canvas, color: image.ColorRgb8(255, 255, 255));
      image.compositeImage(
        canvas,
        resized,
        dstX: math.max(0, (canvasWidth - resized.width) ~/ 2),
        dstY: 4,
      );
      return generator.imageRaster(canvas, align: PosAlign.left);
    } catch (_) {
      return const <int>[];
    }
  }

  Future<image.Image?> _loadLogoImage(String url) {
    return _logoImageCache.putIfAbsent(url, () async {
      try {
        final response = await _assetDio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          return null;
        }
        return image.decodeImage(Uint8List.fromList(bytes));
      } catch (_) {
        return null;
      }
    });
  }

  List<int> _renderRow(
    Generator generator,
    Map<String, dynamic> command,
    int lineChars, {
    String? currencyCode,
  }) {
    final left = _stringValue(
      command['left'] ?? command['label'] ?? command['name'],
    );
    final right = _stringValue(
      command['right'] ?? command['value'] ?? command['amount'],
    );
    if (left.isNotEmpty || right.isNotEmpty) {
      return _renderTextLines(
        generator,
        _twoColumnLines(left, right, lineChars, currencyCode: currencyCode),
        styles: _styles(command),
        currencyCode: currencyCode,
      );
    }

    final columns = command['columns'];
    if (columns is List && columns.isNotEmpty) {
      return _renderColumns(
        generator,
        columns,
        lineChars,
        _styles(command),
        currencyCode: currencyCode,
      );
    }

    return const <int>[];
  }

  List<int> _renderColumns(
    Generator generator,
    List<Object?> columns,
    int lineChars,
    PosStyles styles, {
    String? currencyCode,
  }) {
    final cells = columns.map((value) {
      if (value is Map) {
        return _ColumnCell(
          text: _printerText(
            _stringValue(value['text'] ?? value['value']),
            currencyCode: currencyCode,
          ),
          align: _align(value['align']),
        );
      }
      return _ColumnCell(
        text: _printerText(_stringValue(value), currencyCode: currencyCode),
      );
    }).toList();

    final widths = _columnWidths(cells.length, lineChars);
    final wrapped = <List<String>>[];
    var maxLines = 1;
    for (var i = 0; i < cells.length; i += 1) {
      final lines = _wrapText(cells[i].text, widths[i]);
      wrapped.add(lines);
      maxLines = math.max(maxLines, lines.length);
    }

    final rows = <String>[];
    for (var line = 0; line < maxLines; line += 1) {
      final buffer = StringBuffer();
      for (var column = 0; column < cells.length; column += 1) {
        final text = line < wrapped[column].length ? wrapped[column][line] : '';
        final align = column == cells.length - 1 && cells[column].align == null
            ? PosAlign.right
            : cells[column].align ?? PosAlign.left;
        buffer.write(_fitCell(text, widths[column], align));
        if (column < cells.length - 1) {
          buffer.write(' ');
        }
      }
      rows.add(buffer.toString().trimRight());
    }
    return _renderTextLines(
      generator,
      rows,
      styles: styles,
      currencyCode: currencyCode,
    );
  }
}

class _ColumnCell {
  const _ColumnCell({required this.text, this.align});

  final String text;
  final PosAlign? align;
}

PaperSize _paperSize(String? value) {
  final text = value?.toLowerCase() ?? '';
  if (text.contains('56') || text.contains('58')) {
    return PaperSize.mm58;
  }
  if (text.contains('72')) {
    return PaperSize.mm72;
  }
  return PaperSize.mm80;
}

int _paperLineChars(String? value, PaperSize paperSize) {
  final text = value?.toLowerCase() ?? '';
  if (text.contains('56')) {
    return 30;
  }
  return switch (paperSize) {
    PaperSize.mm58 => 32,
    PaperSize.mm72 => 42,
    PaperSize.mm80 => 48,
    _ => 48,
  };
}

List<String> _wrappedPrinterLines(
  String value,
  int lineChars, {
  String? currencyCode,
}) {
  return _printerText(
    value,
    currencyCode: currencyCode,
  ).split('\n').expand((line) => _wrapText(line, lineChars)).toList();
}

String _commandType(Map<String, dynamic> command) {
  return _stringValue(command['type'] ?? command['kind']).toLowerCase();
}

List<int> _renderTextLines(
  Generator generator,
  Iterable<String> lines, {
  int? lineChars,
  PosStyles styles = const PosStyles(),
  String? currencyCode,
}) {
  final bytes = <int>[];
  final manuallyCenter = styles.align == PosAlign.center && lineChars != null;
  final effectiveLineChars = lineChars == null
      ? null
      : _styledLineChars(lineChars, styles);
  final effectiveStyles = manuallyCenter
      ? styles.copyWith(align: PosAlign.left)
      : styles;
  for (final line in lines) {
    final text = _printerText(line, currencyCode: currencyCode);
    bytes.addAll(
      generator.text(
        manuallyCenter ? _centerAlign(text, effectiveLineChars!) : text,
        styles: effectiveStyles,
      ),
    );
  }
  return bytes;
}

List<String> _twoColumnLines(
  String left,
  String right,
  int lineChars, {
  String? currencyCode,
}) {
  final cleanLeft = _printerText(left, currencyCode: currencyCode);
  final cleanRight = _printerText(right, currencyCode: currencyCode);
  if (cleanLeft.isEmpty) {
    return _wrapText(
      cleanRight,
      lineChars,
    ).map((line) => _rightAlign(line, lineChars)).toList();
  }
  if (cleanRight.isEmpty) {
    return _wrapText(cleanLeft, lineChars);
  }
  if (cleanRight.length >= lineChars - 8) {
    return [
      ..._wrapText(cleanLeft, lineChars),
      ..._wrapText(cleanRight, lineChars).map((line) {
        return _rightAlign(line, lineChars);
      }),
    ];
  }

  final rightWidth = math.min(cleanRight.length, math.max(8, lineChars ~/ 3));
  final leftWidth = math.max(1, lineChars - rightWidth - 1);
  final leftLines = _wrapText(cleanLeft, leftWidth);
  final rows = <String>[];
  for (var i = 0; i < leftLines.length; i += 1) {
    if (i == 0) {
      final paddedLeft = leftLines[i]
          .padRight(leftWidth)
          .substring(0, leftWidth);
      rows.add('$paddedLeft ${_rightAlign(cleanRight, rightWidth)}');
    } else {
      rows.add(leftLines[i]);
    }
  }
  return rows;
}

List<String> _wrapText(String value, int width) {
  final safeWidth = math.max(1, width);
  final text = value.trim();
  if (text.isEmpty) {
    return [''];
  }

  final lines = <String>[];
  for (final rawLine in text.split('\n')) {
    final words = rawLine.trim().split(RegExp(r'\s+'));
    var current = '';
    for (final word in words) {
      if (word.length > safeWidth) {
        if (current.isNotEmpty) {
          lines.add(current);
          current = '';
        }
        for (var index = 0; index < word.length; index += safeWidth) {
          lines.add(
            word.substring(index, math.min(index + safeWidth, word.length)),
          );
        }
        continue;
      }
      final candidate = current.isEmpty ? word : '$current $word';
      if (candidate.length > safeWidth) {
        if (current.isNotEmpty) {
          lines.add(current);
        }
        current = word;
      } else {
        current = candidate;
      }
    }
    if (current.isNotEmpty) {
      lines.add(current);
    }
  }
  return lines.isEmpty ? [''] : lines;
}

List<int> _columnWidths(int count, int lineChars) {
  if (count <= 1) {
    return [lineChars];
  }
  if (count == 2) {
    final first = (lineChars * 0.62).floor();
    return [first, lineChars - first - 1];
  }
  if (count == 3) {
    final first = lineChars <= 32 ? 4 : 5;
    final last = lineChars <= 32 ? 9 : 11;
    return [first, lineChars - first - last - 2, last];
  }

  final gapChars = count - 1;
  final base = (lineChars - gapChars) ~/ count;
  final widths = List<int>.filled(count, base);
  widths[count - 1] += lineChars - gapChars - widths.fold(0, (a, b) => a + b);
  return widths;
}

String _fitCell(String value, int width, PosAlign align) {
  final clipped = value.length > width ? value.substring(0, width) : value;
  return switch (align) {
    PosAlign.center => _centerAlign(clipped, width),
    PosAlign.right => _rightAlign(clipped, width),
    PosAlign.left => clipped.padRight(width),
  };
}

String _rightAlign(String value, int width) {
  if (value.length >= width) {
    return value.substring(value.length - width);
  }
  return value.padLeft(width);
}

String _centerAlign(String value, int width) {
  if (value.length >= width) {
    return value.substring(0, width);
  }
  final leftPadding = ((width - value.length) / 2).floor();
  return value.padLeft(value.length + leftPadding).padRight(width);
}

int _styledLineChars(int lineChars, PosStyles styles) {
  return math.max(1, lineChars ~/ math.max(1, styles.width.value));
}

PosStyles _styles(Map<String, dynamic> command) {
  final style = _stringValue(command['style']).toLowerCase();
  return PosStyles(
    align: _align(command['align']),
    bold: command['bold'] == true || style.contains('bold'),
    height: _textSize(command['size'] ?? command['font_size'] ?? style),
    width: _textSize(command['size'] ?? command['font_size'] ?? style),
  );
}

PosAlign _align(Object? value) {
  switch (_stringValue(value).toLowerCase()) {
    case 'center':
    case 'centre':
      return PosAlign.center;
    case 'right':
      return PosAlign.right;
    case 'left':
    default:
      return PosAlign.left;
  }
}

PosTextSize _textSize(Object? value) {
  final text = _stringValue(value).toLowerCase();
  final numeric = int.tryParse(text);
  if (text.contains('large') ||
      text.contains('title') ||
      text.contains('bold_large') ||
      (numeric != null && numeric > 1)) {
    return PosTextSize.size2;
  }
  return PosTextSize.size1;
}

QRSize _qrSize(Object? value) {
  final text = _stringValue(value).toLowerCase();
  final numeric = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
  final size = numeric ?? (text.contains('small') ? 3 : 4);
  return switch (size.clamp(1, 8)) {
    1 => QRSize.size1,
    2 => QRSize.size2,
    3 => QRSize.size3,
    4 => QRSize.size4,
    5 => QRSize.size5,
    6 => QRSize.size6,
    7 => QRSize.size7,
    _ => QRSize.size8,
  };
}

QRCorrection _qrCorrection(Object? value) {
  switch (_stringValue(value).toLowerCase()) {
    case 'm':
    case 'medium':
      return QRCorrection.M;
    case 'q':
    case 'quartile':
      return QRCorrection.Q;
    case 'h':
    case 'high':
      return QRCorrection.H;
    case 'l':
    case 'low':
    default:
      return QRCorrection.L;
  }
}

PosCutMode _cutMode(Object? value) {
  return switch (_stringValue(value).toLowerCase()) {
    'partial' => PosCutMode.partial,
    _ => PosCutMode.full,
  };
}

int _printableDotWidth(int lineChars) {
  if (lineChars <= 32) {
    return 384;
  }
  if (lineChars <= 42) {
    return 512;
  }
  return 576;
}

int _logoMaxWidth(int lineChars, Object? value) {
  final text = _stringValue(value).toLowerCase();
  final numeric = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
  final paperMax = _printableDotWidth(lineChars) - 24;
  if (numeric != null && numeric > 0) {
    return numeric.clamp(80, paperMax);
  }
  return lineChars <= 32 ? 180 : 240;
}

String _dividerChar(Map<String, dynamic> command) {
  final value = _stringValue(
    command['char'] ?? command['pattern'],
    fallback: '-',
  );
  return value.isEmpty ? '-' : value.substring(0, 1);
}

bool _isHttpUrl(String value) {
  final normalized = value.toLowerCase();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}

String _printerText(String value, {String? currencyCode}) {
  final code = currencyCode?.toUpperCase();
  var text = value
      .replaceAll('\u20b9', 'Rs ')
      .replaceAll('\u00c2\u00a4', 'Rs ')
      .replaceAll('\u00a4', 'Rs ')
      .replaceAll('\u00b7', ' - ')
      .replaceAll('\u2022', ' - ')
      .replaceAll('\u2027', ' - ')
      .replaceAll('\u2219', ' - ')
      .replaceAll('\u00a0', ' ');
  if (code == 'INR') {
    text = text.replaceAllMapped(RegExp(r'\$\s*(?=\d)'), (_) => 'Rs ');
  }
  return text.replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E]'), '?');
}

String _itemName(Map<String, dynamic> item) {
  final nestedMenuItem = _asMap(item['menu_item'] ?? item['menuItem']);
  return _stringValue(
    item['name'] ??
        item['item_name'] ??
        item['menu_item_name'] ??
        nestedMenuItem?['name'],
    fallback: 'Item',
  );
}

String _amountText(Object? value, {String? currencyCode}) {
  if (value == null) {
    return '';
  }
  if (value is num) {
    return currencyCode?.toUpperCase() == 'INR'
        ? 'Rs ${value.toStringAsFixed(2)}'
        : value.toStringAsFixed(2);
  }
  final text = _stringValue(value).trim();
  return text.isEmpty ? '' : _printerText(text, currencyCode: currencyCode);
}

String _firstText(
  Map<String, dynamic> source,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = _deepValue(source, key);
    final text = _stringValue(value);
    if (text.isNotEmpty) {
      return text;
    }
  }
  return fallback;
}

Object? _deepValue(Map<String, dynamic> source, String key) {
  final parts = key.split('.');
  Object? current = source;
  for (final part in parts) {
    if (current is Map) {
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString();
  return text == null || text.isEmpty ? fallback : text;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
