import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Immutable data model representing the signed-in user's profile and role.
///
/// **Purpose:**
/// Stores user identity fields (`id`, `email`, `fullName`, `phone`,
/// `avatarUrl`) and their permission `role` (`'user'` or `'admin'`).
class Profile {
  /// Unique user identifier matching `auth.users.id` in Supabase.
  final String id;

  /// The user's email address.
  final String email;

  /// Optional full name of the user.
  final String? fullName;

  /// Optional phone number of the user.
  final String? phone;

  /// Optional short biography.
  final String? bio;

  /// Optional public URL for the user's avatar image in Supabase Storage.
  final String? avatarUrl;

  /// Permission role: `'user'` (browse/attend) or `'admin'` (create events).
  final String role;

  /// Account creation timestamp.
  final DateTime? createdAt;

  /// Creates an immutable [Profile] instance.
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

  /// Whether this user currently has Admin privileges.
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Friendly name to display in greetings (falls back to `'Explorer'`).
  String get displayName =>
      (fullName?.trim().isNotEmpty ?? false) ? fullName!.trim() : 'Explorer';

  /// Single uppercase initial used in avatar placeholders when [avatarUrl] is `null`.
  String get initial => (fullName?.trim().isNotEmpty ?? false)
      ? fullName!.trim()[0].toUpperCase()
      : (email.isNotEmpty ? email[0].toUpperCase() : '?');

  /// Creates a copy of this [Profile] with specified fields updated.
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

  /// Constructs a [Profile] from a Supabase Auth [User] object's metadata.
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

/// Manages the signed-in user's [Profile], role switching, and avatar uploads.
///
/// **Purpose:**
/// Provides user profile data and role state (`User` vs `Admin`) to the Home
/// header, Drawer, Events page, and Profile editor screen.
///
/// **How it works:**
/// Reads initial metadata from `Supabase.auth.currentUser`, then fetches the
/// authoritative row from `public.profiles`. When the user edits their name,
/// phone, or role, it updates local state immediately and syncs with Supabase.
class ProfileProvider extends ChangeNotifier {
  /// Controller for the Display Name field on the Profile tab.
  final TextEditingController nameController = TextEditingController();

  /// Controller for the read-only Email field on the Profile tab.
  final TextEditingController emailController = TextEditingController();

  /// Controller for the Phone Number field on the Profile tab.
  final TextEditingController phoneController = TextEditingController();

  Profile? _profile;
  bool _isLoading = false;

  /// Creates a [ProfileProvider] and initializes from the active Supabase session.
  ProfileProvider() {
    // Initialize synchronously from current session without calling notifyListeners during build
    final user = _client.auth.currentUser;
    if (user != null) {
      _profile = Profile.fromUser(user);
      _syncControllers();
      Future.microtask(_fetchRemoteProfileRow);
    }
  }

  /// The currently loaded user [Profile], or `null` if signed out.
  Profile? get profile => _profile;

  /// Whether a profile save or avatar upload is in progress.
  bool get isLoading => _isLoading;

  /// Whether the current user has `'admin'` permissions.
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

  // Copies the current Profile values into the TextEditingControllers so the
  // ProfilePage form displays them.
  void _syncControllers() {
    nameController.text = _profile?.fullName ?? '';
    emailController.text = _profile?.email ?? '';
    phoneController.text = _profile?.phone ?? '';
  }

  // Fetches the user's row from `public.profiles` in Supabase to sync their
  // database role, bio, and avatar URL.
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

  /// Loads the user profile from the current Supabase session and `public.profiles` table.
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

  /// Populates a temporary local [Profile] when the device is offline.
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

  /// Clears the current profile and resets form controllers on sign-out.
  void clearProfile() {
    _profile = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    _safeNotify();
  }

  /// Saves edited name and phone values to both local state and Supabase.
  ///
  /// **Purpose:**
  /// Persists changes made on the Profile tab when the user taps "Save Profile".
  ///
  /// **How it works:**
  /// 1. Immediately updates `_profile` in memory so the UI reflects the new
  ///    name right away.
  /// 2. Updates `auth.users` metadata and upserts the `public.profiles` row in
  ///    Supabase.
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

  /// Switches the user's active role between `'user'` and `'admin'`.
  ///
  /// **Purpose:**
  /// Lets you test both User permissions (browsing/booking) and Admin
  /// permissions (creating events) with a single tap.
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

  /// Picks an image from the device gallery and uploads it to Supabase Storage.
  ///
  /// **Purpose:**
  /// Updates the user's profile picture when they tap their avatar on the
  /// Profile screen.
  ///
  /// **How it works:**
  /// 1. Opens the gallery via [ImagePicker].
  /// 2. Uploads the compressed JPEG binary to the `avatars` bucket in Supabase.
  /// 3. Saves the public URL to the user's profile metadata.
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
