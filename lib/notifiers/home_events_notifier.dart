import 'package:flutter/material.dart';

class EventItem {
  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String distance;
  final String price;
  final String description;
  final String imageUrl;
  final int attendees;
  final bool isFeatured;
  final IconData icon;
  final List<Color> gradientColors;

  const EventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.distance,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.attendees,
    this.isFeatured = false,
    required this.icon,
    required this.gradientColors,
  });
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

final ValueNotifier<String> selectedCategoryNotifier = ValueNotifier<String>(
  'All',
);

final ValueNotifier<List<EventItem>> featuredEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleFeaturedEvents);

final ValueNotifier<List<EventItem>> nearbyEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleNearbyEvents);

final ValueNotifier<List<EventItem>> upcomingEventsNotifier =
    ValueNotifier<List<EventItem>>(_sampleUpcomingEvents);

const List<EventItem> _sampleFeaturedEvents = <EventItem>[
  EventItem(
    id: 'feat-1',
    title: 'Flutter Forward Global Summit',
    category: 'Tech',
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
    isFeatured: true,
    icon: Icons.code_rounded,
    gradientColors: <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
  ),
  EventItem(
    id: 'feat-2',
    title: 'Sunset Indie Music Festival',
    category: 'Music',
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
    isFeatured: true,
    icon: Icons.music_note_rounded,
    gradientColors: <Color>[Color(0xFF00838F), Color(0xFF4DD0E1)],
  ),
  EventItem(
    id: 'feat-3',
    title: 'AI & Product Design Expo',
    category: 'Business',
    date: 'Nov 12, 2026',
    time: '10:00 AM',
    location: 'Innovation Hub Downtown',
    distance: '3.0 km away',
    price: '\$49',
    description:
        'Explore how generative AI is transforming product design workflows with industry leaders and startup founders.',
    imageUrl:
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80',
    attendees: 310,
    isFeatured: true,
    icon: Icons.auto_awesome_rounded,
    gradientColors: <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
  EventItem(
    id: 'feat-4',
    title: 'Modern Digital Art Biennale',
    category: 'Art',
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
    icon: Icons.design_services_rounded,
    gradientColors: <Color>[Color(0xFF00796B), Color(0xFF4DB6AC)],
  ),
  EventItem(
    id: 'near-2',
    title: 'Startup Founders Mixer',
    category: 'Business',
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
    icon: Icons.handshake_rounded,
    gradientColors: <Color>[Color(0xFF006064), Color(0xFF26C6DA)],
  ),
  EventItem(
    id: 'near-3',
    title: 'City Night 5K Community Run',
    category: 'Sports',
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
    icon: Icons.directions_run_rounded,
    gradientColors: <Color>[Color(0xFF1B5E20), Color(0xFF4CAF50)],
  ),
  EventItem(
    id: 'near-4',
    title: 'Acoustic Jazz & Open Mic',
    category: 'Music',
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
    icon: Icons.library_music_rounded,
    gradientColors: <Color>[Color(0xFF37474F), Color(0xFF78909C)],
  ),
];

const List<EventItem> _sampleUpcomingEvents = <EventItem>[
  EventItem(
    id: 'up-1',
    title: 'Cloud Native & Supabase Meetup',
    category: 'Tech',
    date: 'Oct 26, 2026',
    time: '04:00 PM',
    location: 'TechPark Auditorium',
    distance: '3.2 km away',
    price: 'Free',
    description:
        'Deep dive into real-time Postgres, Edge Functions, and scalable authentication patterns.',
    imageUrl:
        'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800&auto=format&fit=crop&q=80',
    attendees: 150,
    icon: Icons.cloud_done_rounded,
    gradientColors: <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
  ),
  EventItem(
    id: 'up-2',
    title: 'Creative Photography Walk',
    category: 'Art',
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
    icon: Icons.camera_alt_rounded,
    gradientColors: <Color>[Color(0xFF00838F), Color(0xFF26C6DA)],
  ),
  EventItem(
    id: 'up-3',
    title: 'Product Management Masterclass',
    category: 'Workshops',
    date: 'Nov 05, 2026',
    time: '11:00 AM',
    location: 'Vertex Business Center',
    distance: '4.6 km away',
    price: '\$25',
    description:
        'Learn user discovery, roadmap prioritization, and metrics that matter from senior PMs.',
    imageUrl:
        'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&auto=format&fit=crop&q=80',
    attendees: 95,
    icon: Icons.lightbulb_outline_rounded,
    gradientColors: <Color>[Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
];

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