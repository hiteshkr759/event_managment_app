import 'package:flutter/material.dart';

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
  final String location;
  final String distance;
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

const List<EventAttendee> defaultSampleAttendees = <EventAttendee>[
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

const List<EventItem> initialSeedEvents = <EventItem>[
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
    isFeatured: true,
    icon: Icons.palette_rounded,
    gradientColors: <Color>[Color(0xFF004D40), Color(0xFF009688)],
  ),
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
    isNearby: true,
    icon: Icons.library_music_rounded,
    gradientColors: <Color>[Color(0xFF37474F), Color(0xFF78909C)],
  ),
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
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
    attendeeList: defaultSampleAttendees,
    icon: Icons.lightbulb_outline_rounded,
    gradientColors: <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
];

