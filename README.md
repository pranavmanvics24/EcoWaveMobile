# 🌊 EcoWave: Ride the Wave of Sustainability

EcoWave is a community-driven marketplace designed to make sustainable living effortless and accessible. Built with **Flutter**, **Flask**, and **MongoDB**, it allows users to buy, sell, and track the environmental impact of their second-hand goods in real-time.

---

## 🚀 The Vision
Every item we reuse is a win for the planet. EcoWave doesn't just facilitate transactions; it calculates the **CO₂ saved**, **water conserved**, and **waste diverted** for every product listed. We believe that by visualizing our collective impact, we can inspire a global shift toward circular consumption.

---

## ✨ Key Features

### 🛒 Smarter Marketplace
- **Category-Based Browsing:** Find everything from eco-friendly electronics to upcycled clothing.
- **Eco-Impact Badges:** Every product shows exactly how much CO₂ and water you're saving by buying used.
- **Pin Your Location:** Sellers can drop a GPS pin to show where the item is for local pickups.

### 💬 Seamless Communication
- **Real-Time Chat:** Powered by Socket.IO for instant negotiation between buyers and sellers.
- **Offline Notifications:** If you're away, EcoWave sends an automated email (SMTP) to let you know a buyer is waiting.

### 💳 Secure Payments
- **Razorpay Integration:** Support for all major UPI apps (GPay, PhonePe, Paytm), Cards, and Netbanking.
- **Verified Transactions:** Server-side signature verification ensures every payment is legitimate before marking items as sold.

### 🗺️ Visual Discovery
- **Google Maps Integration:** View product locations on a map to find the best deals in your neighborhood.

---

## 🛠️ Tech Stack

- **Frontend:** [Flutter](https://flutter.dev) + [Provider](https://pub.dev/packages/provider) (State Management) + [GoRouter](https://pub.dev/packages/go_router)
- **Backend:** [Flask](https://flask.palletsprojects.com/) (Python)
- **Database:** [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- **Real-time:** [Socket.IO](https://socket.io/)
- **Payments:** [Razorpay](https://razorpay.com/)
- **Maps:** [Google Maps SDK](https://developers.google.com/maps)

---

## ⚙️ Quick Start

### 1. Prerequisites
- Flutter SDK (Latest)
- Python 3.10+
- MongoDB Atlas Account

### 2. Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```
Create a `.env` file in the `/backend` folder and add:
```env
MONGODB_URI=your_mongodb_uri
SECRET_KEY=your_jwt_secret
SMTP_EMAIL=your_email
SMTP_PASSWORD=your_app_password
RAZORPAY_KEY_ID=your_razorpay_id
RAZORPAY_KEY_SECRET=your_razorpay_secret
```
Run it:
```bash
python main.py
```

### 3. Frontend Setup
```bash
# Install dependencies
flutter pub get

# Add your API Keys:
# 1. Google Maps: android/app/src/main/AndroidManifest.xml
# 2. Razorpay: lib/screens/marketplace_screen.dart

flutter run
```

---

## 🌿 Contribution
We're riding the wave toward a cleaner future. If you have ideas for better impact tracking or new features, feel free to fork and submit a PR!

**EcoWave** — *Better for your pocket, better for the planet.* 🌎
