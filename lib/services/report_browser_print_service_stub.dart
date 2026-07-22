Future<void> printReportHtmlInBrowser({
  required String title,
  required String html,
}) async {
  throw UnsupportedError('Browser print is only available in a web build.');
}

bool get browserReportPrintSupported => false;
