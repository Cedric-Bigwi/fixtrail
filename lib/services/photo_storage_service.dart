import 'dart:typed_data';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, FileOptions;
import '../core/constants.dart';

/// Uploads/deletes incident photos. The backend is chosen with
/// AppConstants.useSupabaseStorage (Supabase = free, Firebase = needs Blaze).
/// Only the resulting public URL is stored in the Firestore report.
class PhotoStorageService {
  static const _supabaseMarker = '/storage/v1/object/public/';

  String _fileName() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 30)}.jpg';

  Future<String> upload(Uint8List bytes, String uid) async {
    final path = '$uid/${_fileName()}';
    if (AppConstants.useSupabaseStorage) {
      final bucket = Supabase.instance.client.storage.from(AppConstants.supabaseBucket);
      await bucket.uploadBinary(path, bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false));
      return bucket.getPublicUrl(path);
    }
    final ref = FirebaseStorage.instance.ref('incident_photos/$path');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> delete(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      if (url.contains(_supabaseMarker)) {
        if (!AppConstants.useSupabaseStorage) return;
        final prefix = '$_supabaseMarker${AppConstants.supabaseBucket}/';
        final urlPath = Uri.parse(url).path;
        final i = urlPath.indexOf(prefix);
        if (i < 0) return;
        final objectPath = Uri.decodeComponent(urlPath.substring(i + prefix.length));
        await Supabase.instance.client.storage
            .from(AppConstants.supabaseBucket)
            .remove([objectPath]);
      } else {
        await FirebaseStorage.instance.refFromURL(url).delete();
      }
    } catch (_) {
      // Already gone or not permitted - the report deletion should still succeed.
    }
  }
}
