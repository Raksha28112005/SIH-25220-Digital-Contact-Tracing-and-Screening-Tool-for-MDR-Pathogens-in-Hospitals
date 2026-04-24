import 'package:flutter/material.dart';

enum UserRole {
  doctor,
  nurse,
}

extension UserRoleExtension on UserRole {
  /// Converts enum to lowercase string for DB / API usage
  String get value {
    switch (this) {
      case UserRole.doctor:
        return "doctor";
      case UserRole.nurse:
        return "nurse";
    }
  }

  /// Human-friendly names for UI
  String get label {
    switch (this) {
      case UserRole.doctor:
        return "Doctor";
      case UserRole.nurse:
        return "Nurse";
    }
  }

  /// Role-specific icons
  IconData get icon {
    switch (this) {
      case UserRole.doctor:
        return Icons.medical_services_rounded;
      case UserRole.nurse:
        return Icons.healing_rounded;
    }
  }

  /// Colors for UI (soft orange/green/blue theme)
  Color get color {
    switch (this) {
      case UserRole.doctor:
        return Colors.blueAccent.shade200; // doctor color
      case UserRole.nurse:
        return Colors.greenAccent.shade400; // nurse color
    }
  }

  /// Parse string → UserRole (safe)
  static UserRole? fromString(String s) {
    switch (s.toLowerCase()) {
      case "doctor":
        return UserRole.doctor;
      case "nurse":
        return UserRole.nurse;
      default:
        return null;
    }
  }
}
