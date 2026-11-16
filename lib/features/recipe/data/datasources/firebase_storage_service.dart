/// Firebase Storage service for uploading ingredient photos.
///
/// This service handles uploading images to Firebase Cloud Storage
/// under the /fridge_snaps/{userId}/{timestamp}.jpg path structure.
/// It provides upload progress tracking and returns the authenticated
/// public URL of the uploaded image.
library;

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Firebase Storage service for image uploads.
///
/// Provides methods to upload ingredient photos to Firebase Cloud Storage
/// and retrieve their public URLs. All methods throw [AppException] on failure.
class FirebaseStorageService {
  final FirebaseStorage _storage;
  final String _userId;

  FirebaseStorageService({
    required FirebaseStorage storage,
    required String userId,
  })  : _storage = storage,
        _userId = userId;

  /// Uploads an image file to Firebase Storage.
  ///
  /// [file] - The image file to upload (from image_picker)
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns the authenticated public HTTP URL of the uploaded image.
  ///
  /// Throws [FileSystemException] if file operations fail.
  /// Throws [NetworkException] if upload fails due to network issues.
  /// Throws [ServerException] if Firebase Storage returns an error.
  Future<String> uploadIngredientPhoto(
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file size
      final fileSize = await file.length();
      if (fileSize > AppConstants.maxImageSizeBytes) {
        throw const FileSystemException(
          message: 'File size exceeds maximum limit of '
              '${AppConstants.maxImageSizeBytes ~/ (1024 * 1024)}MB',
          code: 'file_too_large',
        );
      }

      // Validate file format
      final extension = file.path.split('.').last.toLowerCase();
      if (!AppConstants.supportedImageFormats.contains(extension)) {
        throw FileSystemException(
          message: 'Unsupported image format: $extension. '
              'Supported formats: ${AppConstants.supportedImageFormats.join(", ")}',
          code: 'unsupported_format',
        );
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_$extension';
      final filePath =
          '${AppConstants.firebaseFridgeSnapsPath}/$_userId/$fileName';

      // Get reference to the file location
      final ref = _storage.ref().child(filePath);

      // Convert XFile to File for upload
      final fileData = await File(file.path).readAsBytes();

      // Create upload task with metadata
      final uploadTask = ref.putData(
        fileData,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'uploaded_by': _userId,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress.isNaN ? 0.0 : progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Check for upload errors
      if (snapshot.state != TaskState.success) {
        throw ServerException(
          message: 'Upload failed with state: ${snapshot.state}',
        );
      }

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FileSystemException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Firebase Storage error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error during upload: $e');
    }
  }

  /// Deletes an image from Firebase Storage.
  ///
  /// [imageUrl] - The public URL of the image to delete
  ///
  /// Throws [ServerException] if deletion fails.
  /// Throws [NetworkException] if network error occurs.
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract the path from the URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Firebase Storage deletion error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error during deletion: $e');
    }
  }

  /// Gets the download URL for a file path.
  ///
  /// [filePath] - The storage path of the file
  ///
  /// Returns the authenticated public URL.
  ///
  /// Throws [ServerException] if URL retrieval fails.
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Firebase Storage error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error getting URL: $e');
    }
  }
}
