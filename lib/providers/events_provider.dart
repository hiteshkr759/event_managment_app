import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsProvider extends ChangeNotifier {
  List<EventItem> _allEvents = List<EventItem>.from(initialSeedEvents);

  // Home page state & controller
  final TextEditingController homeSearchController = TextEditingController();
  final PageController featuredPageController = PageController(
    viewportFraction: 0.88,
  );
  String _homeCategory = 'All';
  String _homeSearchQuery = '';
  int _featuredPageIndex = 0;

  // All Events page state & controller
  final TextEditingController allSearchController = TextEditingController();
  String _allModeFilter = 'All';
  String _allCategory = 'All';
  String _allSearchQuery = '';

  // Create Event form state & persistent controllers
  final GlobalKey<FormState> createEventFormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: 'Nov 15, 2026',
  );
  final TextEditingController timeController = TextEditingController(
    text: '06:00 PM',
  );
  final TextEditingController venueController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController platformController = TextEditingController(
    text: 'Google Meet',
  );
  final TextEditingController meetingUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: '25',
  );
  final TextEditingController bannerUrlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String _createMode = 'offline';
  String _createCategory = 'Tech';
  bool _createIsFree = true;
  bool _createIsFeatured = false;
  bool _isCreating = false;

  // Getters
  List<EventItem> get allEvents => _allEvents;
  String get homeCategory => _homeCategory;
  String get homeSearchQuery => _homeSearchQuery;
  int get featuredPageIndex => _featuredPageIndex;

  String get allModeFilter => _allModeFilter;
  String get allCategory => _allCategory;
  String get allSearchQuery => _allSearchQuery;

  String get createMode => _createMode;
  String get createCategory => _createCategory;
  bool get createIsFree => _createIsFree;
  bool get createIsFeatured => _createIsFeatured;
  bool get isCreating => _isCreating;

  EventItem getEventById(String id) {
    return _allEvents.firstWhere(
      (e) => e.id == id,
      orElse: () => _allEvents.first,
    );
  }

  List<EventItem> get featuredEvents => _filterHomeSection(
    _allEvents.where((e) => e.isFeatured).toList(),
  );

  List<EventItem> get nearbyEvents => _filterHomeSection(
    _allEvents.where((e) => e.isNearby).toList(),
  );

  List<EventItem> get upcomingEvents => _filterHomeSection(
    _allEvents.where((e) => !e.isFeatured && !e.isNearby).toList(),
  );

  List<EventItem> get filteredAllEvents {
    final q = _allSearchQuery.trim().toLowerCase();
    return _allEvents.where((event) {
      final matchesMode = switch (_allModeFilter) {
        'Offline' => !event.isOnline,
        'Online' => event.isOnline,
        'Featured' => event.isFeatured,
        'Nearby' => event.isNearby || !event.isOnline,
        _ => true,
      };
      final matchesCategory =
          _allCategory == 'All' || event.category == _allCategory;
      final matchesQuery =
          q.isEmpty ||
          event.title.toLowerCase().contains(q) ||
          event.location.toLowerCase().contains(q) ||
          event.category.toLowerCase().contains(q) ||
          event.eventMode.toLowerCase().contains(q);
      return matchesMode && matchesCategory && matchesQuery;
    }).toList();
  }

  List<EventItem> _filterHomeSection(List<EventItem> source) {
    final q = _homeSearchQuery.trim().toLowerCase();
    return source.where((event) {
      final matchesCategory =
          _homeCategory == 'All' || event.category == _homeCategory;
      final matchesQuery =
          q.isEmpty ||
          event.title.toLowerCase().contains(q) ||
          event.location.toLowerCase().contains(q) ||
          event.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Home page mutators
  void setHomeCategory(String category) {
    _homeCategory = category;
    _featuredPageIndex = 0;
    notifyListeners();
  }

  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    _featuredPageIndex = 0;
    notifyListeners();
  }

  void clearHomeSearch() {
    homeSearchController.clear();
    setHomeSearchQuery('');
  }

  void setFeaturedPageIndex(int index) {
    if (_featuredPageIndex == index) return;
    _featuredPageIndex = index;
    notifyListeners();
  }

  // All Events page mutators
  void setAllModeFilter(String filter) {
    _allModeFilter = filter;
    notifyListeners();
  }

  void setAllCategory(String category) {
    _allCategory = category;
    notifyListeners();
  }

  void setAllSearchQuery(String query) {
    _allSearchQuery = query;
    notifyListeners();
  }

  void clearAllSearch() {
    allSearchController.clear();
    setAllSearchQuery('');
  }

  // Create Event form mutators
  void setCreateMode(String mode) {
    _createMode = mode;
    notifyListeners();
  }

  void setCreateCategory(String category) {
    _createCategory = category;
    notifyListeners();
  }

  void setCreateIsFree(bool isFree) {
    _createIsFree = isFree;
    notifyListeners();
  }

  void setCreateIsFeatured(bool isFeatured) {
    _createIsFeatured = isFeatured;
    notifyListeners();
  }

  void resetCreateEventForm() {
    titleController.clear();
    venueController.clear();
    addressController.clear();
    meetingUrlController.clear();
    bannerUrlController.clear();
    descriptionController.clear();
    _createMode = 'offline';
    _createCategory = 'Tech';
    _createIsFree = true;
    _createIsFeatured = false;
    notifyListeners();
  }

  Future<bool> toggleAttendance(EventItem event, Profile? profile) async {
    final userId =
        profile?.id ??
        Supabase.instance.client.auth.currentUser?.id ??
        'guest-user';
    final userName = profile?.displayName ?? 'You';
    final userEmail = profile?.email ?? 'you@example.com';

    final alreadyAttending = event.isUserAttending(userId);

    final updatedList = alreadyAttending
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
      attendeeList: updatedList,
    );

    _allEvents = _allEvents
        .map((item) => item.id == event.id ? updatedEvent : item)
        .toList();
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      if (alreadyAttending) {
        await client.from('event_registrations').delete().match({
          'event_id': event.id,
          'user_id': userId,
        });
      } else {
        await client.from('event_registrations').insert({
          'event_id': event.id,
          'user_id': userId,
        });
      }
    } catch (_) {}

    return !alreadyAttending;
  }

  Future<EventItem> submitNewEvent(Profile? organizer) async {
    _isCreating = true;
    notifyListeners();

    try {
      final isOnline = _createMode.toLowerCase() == 'online';
      final rawPrice = priceController.text.trim();
      final formattedPrice = _createIsFree
          ? 'Free'
          : (rawPrice.startsWith('\$') ? rawPrice : '\$$rawPrice');

      final locationDisplay = isOnline
          ? '${platformController.text.trim().isNotEmpty ? platformController.text.trim() : 'Virtual'} (Online)'
          : [
              if (venueController.text.trim().isNotEmpty)
                venueController.text.trim(),
              if (addressController.text.trim().isNotEmpty)
                addressController.text.trim(),
            ].join(', ');

      final (icon, colors, defaultBanner) = EventItem.styleForCategory(
        _createCategory,
      );

      final newEvent = EventItem(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        title: titleController.text.trim(),
        category: _createCategory,
        eventMode: isOnline ? 'online' : 'offline',
        date: dateController.text.trim(),
        time: timeController.text.trim(),
        location: locationDisplay.isEmpty ? 'TBA' : locationDisplay,
        distance: isOnline ? 'Online Event' : '1.0 km away',
        onlinePlatform: isOnline ? platformController.text.trim() : null,
        meetingUrl: isOnline ? meetingUrlController.text.trim() : null,
        price: formattedPrice,
        description: descriptionController.text.trim(),
        imageUrl: bannerUrlController.text.trim().isNotEmpty
            ? bannerUrlController.text.trim()
            : defaultBanner,
        attendees: 1,
        attendeeList: <EventAttendee>[
          EventAttendee(
            id: organizer?.id ?? 'organizer',
            name: '${organizer?.displayName ?? 'Admin'} (Host)',
            email: organizer?.email ?? 'admin@example.com',
            avatarUrl: organizer?.avatarUrl,
            registeredAtLabel: 'Organizer',
          ),
        ],
        isFeatured: _createIsFeatured,
        isNearby: !isOnline,
        icon: icon,
        gradientColors: colors,
      );

      _allEvents = <EventItem>[newEvent, ..._allEvents];
      notifyListeners();

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
            'venue_name': isOnline ? null : venueController.text.trim(),
            'address': isOnline ? null : addressController.text.trim(),
            'online_platform': isOnline ? platformController.text.trim() : null,
            'meeting_url': isOnline ? meetingUrlController.text.trim() : null,
            'is_free': _createIsFree,
            'price': _createIsFree
                ? 0
                : (double.tryParse(rawPrice.replaceAll('\$', '')) ?? 0),
            'is_featured': _createIsFeatured,
            'banner_url': newEvent.imageUrl,
          });
        }
      } catch (_) {}

      resetCreateEventForm();
      return newEvent;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    homeSearchController.dispose();
    featuredPageController.dispose();
    allSearchController.dispose();
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    venueController.dispose();
    addressController.dispose();
    platformController.dispose();
    meetingUrlController.dispose();
    priceController.dispose();
    bannerUrlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

