# 💰 Borrow Manager

A Flutter app to track money you **lend** and **borrow** — with real local storage, per-client balances, and due-date reminders.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter) ![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart) ![SQLite](https://img.shields.io/badge/Database-SQLite-green?logo=sqlite) ![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📱 Screenshots
<img width="200" height="450" alt="Screenshot_1788895700" src="https://github.com/user-attachments/assets/340f3262-e12b-49a1-81bc-c33d3093e615" />
<img width="200" height="450" alt="Screenshot_1788896142" src="https://github.com/user-attachments/assets/0a210e13-4d9d-4be9-90f1-f027969786cd" />
<img width="200" height="450" alt="Screenshot_1788896221" src="https://github.com/user-attachments/assets/bd4beda9-d0df-4caf-b6c9-8a36d308a687" />
<img width="200" height="450" alt="Screenshot_1788896293" src="https://github.com/user-attachments/assets/77cc7d90-03f6-4fbe-99c6-1fe6e3a11929" />
<img width="200" height="450" alt="Screenshot_1788896303" src="https://github.com/user-attachments/assets/7ac82584-3787-47cd-a306-9be35c83cb75" />
<img width="200" height="450" alt="Screenshot_1788896309" src="https://github.com/user-attachments/assets/0b05f34c-c6bc-4060-b677-d8e966e1ffad" />
<img width="200" height="450" alt="Screenshot_1788896313" src="https://github.com/user-attachments/assets/80702257-d8fb-4e8a-9b56-fef71c4fec3f" />


---

## ✨ Features

- 🔐 Login screen with validation
- 📊 Dashboard with live **Gave / Received / Balance**
- 👥 Add, Edit, Delete clients
- 💸 Record Lend / Borrow with optional note & due date
- 📋 Per-client transaction history
- ✅ Mark transactions as **Settled**
- 🔔 Reminder screen for overdue & today's dues
- 🕐 Recent transactions list
- ⚙️ Settings (currency, language)
- 📦 Local SQLite storage — **no internet needed**

---

## 🗂️ Project Structure

```
lib/
├── main.dart
├── db/
│   └── database_helper.dart
├── models/
│   ├── client.dart
│   └── transaction_entry.dart
└── screens/
    ├── login_screen.dart
    ├── dashboard_screen.dart
    ├── add_client_screen.dart
    ├── manage_clients_screen.dart
    ├── add_entry_screen.dart
    ├── recent_screen.dart
    ├── reminder_screen.dart
    └── settings_screen.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Android Studio / VS Code

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/SachinMugade8797/self_borrow_manager.git
cd self_borrow_manager

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.3.3 | Local SQLite database |
| `path` | ^1.9.0 | DB file path helper |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 🛠️ How It Works

1. **Add a client** (name + phone)
2. **Record a transaction** — select client, enter amount, choose *Gave* or *Received*, set optional due date
3. **Dashboard** auto-calculates your net balance from the database
4. **Reminders** flag any entry whose due date is today or past
5. **Settle** a transaction to exclude it from the balance

---

## 🤝 Contributing

Pull requests are welcome. For major changes, open an issue first.

---

## 📄 License

MIT © [Sachin Mugade](https://github.com/SachinMugade8797)
