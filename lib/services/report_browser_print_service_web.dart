import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

Future<void> printReportHtmlInBrowser({
  required String title,
  required String html,
}) async {
  final printWindow = window.open('', '_blank', 'width=420,height=720');
  if (printWindow == null) {
    throw UnsupportedError('Allow popups to use browser print.');
  }
  printWindow.document.write(_printDocument(title: title, body: html).toJS);
  printWindow.document.close();
  printWindow.focus();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  printWindow.print();
}

bool get browserReportPrintSupported => true;

String _printDocument({required String title, required String body}) {
  return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>${_escapeHtml(title)}</title>
  <style>
    @page { margin: 8mm; }
    body {
      margin: 0;
      color: #111827;
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      font-size: 11px;
      line-height: 1.28;
    }
    .receipt {
      width: 80mm;
      max-width: 100%;
      margin: 0 auto;
    }
    .center { text-align: center; }
    .right { text-align: right; }
    .bold { font-weight: 700; }
    .large { font-size: 16px; font-weight: 800; }
    .line { border-top: 1px dashed #111827; margin: 8px 0; }
    .row {
      display: grid;
      grid-template-columns: minmax(0, 1fr) auto;
      gap: 8px;
      align-items: flex-start;
      break-inside: avoid;
    }
    .row span:first-child { overflow-wrap: break-word; }
    .row span:last-child {
      max-width: 34mm;
      text-align: right;
    }
    pre {
      white-space: pre;
      overflow-wrap: normal;
      font-family: inherit;
      margin: 0;
    }
  </style>
</head>
<body>
  <div class="receipt">$body</div>
  <script>
    window.addEventListener('afterprint', () => window.close());
  </script>
</body>
</html>
''';
}

String _escapeHtml(Object? value) {
  return value
      .toString()
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
