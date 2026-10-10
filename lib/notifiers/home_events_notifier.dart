import 'package:event_managment_app/notifiers/event_notifer.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventAttendee {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String registeredAtLabel;

  const EventAttendee({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.registeredAtLabel = 'Registered recently',
  });
}

class EventItem {
  final String id;
  final String title;
  final String category;
  final String eventMode; // 'offline' or 'online'
  final String date;
  final String time;
  final String location; // Venue/City for offline, or Platform for online
  final String distance; // e.g. '1.2 km away' or 'Online Event'
  final String? onlinePlatform;
  final String? meetingUrl;
  final String price;
  final String description;
  final String imageUrl;
  final int attendees;
  final List<EventAttendee> attendeeList;
  final bool isFeatured;
  final bool isNearby;
  final IconData icon;
  final List<Color> gradientColors;

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

  bool get isOnline => eventMode.toLowerCase() == 'online';

  bool isUserAttending(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return attendeeList.any((a) => a.id == userId);
  }

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

// Home page notifiers
final ValueNotifier<String> selectedCategoryNotifier = ValueNotifier<String>(
  'All',
);
final ValueNotifier<String> searchQueryNotifier = ValueNotifier<String>('');
final ValueNotifier<int> featuredPageNotifier = ValueNotifier<int>(0);

// All Events page notifiers
final ValueNotifier<String> allEventsSearchNotifier = ValueNotifier<String>('');
final ValueNotifier<String> allEventsCategoryNotifier = ValueNotifier<String>(
  'All',
);
final ValueNotifier<String> allEventsModeFilterNotifier = ValueNotifier<String>(
  'All',
);

// Create Event page notifiers (keeps CreateEventPage a StatelessWidget)
final ValueNotifier<String> createEventModeNotifier = ValueNotifier<String>(
  'offline',
);
final ValueNotifier<String> createEventCategoryNotifier = ValueNotifier<String>(
  'Tech',
);
final ValueNotifier<bool> createEventIsFreeNotifier = ValueNotifier<bool>(true);
final ValueNotifier<bool> createEventIsFeaturedNotifier = ValueNotifier<bool>(
  false,
);
final ValueNotifier<bool> createEventLoadingNotifier = ValueNotifier<bool>(
  false,
);

// Sample attendees shown in the "View Attendees" modal
const List<EventAttendee> _defaultSampleAttendees = <EventAttendee>[
  EventAttendee(
    id: 'sample-u1',
    name: 'Aarav Sharma',
    email: 'aarav.sharma@example.com',
    registeredAtLabel: '2 days ago',
  ),
  EventAttendee(
    id: 'sample-u2',
    name: 'Priya Patel',
    email: 'priya.patel@example.com',
    registeredAtLabel: 'Yesterday',
  ),
  EventAttendee(
    id: 'sample-u3',
    name: 'Rohan Verma',
    email: 'rohan.verma@example.com',
    registeredAtLabel: '5 hours ago',
  ),
  EventAttendee(
    id: 'sample-u4',
    name: 'Sneha Nair',
    email: 'sneha.nair@example.com',
    registeredAtLabel: '1 hour ago',
  ),
];

const List<EventItem> _sampleFeaturedEvents = <EventItem>[
  EventItem(
    id: 'feat-1',
    title: 'Flutter Forward Global Summit',
    category: 'Tech',
    eventMode: 'offline',
    date: 'Oct 24, 2026',
    time: '09:30 AM',
    location: 'Grand Convention Center',
    distance: '2.4 km away',
    price: 'Free',
    description:
        'Join developers and designers for keynotes, live demos, and hands-on sessions covering the latest in Flutter & Dart.',
    imageUrl:
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop&q=80',
    attendees: 420,
    attendeeList: _defaultSampleAttendees,
    isFeatured: true,
    icon: Icons.code_rounded,
    gradientColors: <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
  ),
  EventItem(
    id: 'feat-2',
    title: 'Sunset Indie Music Festival',
    category: 'Music',
    eventMode: 'offline',
    date: 'Nov 02, 2026',
    time: '05:00 PM',
    location: 'Riverside Amphitheater',
    distance: '4.1 km away',
    price: '\$35',
    description:
        'An open-air evening of live indie bands, acoustic sets, food trucks, and immersive light installations.',
    imageUrl:
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&auto=format&fit=crop&q=80',
    attendees: 850,
    attendeeList: _defaultSampleAttendees,
    isFeatured: true,
    icon: Icons.music_note_rounded,
    gradientColors: <Color>[Color(0xFF00838F), Color(0xFF4DD0E1)],
  ),
  EventItem(
    id: 'feat-3',
    title: 'Global AI & Product Design Keynote',
    category: 'Business',
    eventMode: 'online',
    onlinePlatform: 'Zoom Webinar',
    meetingUrl: 'https://zoom.us/j/ai-product-expo',
    date: 'Nov 12, 2026',
    time: '10:00 AM',
    location: 'Zoom Webinar (Online)',
    distance: 'Online Event',
    price: 'Free',
    description:
        'Explore how generative AI is transforming product design workflows with industry leaders and startup founders.',
    imageUrl:
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80',
    attendees: 310,
    attendeeList: _defaultSampleAttendees,
    isFeatured: true,
    icon: Icons.auto_awesome_rounded,
    gradientColors: <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
  EventItem(
    id: 'feat-4',
    title: 'Modern Digital Art Biennale',
    category: 'Art',
    eventMode: 'offline',
    date: 'Nov 18, 2026',
    time: '11:00 AM',
    location: 'Metropolitan Art Gallery',
    distance: '5.5 km away',
    price: '\$20',
    description:
        'Interactive projection mapping, generative sculptures, and talks with contemporary digital artists.',
    imageUrl:
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800&auto=format&fit=crop&q=80',
    attendees: 195,
    attendeeList: _defaultSampleAttendees,
    isFeatured: true,
    icon: Icons.palette_rounded,
    gradientColors: <Color>[Color(0xFF004D40), Color(0xFF009688)],
  ),
];

const List<EventItem> _sampleNearbyEvents = <EventItem>[
  EventItem(
    id: 'near-1',
    title: 'UI/UX Prototyping Bootcamp',
    category: 'Workshops',
    eventMode: 'offline',
    date: 'Oct 15, 2026',
    time: '02:00 PM',
    location: 'CoWork Studio, Sector 4',
    distance: '0.8 km away',
    price: 'Free',
    description:
        'A practical afternoon workshop on building responsive design systems and interactive prototypes.',
    imageUrl:
        'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&auto=format&fit=crop&q=80',
    attendees: 64,
    attendeeList: _defaultSampleAttendees,
    isNearby: true,
    icon: Icons.design_services_rounded,
    gradientColors: <Color>[Color(0xFF00796B), Color(0xFF4DB6AC)],
  ),
  EventItem(
    id: 'near-2',
    title: 'Startup Founders Mixer',
    category: 'Business',
    eventMode: 'offline',
    date: 'Oct 18, 2026',
    time: '06:30 PM',
    location: 'The Terrace Lounge',
    distance: '1.2 km away',
    price: '\$15',
    description:
        'Connect with local entrepreneurs, angel investors, and builders over coffee and lightning pitches.',
    imageUrl:
        'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&auto=format&fit=crop&q=80',
    attendees: 112,
    attendeeList: _defaultSampleAttendees,
    isNearby: true,
    icon: Icons.handshake_rounded,
    gradientColors: <Color>[Color(0xFF006064), Color(0xFF26C6DA)],
  ),
  EventItem(
    id: 'near-3',
    title: 'City Night 5K Community Run',
    category: 'Sports',
    eventMode: 'offline',
    date: 'Oct 20, 2026',
    time: '07:00 PM',
    location: 'Central Park North Gate',
    distance: '1.5 km away',
    price: 'Free',
    description:
        'Lace up for a friendly 5K evening run through the city park followed by refreshments and music.',
    imageUrl:
        'https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?w=800&auto=format&fit=crop&q=80',
    attendees: 240,
    attendeeList: _defaultSampleAttendees,
    isNearby: true,
    icon: Icons.directions_run_rounded,
    gradientColors: <Color>[Color(0xFF1B5E20), Color(0xFF4CAF50)],
  ),
  EventItem(
    id: 'near-4',
    title: 'Acoustic Jazz & Open Mic',
    category: 'Music',
    eventMode: 'offline',
    date: 'Oct 22, 2026',
    time: '08:00 PM',
    location: 'Blue Note Cafe',
    distance: '1.9 km away',
    price: '\$10',
    description:
        'Intimate live jazz performances and open mic slots for local vocalists and instrumentalists.',
    imageUrl:
        'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800&auto=format&fit=crop&q=80',
    attendees: 88,
    attendeeList: _defaultSampleAttendees,
    isNearby: true,
    icon: Icons.library_music_rounded,
    gradientColors: <Color>[Color(0xFF37474F), Color(0xFF78909C)],
  ),
];

const List<EventItem> _sampleUpcomingEvents = <EventItem>[
  EventItem(
    id: 'up-1',
    title: 'Cloud Native & Supabase Live Stream',
    category: 'Tech',
    eventMode: 'online',
    onlinePlatform: 'Google Meet',
    meetingUrl: 'https://meet.google.com/sup-cloud-live',
    date: 'Oct 26, 2026',
    time: '04:00 PM',
    location: 'Google Meet (Online)',
    distance: 'Online Event',
    price: 'Free',
    description:
        'Deep dive into real-time Postgres, Edge Functions, and scalable authentication patterns.',
    imageUrl:
        'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800&auto=format&fit=crop&q=80',
    attendees: 150,
    attendeeList: _defaultSampleAttendees,
    icon: Icons.cloud_done_rounded,
    gradientColors: <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
  ),
  EventItem(
    id: 'up-2',
    title: 'Creative Photography Walk',
    category: 'Art',
    eventMode: 'offline',
    date: 'Oct 29, 2026',
    time: '06:00 AM',
    location: 'Old Town Heritage Square',
    distance: '2.7 km away',
    price: '\$12',
    description:
        'Capture golden-hour street and architectural photography guided by professional mentors.',
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop&q=80',
    attendees: 45,
    attendeeList: _defaultSampleAttendees,
    icon: Icons.camera_alt_rounded,
    gradientColors: <Color>[Color(0xFF00838F), Color(0xFF26C6DA)],
  ),
  EventItem(
    id: 'up-3',
    title: 'Product Management Masterclass',
    category: 'Workshops',
    eventMode: 'online',
    onlinePlatform: 'YouTube Live',
    meetingUrl: 'https://youtube.com/live/pm-masterclass',
    date: 'Nov 05, 2026',
    time: '11:00 AM',
    location: 'YouTube Live (Online)',
    distance: 'Online Event',
    price: '\$25',
    description:
        'Learn user discovery, roadmap prioritization, and metrics that matter from senior PMs.',
    imageUrl:
        'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&auto=format&fit=crop&q=80',
    attendees: 95,
    attendeeList: _defaultSampleAttendees,
    icon: Icons.lightbulb_outline_rounded,
    gradientColors: <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
];

final ValueNotifier<List<EventItem>> featuredEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleFeaturedEvents);

final ValueNotifier<List<EventItem>> nearbyEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleNearbyEvents);

final ValueNotifier<List<EventItem>> upcomingEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleUpcomingEvents);

final ValueNotifier<List<EventItem>> allEventsListNotifier =
    ValueNotifier<List<EventItem>>(<EventItem>[
      ..._sampleFeaturedEvents,
      ..._sampleNearbyEvents,
      ..._sampleUpcomingEvents,
    ]);

/// Navigates to the All Events tab with a specific mode filter pre-selected.
void openAllEventsPage({String modeFilter = 'All'}) {
  allEventsModeFilterNotifier.value = modeFilter;
  eventNotifier.value = 1;
}

/// Filters events for the Home Page sections.
List<EventItem> filterEventsByCategory(
  List<EventItem> events,
  String category, {
  String searchQuery = '',
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();
  return events.where((event) {
    final matchesCategory = category == 'All' || event.category == category;
    final matchesQuery =
        normalizedQuery.isEmpty ||
        event.title.toLowerCase().contains(normalizedQuery) ||
        event.location.toLowerCase().contains(normalizedQuery) ||
        event.category.toLowerCase().contains(normalizedQuery);
    return matchesCategory && matchesQuery;
  }).toList();
}

/// Filters the exhaustive list on the All Events Page by mode, category, and search.
List<EventItem> filterAllEvents({
  required List<EventItem> events,
  required String modeFilter,
  required String category,
  required String searchQuery,
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();
  return events.where((event) {
    final matchesMode = switch (modeFilter) {
      'Offline' => !event.isOnline,
      'Online' => event.isOnline,
      'Featured' => event.isFeatured,
      'Nearby' => event.isNearby || !event.isOnline,
      _ => true,
    };
    final matchesCategory = category == 'All' || event.category == category;
    final matchesQuery =
        normalizedQuery.isEmpty ||
        event.title.toLowerCase().contains(normalizedQuery) ||
        event.location.toLowerCase().contains(normalizedQuery) ||
        event.category.toLowerCase().contains(normalizedQuery) ||
        event.eventMode.toLowerCase().contains(normalizedQuery);
    return matchesMode && matchesCategory && matchesQuery;
  }).toList();
}

/// Toggles the current user's registration for [event], updating the live count
/// and attendee list across all screens and syncing with Supabase.
Future<bool> toggleEventRegistration(EventItem event) async {
  final profile = profileNotifier.value;
  final userId =
      profile?.id ??
      Supabase.instance.client.auth.currentUser?.id ??
      'guest-user';
  final userName = (profile?.fullName?.trim().isNotEmpty ?? false)
      ? profile!.fullName!.trim()
      : (profile?.email.isNotEmpty ?? false ? profile!.email : 'You');
  final userEmail = profile?.email ?? 'you@example.com';

  final alreadyAttending = event.isUserAttending(userId);

  final updatedAttendeeList = alreadyAttending
      ? event.attendeeList.where((a) => a.id != userId).toList()
      : <EventAttendee>[
          EventAttendee(
            id: userId,
            name: userName,
            email: userEmail,
            avatarUrl: profile?.avatarUrl,
            registeredAtLabel: 'Just now',
          ),
          ...event.attendeeList,
        ];

  final updatedCount = alreadyAttending
      ? (event.attendees > 0 ? event.attendees - 1 : 0)
      : event.attendees + 1;

  final updatedEvent = event.copyWith(
    attendees: updatedCount,
    attendeeList: updatedAttendeeList,
  );

  List<EventItem> replaceInList(List<EventItem> list) {
    return list.map((item) => item.id == event.id ? updatedEvent : item).toList();
  }

  allEventsListNotifier.value = replaceInList(allEventsListNotifier.value);
  featuredEventsNotifier.value = replaceInList(featuredEventsNotifier.value);
  nearbyEventsNotifier.value = replaceInList(nearbyEventsNotifier.value);
  upcomingEventsNotifier.value = replaceInList(upcomingEventsNotifier.value);

  // Sync with Supabase event_registrations table if present
  try {
    final client = Supabase.instance.client;
    if (alreadyAttending) {
      await client
          .from('event_registrations')
          .delete()
          .match({'event_id': event.id, 'user_id': userId});
    } else {
      await client.from('event_registrations').insert({
        'event_id': event.id,
        'user_id': userId,
      });
    }
  } catch (_) {
    // Graceful fallback if table is not created yet
  }

  return !alreadyAttending;
}

/// Creates a new Offline or Online event (Admin action) and adds it to the app state & Supabase.
Future<EventItem> createNewEvent({
  required String title,
  required String category,
  required String eventMode, // 'offline' or 'online'
  required String date,
  required String time,
  required String description,
  required bool isFree,
  required String priceText,
  required bool isFeatured,
  String? venueName,
  String? cityAndAddress,
  String? onlinePlatform,
  String? meetingUrl,
  String? imageUrl,
}) async {
  createEventLoadingNotifier.value = true;
  try {
    final isOnline = eventMode.toLowerCase() == 'online';
    final formattedPrice = isFree
        ? 'Free'
        : (priceText.trim().startsWith('\$')
              ? priceText.trim()
              : '\$${priceText.trim()}');

    final locationDisplay = isOnline
        ? '${onlinePlatform?.trim().isNotEmpty == true ? onlinePlatform!.trim() : 'Virtual'} (Online)'
        : [
            if (venueName != null && venueName.trim().isNotEmpty)
              venueName.trim(),
            if (cityAndAddress != null && cityAndAddress.trim().isNotEmpty)
              cityAndAddress.trim(),
          ].join(', ');

    final (icon, colors, defaultBanner) = _styleForCategory(category);
    final profile = profileNotifier.value;

    final newEvent = EventItem(
      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      category: category,
      eventMode: isOnline ? 'online' : 'offline',
      date: date.trim(),
      time: time.trim(),
      location: locationDisplay.isEmpty ? 'TBA' : locationDisplay,
      distance: isOnline ? 'Online Event' : '1.0 km away',
      onlinePlatform: isOnline ? onlinePlatform?.trim() : null,
      meetingUrl: isOnline ? meetingUrl?.trim() : null,
      price: formattedPrice,
      description: description.trim(),
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl.trim()
          : defaultBanner,
      attendees: 1,
      attendeeList: <EventAttendee>[
        EventAttendee(
          id: profile?.id ?? 'organizer',
          name: (profile?.fullName?.trim().isNotEmpty ?? false)
              ? '${profile!.fullName!.trim()} (Host)'
              : 'Admin Host',
          email: profile?.email ?? 'admin@example.com',
          avatarUrl: profile?.avatarUrl,
          registeredAtLabel: 'Organizer',
        ),
      ],
      isFeatured: isFeatured,
      isNearby: !isOnline,
      icon: icon,
      gradientColors: colors,
    );

    // Prepend to all lists so it appears immediately
    allEventsListNotifier.value = <EventItem>[
      newEvent,
      ...allEventsListNotifier.value,
    ];
    if (isFeatured) {
      featuredEventsNotifier.value = <EventItem>[
        newEvent,
        ...featuredEventsNotifier.value,
      ];
    }
    if (!isOnline) {
      nearbyEventsNotifier.value = <EventItem>[
        newEvent,
        ...nearbyEventsNotifier.value,
      ];
    } else {
      upcomingEventsNotifier.value = <EventItem>[
        newEvent,
        ...upcomingEventsNotifier.value,
      ];
    }

    // Also try inserting into Supabase 'events' table if configured
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user != null) {
        await client.from('events').insert({
          'organizer_id': user.id,
          'title': newEvent.title,
          'description': newEvent.description,
          'category': newEvent.category,
          'event_mode': newEvent.eventMode,
          'starts_at': DateTime.now().toIso8601String(),
          'venue_name': isOnline ? null : venueName?.trim(),
          'address': isOnline ? null : cityAndAddress?.trim(),
          'online_platform': isOnline ? onlinePlatform?.trim() : null,
          'meeting_url': isOnline ? meetingUrl?.trim() : null,
          'is_free': isFree,
          'price': isFree
              ? 0
              : (double.tryParse(priceText.replaceAll('\$', '').trim()) ?? 0),
          'is_featured': isFeatured,
          'banner_url': newEvent.imageUrl,
        });
      }
    } catch (_) {
      // Graceful fallback when running with local state before SQL migration
    }

    return newEvent;
  } finally {
    createEventLoadingNotifier.value = false;
  }
}

(IconData, List<Color>, String) _styleForCategory(String category) {
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