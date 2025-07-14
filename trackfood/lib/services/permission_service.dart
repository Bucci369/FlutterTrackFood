import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  /// Check if activity recognition permission is granted
  static Future<bool> hasActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS uses different permissions for step counting
      // The pedometer package handles this automatically
      return true;
    }
    return false;
  }

  /// Request activity recognition permission
  static Future<bool> requestActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS permissions are handled by the pedometer package
      return true;
    }
    return false;
  }

  /// Check if sensors permission is granted
  static Future<bool> hasSensorsPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.sensors.status;
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit sensor permission
  }

  /// Request sensors permission
  static Future<bool> requestSensorsPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.sensors.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check all required permissions for step counting
  static Future<bool> hasAllStepCountingPermissions() async {
    final activityRecognition = await hasActivityRecognitionPermission();
    final sensors = await hasSensorsPermission();
    return activityRecognition && sensors;
  }

  /// Request all permissions for step counting
  static Future<bool> requestAllStepCountingPermissions() async {
    final activityRecognition = await requestActivityRecognitionPermission();
    final sensors = await requestSensorsPermission();
    return activityRecognition && sensors;
  }

  /// Open app settings if permissions are permanently denied
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(
    Permission permission,
  ) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Get human-readable permission status
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Erlaubt';
      case PermissionStatus.denied:
        return 'Verweigert';
      case PermissionStatus.restricted:
        return 'Eingeschränkt';
      case PermissionStatus.limited:
        return 'Begrenzt';
      case PermissionStatus.permanentlyDenied:
        return 'Dauerhaft verweigert';
      case PermissionStatus.provisional:
        return 'Vorläufig';
    }
  }
}
