# App Icons and Images

This directory contains the app icons and images used throughout the application.

## Current Icons

- `tiztaxi.png` - Current app icon (will be replaced with new Resul Taxi icon)

## New Resul Taxi Icon Requirements

To complete the app rebranding, please create a new icon file named `resul_taxi_icon.png` with the following specifications:

### Design Specifications
- **Dimensions**: 1024x1024 pixels (square)
- **Format**: PNG with transparency support
- **Background**: Gradient from bright yellow-orange (#FF8C00) at top to deeper orange at bottom
- **Text Elements**:
  - "Resul" in black, bold sans-serif, centered in upper half
  - "TAXI" in black, smaller all-caps, below "Resul"
- **Taxi Car**: Black silhouette, side view, facing right, in lower half
  - Checkered pattern on rear door in orange/black
  - Orange headlights and taillights
  - Subtle shadow beneath
- **Location Pin**: White teardrop shape above car roof
- **Style**: Rounded corners for the square

### Color Palette
- **Primary Orange**: #FF8C00 (Bright Orange)
- **Secondary Black**: #000000
- **Accent White**: #FFFFFF

### Implementation Steps
1. Create the `resul_taxi_icon.png` file with the above specifications
2. Place it in this directory (`assets/images/resul_taxi_icon.png`)
3. Run `fvm flutter pub run flutter_launcher_icons` to generate app icons
4. The app will automatically use the new icon for:
   - Android launcher icon
   - iOS app icon
   - Splash screen
   - Main screen logo

## Usage in Code

The icon is referenced in:
- `pubspec.yaml` - For flutter_launcher_icons configuration
- `lib/presentation/widgets/splash_screen.dart` - Splash screen logo
- `lib/presentation/screens/main_screen.dart` - Main screen logo

## Branding Updates

The app has been rebranded from "Tiz Taxi" to "Resul Taxi" with the following changes:
- App name: "Resul Taxi" (Android and iOS)
- Developer name: "Resul Taxi" (in about dialog)
- Notification titles: "Resul Taxi"
- All UI references updated to reflect new branding 