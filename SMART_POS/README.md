# Smart POS & Full Inventory Management App

A comprehensive Point of Sale (POS) and inventory management application built with Flutter. This app supports both online and offline operations with automatic synchronization and backup capabilities.

## Features

- **User Authentication**: Secure login and registration system
- **Product Management**: Add, edit, and delete products with SKU, price, cost, and category
- **Inventory Control**: Track stock levels, low stock alerts, and stock history
- **POS System**: Complete billing system with cart management, quantity adjustments, discounts, and taxes
- **Customer Management**: Handle walk-in and regular customers with purchase history
- **Ledger System**: Track debits, credits, payments, and outstanding balances
- **Reports**: Daily, monthly, stock, and customer reports
- **Offline Mode**: Full functionality without internet using local SQLite database
- **Online Sync**: Automatic synchronization with online database when internet is restored
- **Backup System**: Manual and automatic backup with Google Drive integration
- **Google Drive Backup**: Cloud backup and restore functionality
- **Settings**: Business configuration and security options

## Technology Stack

- **Frontend**: Flutter
- **Database**: SQLite (offline), with backend integration capability (Firebase/Supabase/REST API)
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences
- **Connectivity**: Connectivity Plus
- **File Operations**: File Picker, Path
- **Charts**: FL Chart
- **PDF Generation**: PDF, Printing
- **Authentication**: Google Sign-In for cloud backup

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code with Flutter plugin

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd smart_pos
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── product.dart
│   ├── customer.dart
│   ├── transaction.dart
│   ├── transaction_item.dart
│   └── user.dart
├── services/
│   ├── database_service.dart
│   ├── auth_service.dart
│   ├── backup_service.dart
│   ├── sync_service.dart
│   ├── product_service.dart
│   ├── customer_service.dart
│   └── transaction_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── sync_provider.dart
│   ├── product_provider.dart
│   ├── customer_provider.dart
│   └── pos_cart_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── product_management_screen.dart
│   ├── add_product_screen.dart
│   ├── pos_screen.dart
│   ├── customer_management_screen.dart
│   ├── add_customer_screen.dart
│   ├── reports_screen.dart
│   ├── backup_screen.dart
│   └── settings_screen.dart
└── utils/
    ├── constants.dart
    ├── theme.dart
    └── date_formatter.dart
```

## Key Functionality

### Authentication
- User login and registration
- Session management with shared preferences
- Role-based access (admin, manager, cashier)

### Product Management
- Add/edit/delete products
- Track inventory levels
- Categorize products
- Manage pricing (cost vs selling price)
- Low stock alerts
- Product search and filtering

### POS System
- Real-time cart management
- Quantity adjustments
- Discount and tax calculations
- Multiple payment methods
- Customer association
- Transaction history

### Customer Management
- Add/edit/delete customers
- Track purchase history
- View top customers
- Customer search

### Offline Support
- Full functionality without internet
- Local SQLite database
- Automatic sync when connection is restored
- Conflict resolution handling

### Backup & Sync
- Local backup to device storage
- Google Drive cloud backup
- Automatic and manual backup options
- Data restore functionality
- List of available backups

### Reports
- Sales by date
- Top selling products
- Transaction count
- Revenue tracking

### Settings
- Business configuration
- User profile management
- Sync options
- Security settings

## Implementation Details

### Database Schema
The application uses SQLite for local storage with the following tables:
- `users`: Stores user information
- `products`: Stores product information
- `customers`: Stores customer information
- `transactions`: Stores transaction records
- `transaction_items`: Stores individual items in transactions

### State Management
The application uses Provider for state management:
- `AuthProvider`: Manages authentication state
- `SyncProvider`: Handles online/offline synchronization
- `ProductProvider`: Manages product data
- `CustomerProvider`: Manages customer data
- `PosCartProvider`: Manages POS cart state

### Offline-First Architecture
The application is designed with an offline-first approach:
- All core functionality works without internet
- Data is stored locally using SQLite
- Automatic synchronization when internet is available
- Manual sync option for user control

## Screenshots

<img width="720" height="1450" alt="image" src="https://github.com/user-attachments/assets/60e5c0c4-c221-42d9-84bb-2c4986a53d2c" />
<img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/079155a2-7f9d-40e9-a01e-a82589014532" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/794b66cb-449f-423c-a59c-aee7cedabfb8" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/e50e12bf-01fc-4017-98a8-e860c556db9d" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/9a509e70-f42c-4981-be17-6c95089ce440" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/aaeeeda5-036e-4d42-beda-0c4eca3bc8c4" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/a8f15eb9-13d6-4f9b-854d-be42b0ef190f" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/b24dfc5f-e4b0-489f-800b-97898e981234" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/0061cb1f-f40e-4778-a6b0-19025173f35b" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/343cf28b-c5bc-48c0-b132-b52149e1a56c" /><img width="494" height="928" alt="image" src="https://github.com/user-attachments/assets/b32a248a-cf2b-4d11-9ceb-b6702fc9dae5" />













## APK

[Include link to APK file here]

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All the package maintainers for the libraries used in this project
- The open-source community for inspiration and examples
