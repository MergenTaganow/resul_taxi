# App Logo and Splash Screen

## Instructions

1. Save your taxi service logo image as `taxi_logo.png` in this directory
2. The image should be at least 1024x1024 pixels for best quality
3. The image will be used for:
   - App icon (automatically resized for different platforms)
   - Splash screen (displayed during app loading)

## Image Requirements

- Format: PNG
- Background: Black (to match the app theme)
- Logo: Orange taxi car with "TIZ TAXI" text
- Size: 1024x1024 pixels recommended
- Transparency: Not required (black background is fine)

## File Structure

```
assets/images/
├── taxi_logo.png          # Main logo file (add this)
└── README.md             # This file
```

After adding the image, run:
```bash
flutter pub get
flutter clean
flutter pub get
```

The splash screen will automatically use this logo when the app loads. 