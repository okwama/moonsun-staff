enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://192.168.100.2:3000/api';
      case Environment.staging:
        return 'https://nest-origin.vercel.app/api';
      case Environment.production:
        return 'https://nest-origin.vercel.app/api';
    }
  }

  static bool get enableLogs {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static int get requestTimeout {
    switch (_environment) {
      case Environment.development:
        return 30000; // 30 seconds
      case Environment.staging:
        return 15000; // 15 seconds
      case Environment.production:
        return 10000; // 10 seconds
    }
  }

  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
}
