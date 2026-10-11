import 'package:flutter/material.dart';

/// Represents a single user who has registered to attend an event.
///
/// **Purpose:**
/// Holds display details (name, email, avatar, and registration status) for
/// each person shown in the "Registered Attendees" bottom sheet.
class EventAttendee {
  /// The unique user ID (UUID from Supabase `auth.users` / `public.profiles`).
  final String id;

  /// The display name of the attendee.
  final String name;

  /// The email address of the attendee.
  final String email;

  /// Optional URL pointing to the attendee's profile picture.
  final String? avatarUrl;

  /// Human-readable label showing when the user registered (e.g., `'Just now'`).
  final String registeredAtLabel;

  /// Creates an immutable [EventAttendee] record.
  const EventAttendee({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.registeredAtLabel = 'Registered recently',
  });
}

/// Immutable data model representing an event in Eventora.
///
/// **Purpose:**
/// Stores all details needed to render an event card, carousel banner, or
/// details sheet (both **Offline** in-person events and **Online** virtual
/// events), and provides helper methods to convert between Dart objects and
/// Supabase PostgreSQL rows.
///
/// **How it works:**
/// Because all fields are `final`, an [EventItem] cannot be mutated in place.
/// When attendance changes in the UI, [copyWith] creates an updated copy while
/// keeping all other fields untouched.
class EventItem {
  /// Unique identifier (`id` primary key from `public.events`).
  final String id;

  /// Display title of the event.
  final String title;

  /// Event category (e.g., `'Tech'`, `'Music'`, `'Art'`, `'Sports'`).
  final String category;

  /// Delivery mode of the event (`'offline'` for in-person or `'online'`).
  final String eventMode;

  /// Formatted date string shown in the UI (e.g., `'Apr 18, 2026'`).
  final String date;

  /// Formatted time string shown in the UI (e.g., `'10:00 AM'`).
  final String time;

  /// Physical venue name (for offline events) or platform label (for online).
  final String location;

  /// Distance label (e.g., `'2.4 km away'`) or `'Online Event'`.
  final String distance;

  /// Streaming/meeting platform name when [isOnline] is `true`.
  final String? onlinePlatform;

  /// Join URL when [isOnline] is `true`.
  final String? meetingUrl;

  /// Formatted price badge (e.g., `'Free'` or `'\$49'`).
  final String price;

  /// Full text description shown in the event details sheet.
  final String description;

  /// Banner image URL displayed on cards and headers.
  final String imageUrl;

  /// Total number of people attending this event.
  final int attendees;

  /// List of registered users for this event.
  final List<EventAttendee> attendeeList;

  /// Whether this event is highlighted in the "Featured Events" carousel.
  final bool isFeatured;

  /// Whether this event belongs to the "Events Near Me" section.
  final bool isNearby;

  /// Fallback category icon used if the network image fails to load.
  final IconData icon;

  /// Fallback gradient colors matched to [category].
  final List<Color> gradientColors;

  /// Creates an immutable [EventItem].
  const EventItem({
    required this.id,
    required this.title,
    required this.category,
    this.eventMode = 'offline',
    required this.date,
    required this.time,
    required this.location,
    required this.distance,
    this.onlinePlatform,
    this.meetingUrl,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.attendees,
    this.attendeeList = const <EventAttendee>[],
    this.isFeatured = false,
    this.isNearby = false,
    required this.icon,
    required this.gradientColors,
  });

  /// Whether this event takes place online rather than at a physical venue.
  bool get isOnline => eventMode.toLowerCase() == 'online';

  /// Checks whether the user with [userId] is already in [attendeeList].
  ///
  /// **Purpose:**
  /// Determines whether the event details button should show "Book / Attend"
  /// or "Attending ✓ (Tap to Cancel)".
  bool isUserAttending(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return attendeeList.any((a) => a.id == userId);
  }

  /// Creates a new [EventItem] with updated [attendees] or [attendeeList].
  ///
  /// **Purpose:**
  /// Supports immutable state updates in `EventsProvider` when a user joins or
  /// leaves an event.
  EventItem copyWith({
    int? attendees,
    List<EventAttendee>? attendeeList,
  }) {
    return EventItem(
      id: id,
      title: title,
      category: category,
      eventMode: eventMode,
      date: date,
      time: time,
      location: location,
      distance: distance,
      onlinePlatform: onlinePlatform,
      meetingUrl: meetingUrl,
      price: price,
      description: description,
      imageUrl: imageUrl,
      attendees: attendees ?? this.attendees,
      attendeeList: attendeeList ?? this.attendeeList,
      isFeatured: isFeatured,
      isNearby: isNearby,
      icon: icon,
      gradientColors: gradientColors,
    );
  }

  /// Returns the default `(icon, gradientColors, bannerUrl)` tuple for [category].
  ///
  /// **Purpose:**
  /// Assigns consistent visual styling (icon, gradient, and fallback Unsplash
  /// photo) based on the event's category using Dart 3's `switch` expression
  /// and Record return type `(IconData, List<Color>, String)`.
  static (IconData, List<Color>, String) styleForCategory(String category) {
    return switch (category) {
      'Tech' => (
        Icons.code_rounded,
        const <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop&q=80',
      ),
      'Music' => (
        Icons.music_note_rounded,
        const <Color>[Color(0xFF00838F), Color(0xFF4DD0E1)],
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&auto=format&fit=crop&q=80',
      ),
      'Workshops' => (
        Icons.design_services_rounded,
        const <Color>[Color(0xFF00796B), Color(0xFF4DB6AC)],
        'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&auto=format&fit=crop&q=80',
      ),
      'Business' => (
        Icons.handshake_rounded,
        const <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
        'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&auto=format&fit=crop&q=80',
      ),
      'Sports' => (
        Icons.directions_run_rounded,
        const <Color>[Color(0xFF1B5E20), Color(0xFF4CAF50)],
        'https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?w=800&auto=format&fit=crop&q=80',
      ),
      _ => (
        Icons.palette_rounded,
        const <Color>[Color(0xFF004D40), Color(0xFF009688)],
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800&auto=format&fit=crop&q=80',
      ),
    };
  }

  /// Converts this [EventItem] into a JSON map matching the Supabase `public.events` table.
  ///
  /// **Purpose:**
  /// Serializes a Dart [EventItem] into database column names so it can be
  /// inserted into Supabase when an Admin creates a new event.
  ///
  /// **How it works:**
  /// Maps Dart properties to PostgreSQL snake_case columns (`organizer_id`,
  /// `event_mode`, `starts_at`, `venue_name`, `meeting_url`, etc.) and ensures
  /// the database `valid_event_mode_fields` check constraint is satisfied.
  Map<String, dynamic> toSupabaseMap(String organizerId) {
    final online = isOnline;
    final numericPrice =
        double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final free = price.trim().toLowerCase() == 'free' || numericPrice == 0.0;

    return <String, dynamic>{
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'category': category,
      'event_mode': online ? 'online' : 'offline',
      'starts_at': _parseStartsAtIso(date, time),
      'venue_name': online ? null : (location.isNotEmpty ? location : 'TBA Venue'),
      'address': online ? null : distance,
      'city': isNearby ? 'nearby' : 'standard',
      'online_platform': online ? (onlinePlatform ?? 'Online Platform') : null,
      'meeting_url': online
          ? (meetingUrl != null && meetingUrl!.isNotEmpty
                ? meetingUrl
                : 'https://meet.google.com')
          : null,
      'is_free': free,
      'price': free ? 0 : numericPrice,
      'max_capacity': attendees,
      'is_featured': isFeatured,
      'banner_url': imageUrl,
    };
  }

  /// Builds an [EventItem] from a Supabase `public.events` row and joined `event_registrations`.
  ///
  /// **Purpose:**
  /// Deserializes raw JSON maps returned by `Supabase.from('events').select(...)`
  /// into strongly-typed Dart [EventItem] objects for the UI.
  ///
  /// **How it works:**
  /// 1. Extracts category styling (`icon`, `gradientColors`, fallback banner).
  /// 2. Parses `starts_at` ISO timestamp into readable `date` and `time` strings.
  /// 3. Loops over nested `event_registrations` rows (joined with `profiles`)
  ///    to build the live [attendeeList] and calculate total [attendees].
  factory EventItem.fromSupabaseMap(Map<String, dynamic> row) {
    final category = (row['category'] as String?) ?? 'Tech';
    final (icon, colors, defaultBanner) = styleForCategory(category);
    final mode = ((row['event_mode'] as String?) ?? 'offline').toLowerCase();
    final online = mode == 'online';

    final startsAtRaw = row['starts_at'] as String?;
    final startsAt = startsAtRaw != null
        ? DateTime.tryParse(startsAtRaw)?.toLocal()
        : null;
    final (formattedDate, formattedTime) = _formatDateTime(startsAt);

    final isFree = (row['is_free'] as bool?) ?? true;
    final rawPrice = row['price'];
    final numPrice = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);
    final priceLabel = (isFree || numPrice <= 0)
        ? 'Free'
        : '\$${numPrice % 1 == 0 ? numPrice.toInt() : numPrice.toStringAsFixed(2)}';

    final venueName = (row['venue_name'] as String?)?.trim() ?? '';
    final address = (row['address'] as String?)?.trim() ?? '';
    final platform = (row['online_platform'] as String?)?.trim();
    final locationLabel = online
        ? '${(platform != null && platform.isNotEmpty) ? platform : 'Virtual'} (Online)'
        : (venueName.isNotEmpty ? venueName : 'TBA');
    final distanceLabel = online
        ? 'Online Event'
        : (address.isNotEmpty ? address : '1.5 km away');

    // Parse joined event_registrations if present
    final regList = <EventAttendee>[];
    final rawRegs = row['event_registrations'];
    if (rawRegs is List) {
      for (final item in rawRegs) {
        if (item is Map<String, dynamic>) {
          final profileMap = item['profiles'] as Map<String, dynamic>?;
          final uid =
              (item['user_id'] as String?) ??
              (profileMap?['id'] as String?) ??
              'user';
          final fullName = (profileMap?['full_name'] as String?)?.trim();
          final email = (profileMap?['email'] as String?)?.trim() ?? '';
          regList.add(
            EventAttendee(
              id: uid,
              name: (fullName != null && fullName.isNotEmpty)
                  ? fullName
                  : (email.isNotEmpty ? email.split('@').first : 'Attendee'),
              email: email,
              avatarUrl: profileMap?['avatar_url'] as String?,
              registeredAtLabel: 'Registered',
            ),
          );
        }
      }
    }

    final baseCount = (row['max_capacity'] as int?) ?? 0;
    final totalAttendees = baseCount + regList.length;

    final cityTag = (row['city'] as String?)?.toLowerCase();
    final isFeatured = (row['is_featured'] as bool?) ?? false;
    final isNearby = cityTag == 'nearby';

    return EventItem(
      id: row['id'].toString(),
      title: (row['title'] as String?) ?? 'Untitled Event',
      category: category,
      eventMode: online ? 'online' : 'offline',
      date: formattedDate,
      time: formattedTime,
      location: locationLabel,
      distance: distanceLabel,
      onlinePlatform: platform,
      meetingUrl: row['meeting_url'] as String?,
      price: priceLabel,
      description: (row['description'] as String?) ?? '',
      imageUrl: (row['banner_url'] as String?)?.isNotEmpty == true
          ? row['banner_url'] as String
          : defaultBanner,
      attendees: totalAttendees,
      attendeeList: regList,
      isFeatured: isFeatured,
      isNearby: isNearby,
      icon: icon,
      gradientColors: colors,
    );
  }

  static String _parseStartsAtIso(String dateStr, String timeStr) {
    const months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    try {
      final cleanedDate = dateStr.replaceAll(',', '').trim();
      final dateParts = cleanedDate.split(RegExp(r'\s+'));
      int month = 10;
      int day = 24;
      int year = 2026;
      if (dateParts.length >= 3) {
        final mKey = dateParts[0].toLowerCase();
        month =
            months[mKey.length >= 3 ? mKey.substring(0, 3) : mKey] ?? 10;
        day = int.tryParse(dateParts[1]) ?? 24;
        year = int.tryParse(dateParts[2]) ?? 2026;
      }

      int hour = 18;
      int minute = 0;
      final cleanedTime = timeStr.trim().toUpperCase();
      final timeMatch = RegExp(
        r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
      ).firstMatch(cleanedTime);
      if (timeMatch != null) {
        hour = int.tryParse(timeMatch.group(1)!) ?? 18;
        minute = int.tryParse(timeMatch.group(2)!) ?? 0;
        final period = timeMatch.group(3);
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }

      return DateTime(year, month, day, hour, minute).toUtc().toIso8601String();
    } catch (_) {
      return DateTime.now().toUtc().toIso8601String();
    }
  }

  static (String, String) _formatDateTime(DateTime? dt) {
    if (dt == null) return ('Nov 15, 2026', '06:00 PM');
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final dateLabel = '$month $day, ${dt.year}';

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hourPadded = hour12.toString().padLeft(2, '0');
    final minPadded = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeLabel = '$hourPadded:$minPadded $period';

    return (dateLabel, timeLabel);
  }
}

const List<String> eventCategories = <String>[
  'All',
  'Tech',
  'Music',
  'Workshops',
  'Business',
  'Sports',
  'Art',
];

const List<String> eventModeFilters = <String>[
  'All',
  'Offline',
  'Online',
  'Featured',
  'Nearby',
];

