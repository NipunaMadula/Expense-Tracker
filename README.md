# CyphExpense - Expense Tracker Mobile App

> **Practical Task for Flutter Developer Internship at CyphLab**  
> Built with Flutter 3.27, Dart 3.6, Provider, Firebase Cloud Firestore, Firebase Authentication, and Material 3.

---

## 🌟 Executive Summary

**CyphExpense** is a personal expense tracker developed for the CyphLab Flutter Developer Internship practical task. It supports Firebase-backed user data, local fallback storage, expense analytics, filtering, validation, and theme preferences.

---

## ✨ Features Implemented

### 🎯 Core Requirements
- [x] **Add New Expenses:** Seamless entry with form validation, category selection, date picker, amount formatting, and optional description notes.
- [x] **Edit Existing Expenses:** Edit any expense with pre-populated fields and instant reactive UI updates.
- [x] **Delete Expenses:** Swipe-to-delete with confirmation modal and an instant **"Undo" SnackBar** to prevent accidental data loss.
- [x] **Category Selection:** 11 distinct categories (Food & Dining, Transportation, Shopping, Entertainment, Bills & Utilities, Health, Education, Travel, Personal Care, Investments, Other), each equipped with custom icons and curated Material 3 color palettes.
- [x] **Firebase Integration:** Real-time synchronized cloud storage using **Cloud Firestore** (`users/{userId}/expenses`), stream-based listeners, and deployed security rules.
- [x] **Monthly Expense Totals:** Prominently displays the total spending for the active/selected month, month-over-month trend percentage comparison (`+12.4% vs last month`), and average daily spending.
- [x] **Expense History & Chronological List:** Chronologically sorted list of transactions with category badge, formatted relative timestamps ("Today", "Yesterday", "MMM d, yyyy"), and notes snippet.
- [x] **Multi-Criteria Filtering & Sorting:**
  - Instant search across titles, notes, and amounts.
  - Category filter chips and multi-category bottom sheet.
  - Custom date range picker (`showDateRangePicker`) and smooth Month selector navigation (`< September 2026 >`).
  - Sort by Newest First, Oldest First, Highest Amount, or Lowest Amount.
- [x] **Form Validation:**
  - Title: required, min 2 chars, max 50 chars.
  - Amount: required, positive numeric validation with currency prefix, max value limit.
  - Category: mandatory selection.
  - Date: date picker constraint.
  - Note: optional, max 250 characters.
- [x] **State Handling:**
  - **Loading States:** Modern circular indicator with status message.
  - **Empty States:** Clean illustrations with friendly messages and a quick "Add Expense" call-to-action.
  - **Error States:** Informative error view with "Try Again" retry action.

---

### 🚀 Additional & Bonus Features
- [x] **Interactive Expense Charts (`fl_chart`):**
  - **Category Breakdown Pie Chart:** Interactive touch selection with dynamic radius enlargement, percentages, and colored legend items.
  - **6-Month Spending Trend Bar Chart:** Visualizes historical spending trends over the last 6 months with custom gradient rods and tooltips.
- [x] **Dark Mode & Light Mode:**
  - System, light, and dark theme selection in Settings.
  - Full support for System, Light, and Dark modes persisted across restarts via `SharedPreferences`.
  - Rich contrast color palette (Deep Slate in Dark Mode, Crisp Indigo/Cyan in Light Mode).
- [x] **Monthly Budget Goal & Alert Bar:**
  - Custom monthly budget goal setting in Settings.
  - Visual progress bar on the dashboard showing percentage spent, automatically warning when reaching 80% (amber) or exceeding 100% (rose red).
- [x] **Firebase Authentication:**
  - One-click Anonymous Guest login.
  - Email and password Sign In and Sign Up with validation.
  - Multi-user isolation in Cloud Firestore.
- [x] **Export Expenses to CSV:**
  - Generates standard CSV spreadsheet data formatted with escaped strings, dates, and amounts.
  - One-tap "Copy to Clipboard" for sharing or backup.
- [x] **Local fallback mode:**
  - If Firebase cannot initialize on an unsupported platform or because configuration is unavailable, the app uses local reactive storage with sample expenses.
  - On configured Android/iOS builds, users must sign in as a guest or with email/password before Firestore expenses are available.
- [x] **Branded splash screen:**
  - Animated CyphExpense splash screen with light and dark theme support.

---

## 🏗️ Architecture & Code Structure

The application adheres to the **MVVM (Model-View-ViewModel)** architectural pattern and **Separation of Concerns**, inspired by official Flutter best practices:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Material 3 light/dark palette & category colors
│   │   └── app_constants.dart         # Defaults, validation limits, storage keys
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 light/dark themes with Google Fonts (Inter)
│   ├── utils/
│   │   ├── csv_exporter.dart          # CSV generation & string escaping
│   │   ├── currency_formatter.dart    # NumberFormat currency & compact formatting
│   │   └── date_formatter.dart        # Relative dates, month/year parsing
│   └── widgets/
│       ├── empty_state_view.dart      # Clean empty state widget
│       ├── error_state_view.dart      # Error state with retry callback
│       ├── loading_indicator.dart     # Modern circular indicator
│       └── stat_card.dart             # Metric card with icons & badges
├── data/
│   ├── models/
│   │   ├── expense_category.dart      # Category enum with icons and colors
│   │   ├── expense_model.dart         # Immutable data model with Firestore serialization
│   │   └── user_model.dart            # Auth user representation
│   └── repositories/
│       ├── auth_repository.dart       # FirebaseAuth & LocalAuth implementations
│       ├── expense_repository.dart    # Abstract interface for repository pattern
│       ├── firestore_expense_repository.dart  # Cloud Firestore implementation
│       └── local_expense_repository.dart      # Local reactive storage + sample data
├── providers/
│   ├── auth_provider.dart             # Auth state ViewModel
│   ├── expense_provider.dart          # Core Expense ViewModel (streams, filtering, CRUD)
│   └── theme_provider.dart            # Theme, currency, and budget preferences
├── ui/
│   ├── home_navigation_screen.dart    # Shell navigation (Overview, Expenses, Analytics, Settings)
│   └── screens/
│       ├── analytics/
│       │   └── analytics_screen.dart  # Deep visual breakdown & category rankings
│       ├── auth/
│       │   └── auth_screen.dart       # Sign In, Sign Up, and Guest mode
│       ├── dashboard/
│       │   ├── dashboard_screen.dart  # Month navigator, summary card, stats, charts preview
│       │   └── widgets/
│       │       ├── category_pie_chart.dart
│       │       ├── month_selector.dart
│       │       ├── monthly_bar_chart.dart
│       │       └── summary_card.dart
│       ├── expense_detail/
│       │   └── expense_detail_screen.dart # Detailed expense inspection & quick actions
│       ├── expense_form/
│       │   └── expense_form_screen.dart   # Add & Edit expense form with validation
│       ├── expense_list/
│       │   ├── expense_list_screen.dart   # Filterable history list with search
│       │   └── widgets/
│       │       ├── expense_card.dart      # Swipe-to-delete card
│       │       └── expense_filter_sheet.dart # Multi-criteria filter modal
│       └── settings/
│           └── settings_screen.dart   # Account, currency, budget, theme, and CSV export
├── firebase_options.dart              # FlutterFire configuration options
└── main.dart                          # App entry point with MultiProvider & initialization
```

---

## 📦 Packages & Technologies Used

| Package | Version | Purpose |
|---|---|---|
| **flutter** | 3.27.4 | Core framework |
| **provider** | ^6.1.5+1 | State management & dependency injection (MVVM) |
| **cloud_firestore** | ^5.6.2 | Cloud database storage and real-time sync |
| **firebase_auth** | ^5.4.1 | User authentication (Anonymous + Email/Password) |
| **firebase_core** | ^3.10.1 | Firebase engine initialization |
| **fl_chart** | ^0.69.0 | Interactive pie and bar charts |
| **google_fonts** | ^6.3.0 | Modern typography (Inter) |
| **intl** | ^0.20.2 | Currency formatting & date manipulation |
| **shared_preferences** | ^2.5.3 | Local persistence for themes, currency & offline cache |
| **uuid** | ^4.6.0 | Unique transaction identifier generation |

---

## AI Tools Used

GitHub Copilot was used during development for code exploration, implementation support, debugging, test updates, Firebase setup guidance, and README cleanup. The final code and configuration were reviewed and tested in the project workspace.

### How AI Tools Helped:
1. **Architecture & Boilerplate Scaffolding:** Assisted with the Provider and repository structure and separation of concerns.
2. **Data & Math Computations:** Assisted in formulating concise algorithms for month-over-month trend percentages, daily averages, and category spending distribution.
3. **Chart Configuration:** Expedited the setup of `fl_chart` interactive touch data callbacks and custom gradient bar rods.
4. **Testing and Debugging:** Assisted with unit/widget test updates, Firebase troubleshooting, and layout overflow fixes.
5. **Documentation:** Assisted with setup instructions and implementation notes.

---

## 🧪 Automated Testing

The project includes unit and widget tests verifying core business logic and UI integrity:

- **`test/models/expense_model_test.dart`**: Tests serialization/deserialization to/from Map and Firestore, `copyWith`, and value equality.
- **`test/repositories/local_expense_repository_test.dart`**: Tests CRUD operations and reactive stream broadcasts.
- **`test/providers/expense_provider_test.dart`**: Tests ViewModel search filtering, category filtering, month calculations, and undo functionality.
- **`test/widget_test.dart`**: Tests application mounting, navigation destinations, and dashboard components.

To run tests:
```bash
flutter test
```
Run the command locally to verify the current result before submission.

---

## 🚀 Setup & Execution Instructions

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.27 or newer)
- Dart SDK 3.6 or newer
- An Android device / emulator, Chrome browser, or Windows desktop environment

### 1. Clone the Repository
Clone the published repository using its GitHub URL, then open the project directory:

```bash
git clone https://github.com/NipunaMadula/Expense-Tracker.git
cd Expense-Tracker
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the Application
You can run the app directly on any connected device:

```bash
# Run on Android emulator / device
flutter run -d emulator-5554

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```

> **Firebase setup:**
> The repository is configured for the Firebase project used during development. To use another project, run `flutterfire configure`, enable Anonymous and Email/Password Authentication, enable Cloud Firestore, add the Android SHA-1 and SHA-256 fingerprints, and download the updated `google-services.json` into `android/app/`.

Deploy the included Firestore rules from the project root:

```bash
firebase deploy --only firestore:rules
```

The rules allow access only to the signed-in user's `users/{userId}/expenses/{expenseId}` documents.

---

## Submission Checklist

- [x] Publish this project in a public GitHub repository: [Expense Tracker on GitHub](https://github.com/NipunaMadula/Expense-Tracker)
- [x] Record a short demonstration and upload it to Google Drive with viewer access or YouTube as an unlisted video: [Demo Video](https://drive.google.com/file/d/1-etcCM8VBNS96ja2rkvULq4jQLbZoKUw/view?usp=sharing)
- [x] Build an APK with `flutter build apk --release`: [Download APK](https://drive.google.com/file/d/10TdDGXZ4oCiO7iNtF3DL72-y7IHRZZBI/view?usp=sharing)

---

*Thank you for reviewing this submission for the Flutter Developer Internship at CyphLab!*
