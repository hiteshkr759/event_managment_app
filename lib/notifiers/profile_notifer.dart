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
  final String role; // 'user' or 'admin'
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.role = 'user',
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  Profile copyWith({
    String? fullName,
    String? phone,
    String? bio,
    String? avatarUrl,
    String? role,
  }) {
    return Profile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }

  // Built straight from the auth user object (with role fallback)
  factory Profile.fromUser(User user, {String? overrideRole}) {
    final meta = user.userMetadata ?? {};
    final resolvedRole =
        overrideRole ?? (meta['role'] as String?)?.toLowerCase() ?? 'user';
    return Profile(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String?,
      phone: meta['phone'] as String?,
      bio: meta['bio'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
      role: resolvedRole == 'admin' ? 'admin' : 'user',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}

final ValueNotifier<Profile?> profileNotifier = ValueNotifier<Profile?>(null);
final ValueNotifier<bool> profileLoadingNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);

SupabaseClient get _client => Supabase.instance.client;

Future<void> loadProfile() async {
  final user = _client.auth.currentUser;
  if (user == null) {
    profileNotifier.value = null;
    return;
  }

  // Set immediately from local session metadata
  profileNotifier.value = Profile.fromUser(user);

  // Also try fetching role from public.profiles table if it exists in Supabase
  try {
    final row = await _client
        .from('profiles')
        .select('role, full_name, phone, bio, avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    if (row != null) {
      profileNotifier.value = Profile(
        id: user.id,
        email: user.email ?? '',
        fullName:
            (row['full_name'] as String?) ?? profileNotifier.value?.fullName,
        phone: (row['phone'] as String?) ?? profileNotifier.value?.phone,
        bio: (row['bio'] as String?) ?? profileNotifier.value?.bio,
        avatarUrl:
            (row['avatar_url'] as String?) ?? profileNotifier.value?.avatarUrl,
        role: ((row['role'] as String?) ?? profileNotifier.value?.role ?? 'user')
            .toLowerCase(),
        createdAt: DateTime.tryParse(user.createdAt),
      );
    }
  } catch (_) {
    // Table may not be created yet; keep metadata-based profile
  }
}

void clearProfile() {
  profileNotifier.value = null;
  editModeNotifier.value = false;
}

Future<void> updateProfile({
  required String fullName,
  required String phone,
  required String? bio,
  String? role,
}) async {
  profileLoadingNotifier.value = true;
  try {
    final nextRole = role ?? profileNotifier.value?.role ?? 'user';
    final res = await _client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName,
          'phone': phone,
          'bio': bio,
          'role': nextRole,
        },
      ),
    );
    if (res.user != null) {
      profileNotifier.value = Profile.fromUser(
        res.user!,
        overrideRole: nextRole,
      );
    }
    try {
      final user = _client.auth.currentUser;
      if (user != null) {
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'full_name': fullName,
          'phone': phone,
          'bio': bio,
          'role': nextRole,
        });
      }
    } catch (_) {
      // Ignore if public.profiles table does not exist yet
    }
  } finally {
    profileLoadingNotifier.value = false;
  }
}

Future<void> updateUserRole(String newRole) async {
  final current = profileNotifier.value;
  if (current == null) return;
  final normalized = newRole.toLowerCase() == 'admin' ? 'admin' : 'user';
  profileNotifier.value = current.copyWith(role: normalized);

  try {
    await _client.auth.updateUser(
      UserAttributes(data: {'role': normalized}),
    );
  } catch (_) {}

  try {
    await _client
        .from('profiles')
        .update({'role': normalized})
        .eq('id', current.id);
  } catch (_) {}
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
      profileNotifier.value = Profile.fromUser(
        res.user!,
        overrideRole: profileNotifier.value?.role,
      );
    }
  } finally {
    profileLoadingNotifier.value = false;
  }
}
