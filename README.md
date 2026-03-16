# QuadBank - Mobile Banking Application

A **modern mobile banking application** built with **Flutter and Firebase**. QuadBank provides a full digital banking experience including **account management, fund transfers, bill payments, savings goals, virtual credit cards, and transaction tracking**.

---

## 📱 Features

### 🔐 Authentication
- User registration with **email verification**
- Secure login with **Remember Me**
- **Password reset via email**
- **Auto logout** when app is paused for security

---

### 💰 Account Management
- Real-time **balance tracking**
- Deposit funds
- View **account details**
  - Account number
  - Card details
- Toggle **balance visibility**

---

### 💸 Money Transfer
- Transfer funds using **account numbers**
- Optional **transaction memo**
- **Real-time balance updates**
- Transaction **confirmation screen**

---

### 📊 Savings Goals
- Create **multiple savings goals**
- Visual **progress tracking**
- Transfer money from **main balance → goals**
- Transfer **completed goals → main balance**
- Separate views for **active and completed goals**

---

### 💳 Virtual Credit Card
- Virtual card displaying:
  - Card number
  - Expiry date
  - CVV
- Card details **auto-generated from user data**
- **Temporary and permanent disable options**
- Secure card display

---

### 📱 Transaction History
- Complete **transaction log**
- Transaction types:
  - Deposits
  - Transfers
  - Bill payments
  - Received funds
- **Color-coded amounts**
  - 🟢 Incoming
  - 🔴 Outgoing
- Transaction details including **date and participants**

---

### 💡 Bill Payments
Supported bill types:
- Electricity
- Water
- Internet
- Gas
- Mobile

Features:
- Bill **verification before payment**
- **Auto-populated bill amounts**
- **Insufficient balance protection**

---

### 🎨 Theme Support
- Light mode
- Dark mode
- Persistent theme preference
- **Gold themed UI**

---

### ⚙️ Settings
- Toggle **dark mode**
- Save login credentials
- Customer support info
- Secure logout

---

### 🗺️ Location Services
- Integrated **Google Maps**
- Bank location marker at:

**Arfa Software Technology Park, Lahore**

---

# 🧰 Tech Stack

### Frontend
- **Flutter (Dart)**

### Backend
- **Firebase**

Services used:
- Firebase Authentication
- Cloud Firestore

### State Management
- **Provider Pattern**
- Custom `AppState` class

### Local Storage
- **SharedPreferences**

### Maps
- **Google Maps Flutter**

---

# 📦 Dependencies

```yaml
firebase_core
firebase_auth
cloud_firestore
google_maps_flutter
shared_preferences
📁 Project Structure
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── SavingsGoal.dart
│   └── TransactionRecord.dart
├── services/
│   ├── AuthService.dart
│   └── PreferencesService.dart
├── screens/
│   ├── AuthWrapper.dart
│   ├── SignupScreen.dart
│   ├── LoginScreen.dart
│   ├── DashboardScreen.dart
│   ├── DepositScreen.dart
│   ├── TransferScreen.dart
│   ├── TransactionSuccessScreen.dart
│   ├── VirtualCreditCardScreen.dart
│   ├── PayBillsScreen.dart
│   ├── SavingsScreen.dart
│   ├── TransactionHistoryScreen.dart
│   ├── AccountScreen.dart
│   ├── MapScreen.dart
│   └── SettingsScreen.dart
└── app_state.dart
🔥 Firebase Firestore Structure
users/{userId}
│
├── uid
├── username
├── email
├── accountNumber
├── balance
├── cardNumber
├── cvv
├── expiryDate
├── createdAt
│
└── transactions/{transactionId}
    ├── id
    ├── date
    ├── amount
    ├── to
    ├── from
    ├── type
    └── memo

savings_goals/{goalId}
│
├── id
├── name
├── targetAmount
├── currentAmount
├── createdAt
└── isCompleted

bills/{billId}
│
├── type
├── id
├── amount
└── description
⚙️ Installation
1️⃣ Clone the repository
git clone https://github.com/yourusername/quadbank.git
cd quadbank
2️⃣ Install dependencies
flutter pub get
3️⃣ Firebase Setup

Create a Firebase project at
https://console.firebase.google.com

Enable Email/Password Authentication

Create Cloud Firestore Database

Download configuration files:

Android

android/app/google-services.json

iOS

ios/Runner/GoogleService-Info.plist
4️⃣ Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    match /bills/{document} {
      allow read: if request.auth != null;
    }
  }
}
5️⃣ Run the application
flutter run
🧪 Sample Firestore Data
Electricity Bill
{
  "type": "Electricity",
  "id": "ELEC001",
  "amount": 2500,
  "description": "Monthly electricity bill - May 2024"
}
Water Bill
{
  "type": "Water",
  "id": "WATER001",
  "amount": 1200,
  "description": "Quarterly water supply charges"
}
Internet Bill
{
  "type": "Internet",
  "id": "NET001",
  "amount": 3500,
  "description": "Fiber broadband - Monthly subscription"
}
🔒 Security Features

Firebase Authentication

Auto logout when app pauses

Password reset support

Secure credential storage using SharedPreferences

Firestore access control rules
