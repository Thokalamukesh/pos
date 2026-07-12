class AppConfig {
  const AppConfig._();

  static const baseUrl = String.fromEnvironment(
    'SELFX_BASE_URL',
    defaultValue: 'https://app.selfx.in',
  );
  static const publicBaseUrl = String.fromEnvironment(
    'SELFX_PUBLIC_BASE_URL',
    defaultValue: 'https://iisc.app.selfx.in',
  );

  static const apiPrefix = '/api/v1';
  static const appVersion = String.fromEnvironment(
    'SELFX_APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const platformHeaderValue = String.fromEnvironment(
    'SELFX_PLATFORM',
    defaultValue: 'android',
  );

  static String urlFrom(String base, String path) {
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
