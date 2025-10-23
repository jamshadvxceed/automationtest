# Myntra Clone - Flutter E-commerce App

A complete Flutter e-commerce application inspired by Myntra, built with GetX state management and featuring a modern, responsive UI.

## 🚀 Features

- **Authentication**: Login/logout with dummy credentials
- **Product Browsing**: Browse products by categories (Men, Women, Kids, Beauty)
- **Search**: Real-time product search functionality
- **Product Details**: Detailed product view with size/color selection
- **Shopping Cart**: Add/remove items, quantity management, price calculation
- **Wishlist**: Save favorite products for later
- **Responsive Design**: Works on both Android and iOS
- **Modern UI**: Clean, Myntra-inspired design with smooth animations

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x+
- **State Management**: GetX
- **UI Components**: Material Design with custom styling
- **Typography**: Google Fonts (Poppins)
- **Images**: Cached Network Images
- **Grid Layout**: Flutter Staggered Grid View

## 📱 App Structure

```
lib/
├── controllers/          # GetX Controllers
│   ├── auth_controller.dart
│   ├── product_controller.dart
│   ├── cart_controller.dart
│   └── wishlist_controller.dart
├── models/              # Data Models
│   └── product_model.dart
├── routes/              # Navigation Routes
│   └── app_routes.dart
├── views/               # UI Screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── wishlist_screen.dart
│   └── profile_screen.dart
├── widgets/             # Reusable Widgets
│   ├── product_card.dart
│   ├── category_chip.dart
│   └── custom_button.dart
├── utils/               # Utilities & Constants
│   ├── app_colors.dart
│   └── dummy_data.dart
└── main.dart           # App Entry Point
```

## 🎯 App Flow

1. **Splash Screen** → Shows app logo for 2 seconds
2. **Login Screen** → Authentication with demo credentials
3. **Home Screen** → Product browsing with bottom navigation
4. **Product Detail** → Detailed product view with cart/wishlist actions
5. **Cart/Wishlist** → Manage selected items
6. **Profile** → User info and app settings

## 🔐 Demo Credentials

- **Email**: user@vxceed.com
- **Password**: password123

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd automationtest
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6                           # State Management
  google_fonts: ^6.2.1                  # Typography
  flutter_staggered_grid_view: ^0.7.0    # Grid Layout
  cached_network_image: ^3.3.1          # Image Caching
  cupertino_icons: ^1.0.8               # iOS Icons
```

## 🎨 UI Guidelines

- **Color Scheme**: Myntra-inspired pink accent (#E91E63)
- **Typography**: Poppins font family
- **Layout**: Card-based design with proper spacing
- **Animations**: Smooth transitions and Hero animations
- **Responsive**: Adapts to different screen sizes

## 📱 Screenshots

The app includes:
- Modern splash screen with animated logo
- Clean login interface with validation
- Product grid with category filtering
- Detailed product views with image gallery
- Shopping cart with quantity controls
- Wishlist management
- User profile with statistics

## 🔄 State Management

Uses GetX for:
- **Reactive State**: Observable variables with automatic UI updates
- **Navigation**: Route management with bindings
- **Dependency Injection**: Controller lifecycle management
- **Snackbars**: User feedback and notifications

## 🎯 Key Features Implementation

### Product Management
- Category-based filtering
- Real-time search
- Favorite/unfavorite functionality
- Product detail navigation

### Shopping Cart
- Add/remove items with size/color selection
- Quantity management
- Price calculation with delivery fees
- Free delivery threshold (₹1999+)

### Wishlist
- Save/remove favorite products
- Move items to cart
- Bulk operations

### User Experience
- Smooth animations and transitions
- Loading states and error handling
- Responsive design patterns
- Intuitive navigation

## 🚀 Future Enhancements

- Backend integration with REST APIs
- User registration and profile management
- Order history and tracking
- Payment gateway integration
- Push notifications
- Social login options
- Product reviews and ratings
- Advanced filtering and sorting

## 📄 License

This project is created for demonstration purposes and showcases Flutter development best practices with GetX state management.
