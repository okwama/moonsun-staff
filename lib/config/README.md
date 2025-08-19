# Configuration System

This directory contains the centralized configuration for the Woosh Flutter app.

## Files

### `app_config.dart`
Main configuration file containing:
- API endpoints
- App settings
- Storage keys
- Notification settings
- Timezone settings

### `environment.dart`
Environment-specific configuration:
- Development, staging, and production environments
- Environment-specific URLs and settings
- Request timeouts per environment

## Usage

### Basic Usage
```dart
import '../config/app_config.dart';

// Get API endpoint
String authUrl = AppConfig.authEndpoint;

// Get app settings
String appName = AppConfig.appName;
```

### Environment Switching
```dart
import '../config/environment.dart';

// Set environment (call this early in main.dart)
EnvironmentConfig.setEnvironment(Environment.production);

// Get environment-specific settings
String baseUrl = EnvironmentConfig.baseUrl;
bool enableLogs = EnvironmentConfig.enableLogs;
```

## Environment URLs

- **Development**: `http://192.168.100.2:3000/api`
- **Staging**: `https://staging-api.woosh.com/api`
- **Production**: `https://api.woosh.com/api`

## Benefits

1. **Centralized Management**: All URLs and settings in one place
2. **Easy Environment Switching**: Change environment with one line
3. **Type Safety**: Compile-time checking of configuration values
4. **Maintainability**: Easy to update URLs and settings
5. **Consistency**: All services use the same configuration

## Adding New Endpoints

To add a new API endpoint:

1. Add it to `AppConfig`:
```dart
static String get newEndpoint => '$baseUrl/new-feature';
```

2. Use it in your service:
```dart
import '../config/app_config.dart';

class NewService {
  static String get baseUrl => AppConfig.newEndpoint;
}
``` 