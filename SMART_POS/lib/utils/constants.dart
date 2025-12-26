class AppConstants {
  // App Name
  static const String appName = 'Smart POS';

  // API Endpoints (will be configured based on backend choice)
  static const String baseUrl = 'https://your-backend-url.com/api'; // Replace with your actual backend URL
  
  // Shared preference keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String backupPathKey = 'backup_path';

  // Default values
  static const double defaultTaxRate = 0.0; // Will be configurable in settings
  static const String defaultCurrency = 'USD';
  static const int defaultPageSize = 20;

  // Validation patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]{10,}$';
  static const String passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,}$';

  // Storage paths
  static const String backupDirectory = 'smart_pos_backups';
  static const String imageDirectory = 'smart_pos_images';

  // Colors
  static const int primaryColorValue = 0xFF6200EE;
  static const int secondaryColorValue = 0xFF03DAC6;
  static const int backgroundColorValue = 0xFFFFFFFF;
  static const int surfaceColorValue = 0xFFFFFFFF;
  static const int errorColorValue = 0xFFB00020;
  static const int successColorValue = 0xFF4CAF50;
  
  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;

  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;

  // Status values
  static const String transactionCompleted = 'completed';
  static const String transactionPending = 'pending';
  static const String transactionCancelled = 'cancelled';
  
  static const String userRoleAdmin = 'admin';
  static const String userRoleManager = 'manager';
  static const String userRoleCashier = 'cashier';

  // Backup types
  static const String backupTypeManual = 'manual';
  static const String backupTypeAuto = 'auto';
  static const String backupTypeCloud = 'cloud';

  // Sync status
  static const String syncStatusPending = 'pending';
  static const String syncStatusSyncing = 'syncing';
  static const String syncStatusCompleted = 'completed';
  static const String syncStatusFailed = 'failed';
}