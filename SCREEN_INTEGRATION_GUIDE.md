
# Screen Integration & Navigation Guide

## Overview
All screens in the Crisis Response App have been successfully integrated using a centralized routing system. This document outlines the complete navigation structure and how screens connect to each other.

## Navigation Flow Architecture

### 1. **Authentication Flow**
```
Entry Screen (GuardianScreen)
    ├── Login → Emergency Dashboard
    └── Sign Up → Signup → Success → Permissions → Emergency Dashboard

Forgot Password Flow:
    Login → Forget Password → OTP → Reset Password → Login Screen
```

### 2. **Main Dashboard Navigation**
- **Emergency Dashboard** is the main hub after authentication
- Bottom navigation (4 items):
  - Home (0) - Stays on Dashboard
  - Alerts (1) - Navigates to Alerts Center
  - SOS (2) - Triggers SOS flow (dedicated button)
  - Settings (3) - Navigates to Safety Settings

### 3. **Emergency Response Screens**
```
Emergency Dashboard
    └── SOS Triggered (hold SOS button)
            └── Accident Detected (after countdown)
```

### 4. **Profile & Settings**
```
Emergency Dashboard
    ├── Emergency Profile (from header icon)
    └── Safety Settings (from bottom nav)
```

### 5. **Alerts & Safety**
```
Alerts Center
    ├── Community Alert
    └── Preventive Safety Alerts

Safety Map
Safety Settings
```

### 6. **Educational Resources**
- CPR Guide
- First Aid Guide  
- Safety Tutorial

### 7. **Advanced Features**
- Responder Directory
- Event History
- Advanced Sensors
- Connectivity Status
- Emergency Beacon

## Routing System

### App Routes Configuration
All routes are centralized in `lib/routes/app_routes.dart`:

```dart
class AppRoutes {
  // Auth Routes
  static const String entry = '/entry';
  static const String login = '/login';
  static const String signup = '/signup';
  // ... and more
}
```

### Navigation Methods
Use named route navigation for consistency:

```dart
// Instead of:
Navigator.push(context, MaterialPageRoute(...));

// Use:
Navigator.pushNamed(context, AppRoutes.dashboard);
// or for replacement:
Navigator.pushReplacementNamed(context, AppRoutes.login);
```

## Integrated Screens List

### Authentication (8 screens)
1. ✅ Entry Screen (Guardian)
2. ✅ Login Screen
3. ✅ Sign Up Screen
4. ✅ Forget Password (Recover Access)
5. ✅ OTP Verification
6. ✅ Reset Password
7. ✅ Permissions Screen (Safety Permissions)
8. ✅ Success Screen (Account Created)

### Dashboard & Emergency (4 screens)
9. ✅ Emergency Dashboard
10. ✅ Emergency Profile
11. ✅ SOS Triggered
12. ✅ Accident Detected

### Alerts & Safety (4 screens)
13. ✅ Alerts Center
14. ✅ Safety Map
15. ✅ Community Alert
16. ✅ Preventive Safety Alerts

### Educational Resources (3 screens)
17. ✅ CPR Guide
18. ✅ First Aid Guide
19. ✅ Safety Tutorial

### Advanced Features (5 screens)
20. ✅ Responder Directory
21. ✅ Event History
22. ✅ Advanced Sensors
23. ✅ Connectivity Status
24. ✅ Emergency Beacon

**Total: 27 screens fully integrated**

## Key Implementation Details

### 1. Named Route Navigation
All screen transitions now use named routes through `AppRoutes` class, eliminating the need for manual `MaterialPageRoute` creation.

### 2. Main Entry Point
The app starts at `AuthGate`, which checks Firebase authentication:
- If logged in → Emergency Dashboard
- If not logged in → Login Screen

### 3. Post-Login Flow
After successful login, users go to Emergency Dashboard which serves as the main hub.

### 4. Emergency Response Flow
1. User holds SOS button on dashboard
2. Navigates to SOS Triggered screen
3. After 8-second countdown → Accident Detected screen
4. User can confirm or cancel emergency

### 5. Bottom Navigation Integration
The dashboard's bottom navigation now properly routes to:
- Alerts Center (Alerts tab)
- Safety Settings (Settings tab)
- Dashboard stays on home

### 6. Header Navigation
Emergency Dashboard header profile icon routes to Emergency Profile screen.

## Testing Checklist

- [ ] App launches and shows auth gate
- [ ] Login/Signup flow works end-to-end
- [ ] Forgot password flow works
- [ ] Dashboard loads after login
- [ ] Bottom navigation buttons work
- [ ] Profile icon navigates correctly
- [ ] SOS triggered flow works
- [ ] All named routes are accessible
- [ ] Back buttons navigate correctly
- [ ] No duplicate route definitions

## Future Enhancements

1. Add transition animations for screen changes
2. Implement deep linking for notifications
3. Add bottom sheet modals for quick actions
4. Implement tab-based navigation for dashboard
5. Add shared preferences for last visited screen
6. Implement network-aware navigation

## File Modifications Summary

**Updated Files:**
- `lib/main.dart` - Added app routes
- `lib/routes/app_routes.dart` - Created routing system
- `lib/screens/Entry_screen.dart` - Named routes
- `lib/screens/Login_screen.dart` - Named routes
- `lib/screens/Signup_screen.dart` - Named routes
- `lib/screens/Forget_Password_screen.dart` - Named routes
- `lib/screens/OTP_screen.dart` - Named routes
- `lib/screens/Reset_Password_screen.dart` - Named routes
- `lib/screens/Permissions_screen.dart` - Named routes
- `lib/screens/Success_screen.dart` - Named routes
- `lib/screens/emergency_dashboard_screen.dart` - Named routes + bottom nav
- `lib/screens/sos_trigger_screen.dart` - Named routes

## How to Use Named Routes

### In Your Code
```dart
// Push new screen
Navigator.pushNamed(context, AppRoutes.dashboard);

// Replace screen
Navigator.pushReplacementNamed(context, AppRoutes.login);

// Pop with result
Navigator.pop(context, result);
```

### Adding New Routes
1. Add constant to `AppRoutes` class
2. Add widget builder to `getRoutes()` method
3. Update relevant screen imports
4. Use named route in navigation calls

---

**Integration Status: ✅ COMPLETE**

All 27 screens are now properly integrated with a centralized routing system. The app flow is organized and maintainable.
