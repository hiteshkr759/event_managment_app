import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  String get displayName =>
      (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : 'Explorer';

  String get initial => (fullName?.trim().isNotEmpty ?? false)
      ? fullName!.trim()[0].toUpperCase()
      : (email.isNotEmpty ? email[0].toUpperCase() : '?');

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

class ProfileProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Profile? _profile;
  bool _isLoading = false;

  ProfileProvider() {
    // Initialize synchronously from current session without calling notifyListeners during build
    final user = _client.auth.currentUser;
    if (user != null) {
      _profile = Profile.fromUser(user);
      _syncControllers();
      Future.microtask(_fetchRemoteProfileRow);
    }
  }

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAdmin => _profile?.isAdmin ?? false;

  SupabaseClient get _client => Supabase.instance.client;

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  void _syncControllers() {
    nameController.text = _profile?.fullName ?? '';
    emailController.text = _profile?.email ?? '';
    phoneController.text = _profile?.phone ?? '';
  }

  Future<void> _fetchRemoteProfileRow() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      final row = await _client
          .from('profiles')
          .select('role, full_name, phone, bio, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        _profile = Profile(
          id: user.id,
          email: user.email ?? '',
          fullName: (row['full_name'] as String?) ?? _profile?.fullName,
          phone: (row['phone'] as String?) ?? _profile?.phone,
          bio: (row['bio'] as String?) ?? _profile?.bio,
          avatarUrl: (row['avatar_url'] as String?) ?? _profile?.avatarUrl,
          role: ((row['role'] as String?) ?? _profile?.role ?? 'user')
              .toLowerCase(),
          createdAt: DateTime.tryParse(user.createdAt),
        );
        _syncControllers();
        _safeNotify();
      }
    } catch (_) {}
  }

  Future<void> loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      clearProfile();
      return;
    }

    _profile = Profile.fromUser(user);
    _syncControllers();
    _safeNotify();
    await _fetchRemoteProfileRow();
  }

  void setOfflineProfile({
    required String email,
    String? fullName,
    String? phone,
    String role = 'user',
  }) {
    final derivedName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : email.split('@').first;
    _profile = Profile(
      id: 'offline-${email.hashCode}',
      email: email,
      fullName: derivedName,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );
    _syncControllers();
    _safeNotify();
  }

  void clearProfile() {
    _profile = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    _safeNotify();
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    _safeNotify();

    final fullName = nameController.text.trim();
    final phone = phoneController.text.trim();
    final currentRole = _profile?.role ?? 'user';

    // Update local profile immediately so UI works even when offline
    if (_profile != null) {
      _profile = _profile!.copyWith(
        fullName: fullName,
        phone: phone,
        role: currentRole,
      );
      _syncControllers();
    }

    try {
      final user = _client.auth.currentUser;
      if (user != null) {
        final res = await _client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': fullName,
              'phone': phone,
              'bio': _profile?.bio,
              'role': currentRole,
            },
          ),
        );
        if (res.user != null) {
          _profile = Profile.fromUser(res.user!, overrideRole: currentRole);
          _syncControllers();
        }
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'full_name': fullName,
          'phone': phone,
          'bio': _profile?.bio,
          'role': currentRole,
        });
      }
    } catch (_) {
      // Ignore network/DNS errors when offline; local profile state is already updated
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> updateRole(String newRole) async {
    if (_profile == null) return;
    final normalized = newRole.toLowerCase() == 'admin' ? 'admin' : 'user';
    _profile = _profile!.copyWith(role: normalized);
    _safeNotify();

    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'role': normalized}),
      );
    } catch (_) {}

    try {
      await _client
          .from('profiles')
          .update({'role': normalized})
          .eq('id', _profile!.id);
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

    _isLoading = true;
    _safeNotify();
    try {
      final bytes = await picked.readAsBytes();
      final path = '${user.id}/avatar.jpg';

      await _client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpg'),
      );

      final url =
          '${_client.storage.from('avatars').getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

      final res = await _client.auth.updateUser(
        UserAttributes(data: {'avatar_url': url}),
      );
      if (res.user != null) {
        _profile = Profile.fromUser(res.user!, overrideRole: _profile?.role);
      }
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
