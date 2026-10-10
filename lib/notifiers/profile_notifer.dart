import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.createdAt,
  });

  // Built straight from the auth user object
  factory Profile.fromUser(User user) {
    final meta = user.userMetadata ?? {};
    return Profile(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String?,
      phone: meta['phone'] as String?,
      bio: meta['bio'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}

final ValueNotifier<Profile?> profileNotifier = ValueNotifier<Profile?>(null);
final ValueNotifier<bool> profileLoadingNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);

SupabaseClient get _client => Supabase.instance.client;

// No network call needed: the user object is already on the device
void loadProfile() {
  final user = _client.auth.currentUser;
  profileNotifier.value = user == null ? null : Profile.fromUser(user);
}

void clearProfile() {
  profileNotifier.value = null;
  editModeNotifier.value = false;
}

Future<void> updateProfile({
  required String fullName,
  required String phone,
  required String? bio,
}) async {
  profileLoadingNotifier.value = true;
  try {
    final res = await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, 'phone': phone, 'bio': bio}),
    );
    if (res.user != null) {
      profileNotifier.value = Profile.fromUser(res.user!);
    }
  } finally {
    profileLoadingNotifier.value = false;
  }
}

Future<void> uploadAvatar() async {
  final user = _client.auth.currentUser;
  if (user == null) return;

  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    imageQuality: 80,
  );
  if (picked == null) return;

  profileLoadingNotifier.value = true;
  try {
    final bytes = await picked.readAsBytes();
    final path = '${user.id}/avatar.jpg';

    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpg',
          ),
        );

    final url =
        '${_client.storage.from('avatars').getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

    final res = await _client.auth.updateUser(
      UserAttributes(data: {'avatar_url': url}),
    );
    if (res.user != null) {
      profileNotifier.value = Profile.fromUser(res.user!);
    }
  } finally {
    profileLoadingNotifier.value = false;
  }
}
