# Kisan Mitra 

A comprehensive Flutter mobile application designed to empower Indian farmers with real-time agricultural information, market intelligence, and government schemes data.

## ?? Screenshots

| Market Prices | Home Screen | Crop Info | 
|---|---|---|
| ![Market Prices](images/market_prices.jpg) | ![Home Screen](images/home_screen.jpg) | ![Crop Info](images/crop_info.jpg) |

## ?? Features

### ?? Real-Time Market Prices
- Live commodity prices from India's official data.gov.in API
- Filter by state and market
- Track price trends across different markets
- Support for multiple crops (Rice, Paddy, Maize, Cotton, Tomato, Chilli, etc.)

### ??? Weather Forecasting
- Location-based weather updates using geolocation
- Current temperature and conditions
- Daily forecasts for agricultural planning
- Automatic caching for offline access
- Smart alerts for weather-related farming activities

### ?? Crop Information
- Comprehensive crop database with details
- Growing duration and water requirements
- Seasonal crop recommendations
- Filter by crop type (Kharif, Rabi, Vegetables)
- High-resolution crop images

### ?? Voice Integration
- Speech-to-text for hands-free operation
- Text-to-speech for accessibility
- Multilingual support (English, Telugu)
- Perfect for farmers with limited literacy

### ?? Government Schemes
- Information about agricultural subsidies
- Eligibility criteria and benefits
- Application procedures
- Updated scheme database

### ??? Buy/Sell Marketplace
- Direct trading platform for farmers
- Product listings and negotiations
- Secure transactions
- Community-driven commerce

### ?? User Profile Management
- Personal farmer profiles
- Preferences and settings
- Language selection
- Notification management

### ?? Offline Support
- Cached market data
- Stored weather forecasts
- Previous session data retention
- Seamless online/offline transition

## ??? Technical Stack

- **Framework**: Flutter 3.41.6
- **Language**: Dart 3.11.4
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **API Integration**: HTTP
- **Database**: Firebase Firestore (planned)
- **Location Services**: Geolocator
- **UI Components**: Lottie animations, FL Chart, Google Fonts
- **Voice**: Flutter TTS, Speech to Text
- **Image Handling**: Image Picker

## ?? Key Dependencies

- provider: ^6.1.1
- http: ^1.1.0
- shared_preferences: ^2.2.2
- lottie: ^2.7.0
- fl_chart: ^0.66.0
- google_fonts: ^6.1.0
- geolocator: ^13.0.0
- flutter_tts: ^3.8.5
- speech_to_text: ^7.0.0

## ?? Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.11+
- Git

### Installation

`ash
git clone https://github.com/subbu-1985/Kisan_mitra.git
cd Kisan_mitra
flutter pub get
flutter run
`

## ?? Supported Platforms
- ? Android
- ? iOS
- ? Web
- ? Windows
- ? macOS
- ? Linux

## ??? Project Structure

`
lib/
+-- main.dart
+-- screens/                  # 11 main screens
+-- services/                 # API and business logic
+-- providers/                # State management
+-- utils/                    # Utilities and helpers
`

## ?? Security Notice

?? **Important**: API keys should never be hardcoded. For production:
- Move API keys to environment variables
- Use secure configuration management
- Implement backend API gateway

## ?? API Integrations

1. **data.gov.in**: Agricultural commodity prices
2. **Open-Meteo**: Weather data and forecasts
3. **Firebase**: User authentication and database (optional)

## ?? UI/UX Features

- Intuitive farmer-friendly interface
- Multilingual support (English, Telugu)
- Voice commands and text-to-speech
- Responsive design for all screen sizes
- Offline-first architecture

## ?? Support & Features

- Real-time market prices
- Weather forecasting
- Crop information database
- Government schemes information
- Buy/Sell marketplace
- Voice assistance
- Multi-language support

## ?? Contributing

Contributions welcome! Follow standard Git workflow:
1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push and create Pull Request

## ?? Authors

- **Developer**: Subbu
- **Project**: Kisan Mitra (Farmer's Friend)

## ?? Version

- **v1.0.0** - Initial Release
  - Real-time market price tracking
  - Weather forecasting
  - Crop information
  - Voice assistance
  - Government schemes
  - Buy/Sell marketplace

## ?? Roadmap

- [ ] Firebase integration
- [ ] User authentication
- [ ] Payment gateway
- [ ] ML-based crop yield predictions
- [ ] Pest detection system
- [ ] Community forums
- [ ] Expert consultation

---

**Made with ?? for Indian Farmers** ??
