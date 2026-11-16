/// Global Riverpod provider for Firebase Storage initialization.
///
/// This provider manages the Firebase Storage instance and provides
/// it throughout the application using Riverpod's dependency injection.
/// The storage is initialized with environment configuration from EnvConfig.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Provider for Firebase Storage instance.
///
/// This provider provides access to the Firebase Storage instance.
/// Firebase is initialized in main.dart as a non-blocking service.
/// Configuration is sourced from EnvConfig with runtime fallbacks.
///
/// Usage:
/// ```dart
/// final storage = ref.watch(firebaseStorageProvider);
/// final ref = storage.ref().child('path/to/file');
/// ```
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  // Firebase is initialized in main.dart as a non-blocking service
  // This provider simply provides access to the initialized instance
  return FirebaseStorage.instance;
});

/// Provider for Firebase Storage reference to the fridge snaps folder.
///
/// This provider returns a reference to the specific folder where
/// ingredient photos are stored (/fridge_snaps).
///
/// Usage:
/// ```dart
/// final folderRef = ref.watch(fridgeSnapsFolderProvider);
/// final fileRef = folderRef.child('image.jpg');
/// ```
final fridgeSnapsFolderProvider = Provider<Reference>((ref) {
  final storage = ref.read(firebaseStorageProvider);
  return storage.ref().child('fridge_snaps');
});
