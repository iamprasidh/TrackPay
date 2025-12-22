# TrackPay

A comprehensive personal finance management application built with Flutter. TrackPay helps you track your income, expenses, manage multiple accounts, set budgets, and gain insights into your spending patterns with detailed analytics.

##  Features

### Core Features
- **Transaction Management**: Add, edit, and delete income and expense transactions with detailed information
- **Multi-Account Support**: Manage multiple bank accounts or wallets in one place
- **Category System**: Organize transactions with customizable categories and subcategories
- **Budget Tracking**: Set and monitor budgets for different spending categories
- **Analytics Dashboard**: View comprehensive analytics and spending patterns
- **Dark Mode Support**: Comfortable viewing in any lighting condition

### Advanced Features
- **Data Export/Import**: 
  - Export transactions to CSV format for backup and external analysis
  - Import CSV files to restore or migrate data
  - Export data to Excel format for detailed spreadsheet analysis
- **Multi-Currency Support**: Track transactions in different currencies
- **Persistent Storage**: All data stored locally using Hive database for privacy and offline access
- **Customizable Settings**: Personalize the app with your preferred currency and theme

##  Use Cases
- Personal expense tracking
- Budget management and planning
- Income and expense analysis
- Financial record keeping
- Tax documentation
- Spending habit monitoring

##  Tech Stack

### Framework & Languages
- **Flutter**: Cross-platform mobile application framework
- **Dart**: Programming language

### Key Dependencies
- **hive & hive_flutter**: Local database for efficient data storage
- **flutter_riverpod**: State management solution
- **google_fonts**: Typography support
- **excel**: Excel file generation and manipulation
- **pdf**: PDF file creation and handling
- **file_saver**: File download and saving functionality
- **permission_handler**: Android/iOS permissions management
- **uuid**: Unique identifier generation
- **path_provider**: Access to device directories

### Development Tools
- **build_runner**: Code generation
- **hive_generator**: Hive adapter generation
- **flutter_launcher_icons**: App icon management
- **flutter_lints**: Dart linting

## 📋 Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/                   # Data models
│   ├── account.dart         # Account model
│   ├── budget.dart          # Budget model
│   ├── category.dart        # Category model
│   ├── settings.dart        # Application settings
│   ├── transaction.dart     # Transaction model
│   ├── transaction_type.dart# Transaction type (Income/Expense)
│   └── user.dart            # User profile model
├── providers/               # Riverpod state management
├── screens/                 # UI Screens
│   ├── home_screen.dart     # Main home screen
│   ├── launch/              # App launch/splash screens
│   ├── intro/               # Introduction/onboarding screens
│   ├── dashboard/           # Analytics and dashboard screens
│   ├── transactions/        # Transaction management screens
│   ├── accounts/            # Account management screens
│   └── settings/            # Settings screen
├── services/                # Business logic and API integration
└── utils/                   # Utility functions and constants
```

##  Getting Started

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Dart SDK (included with Flutter)
- Android Studio, Xcode, or any Flutter-supported IDE

### Installation

1. **Clone the repository**
   `bash
   git clone <repository-url>
   cd trackpay
   `

2. **Install dependencies**
   `bash
   flutter pub get
   `

3. **Generate code (Hive adapters and other generated files)**
   `bash
   flutter pub run build_runner build --delete-conflicting-outputs
   `

4. **Run the application**
   `bash
   flutter run
   `

### Building for Production

**Android APK:**
`bash
flutter build apk --release
`

**iOS App:**
`bash
flutter build ios --release
`

**Windows Desktop:**
`bash
flutter build windows --release
`

##  Data Management

### Backup & Restore
- **Export to CSV**: Access Settings  Export CSV (Backup) to download your transaction data
- **Import from CSV**: Use Settings  Import CSV (Restore) to restore backed-up data
- **Excel Export**: Export all data to Excel format for detailed analysis and record keeping

All data is stored locally on your device using the Hive database, ensuring your financial information remains private and accessible even without an internet connection.

##  Configuration

### Currency Settings
Configure your preferred currency in the Settings screen. The app will use this currency for all transactions and reports.

### Theme Settings
Toggle Dark Mode on/off from the Settings screen for comfortable viewing in any environment.

### User Profile
Set your name in Settings for personalized app experience.

##  App Screens

- **Home Screen**: Quick overview of recent transactions
- **Dashboard**: Analytics with spending patterns and trends
- **Add Transaction**: Easy transaction entry with categories and accounts
- **Settings**: Comprehensive preferences and data management options

##  Contributing

Contributions are welcome! If you find any bugs or have feature suggestions, please feel free to open an issue or submit a pull request.

##  License

This project is private and intended for personal use.

##  Support

For issues, feature requests, or questions, please open an issue in the repository.

---

**Note**: All financial data is stored locally on your device. TrackPay does not collect, store, or transmit your financial information to external servers.
