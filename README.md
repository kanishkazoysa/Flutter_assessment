# Product Catalogue Application 📱✨

A modern, highly polished Flutter application designed to showcase a curated product catalogue with real-time search, category filtering, persistent favourites, interactive product galleries, and full light/dark theme switching.

Built as part of the **Associate Flutter Developer Practical Assessment**.

---

## 🌟 Key Features

- **Product Catalogue Grid**: Responsive 2-column grid layout displaying product images, titles, pricing, ratings, categories, and quick-favourite status.
- **Product Details Screen**: Full-screen view with hero animations, expanded image gallery (interactive 5-thumbnail selector), full product descriptions, and persistent favourite toggle.
- **Real-Time Substring Search**: Instant search filtering as the user types with clean empty state feedback.
- **Category Filtering**: Horizontal category filter chips for quick product filtering (All, Electronics, Jewelery, Men's Clothing, Women's Clothing).
- **Persistent Favourites**: Add/remove products to/from favourites with automatic state synchronization across all screens, persisted locally using `shared_preferences`.
- **Light & Dark Theme Engine**: Full app-wide dynamic theme switching with customized status bar integration, custom search bars, and high-contrast UI components.
- **Loading & Error Handling**: Shimmer/loading spinners, graceful error screens with retry capabilities, and clear empty states.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter (Dart)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Local Persistence**: `shared_preferences`
- **Network Image Caching**: `cached_network_image`
- **Architecture Pattern**: Feature-First Layered Architecture

### Project Folder Structure

```text
lib/
├── app.dart                           # Root MaterialApp & dynamic SystemUiOverlayStyle
├── main.dart                          # App entry point with ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 Light & Dark themes
│   │   └── theme_provider.dart        # Riverpod ThemeMode state notifier
│   └── network/                       # Network client / mock API service
└── features/
    ├── favourites/
    │   └── providers/
    │       └── favourites_provider.dart # Persistent favourites StateNotifier
    └── products/
        ├── models/
        │   └── product.dart           # Product data model
        ├── providers/
        │   ├── product_provider.dart   # Product list & category state
        │   └── search_provider.dart    # Substring search query state
        ├── screens/
        │   ├── product_list_screen.dart # Main catalog screen & floating nav
        │   └── product_detail_screen.dart # Interactive product details
        └── widgets/
            ├── empty_state_widget.dart# Empty search/category view
            ├── error_widget.dart      # Error handling view with retry
            ├── loading_widget.dart    # Loading spinner / shimmer
            └── product_card.dart      # Individual product grid item card
```

---

## 🚀 Setup & Execution Instructions

### Prerequisites
- Flutter SDK (v3.19.0 or higher recommended)
- Dart SDK
- Android Studio / VS Code with Flutter extension
- Connected Android/iOS Device or Emulator

### 1. Install Dependencies
In the project root directory, run:
```bash
flutter pub get
```

### 2. Run the Application
To launch the app in debug mode on a connected device:
```bash
flutter run
```

### 3. Build Production APK
To generate a release APK for testing/submission:
```bash
flutter build apk --release
```
The output APK file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📋 Assessment Criteria Coverage

| Criteria | Implementation Details |
| :--- | :--- |
| **Product List & Details** | Grid layout with `Hero` transition, larger image, full descriptions, pricing, ratings, and category labels. |
| **Substring Search** | Live `searchQueryProvider` matching product titles continuously as user types. |
| **Favourites & Persistence** | Synchronized across list and detail screens, persisted locally using `shared_preferences`. |
| **State Management** | Clean separation of UI and business logic using Riverpod `StateNotifierProvider` and `StateProvider`. |
| **Light/Dark Theme** | App-wide theme with custom status bar overlay brightness and squircle toggle button. |
| **Loading & Error Handling** | Dedicated `LoadingWidget`, `ErrorStateWidget` with retry button, and `EmptyStateWidget`. |

---

## 💭 Assumptions, Challenges & Future Improvements

### Assumptions Made
- Product data is fetched via standard HTTP request (or local mock data fallback) using Fakestore API format.
- Favourites are stored as a set of product IDs locally on the device.

### Challenges Encountered & Solutions
- **Status Bar Visibility in Dark Mode**: Resolved by wrapping the root `MaterialApp` builder with `AnnotatedRegion<SystemUiOverlayStyle>` to dynamically switch status bar icons to white in dark mode.
- **Seamless Image Gallery Interaction**: Added a 5-thumbnail interactive selector on the details screen so users can preview products from multiple cards seamlessly.

### 📝 Development Note regarding Commit History & Author Email
- **Commit History Note**: The git commits for this repository were made from a local environment configured with `kanishka@trbogen.com` (`TGKanishka`), while the repository is hosted under the GitHub account [`kanishkazoysa`](https://github.com/kanishkazoysa). All commits represent the authentic, step-by-step development history of this assessment.

### Future Improvements
- Add Add-to-Cart functionality with item quantity counters and checkout flow.
- Add product sort options (Price Low-to-High, Rating, Alphabetical).
- Implement pull-to-refresh on the product list screen.

---

## 📤 Submission Details

- **GitHub Repository**: [kanishkazoysa/Flutter_assessment](https://github.com/kanishkazoysa/Flutter_assessment)
- **Commit History**: Full commit history preserved intact as requested by assessment instructions.
