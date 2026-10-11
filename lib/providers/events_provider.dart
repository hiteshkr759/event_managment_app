import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central state provider for browsing, filtering, creating, and booking events.
///
/// **Purpose:**
/// Acts as the single source of truth for all events in Eventora. It fetches
/// events from Supabase (`public.events`), holds search/filter states for the
/// Home and All Events screens, manages the Create Event form controllers, and
/// handles RSVP registrations (`public.event_registrations`).
///
/// **How it works:**
/// Extends [ChangeNotifier]. Whenever events are fetched from Supabase or a
/// user changes a search/category filter, `_safeNotify()` calls
/// [notifyListeners], which automatically rebuilds any `StatelessWidget`
/// watching [EventsProvider].
class EventsProvider extends ChangeNotifier {
  List<EventItem> _allEvents = <EventItem>[];

  /// Controller for the search bar on the Home tab.
  final TextEditingController homeSearchController = TextEditingController();
  String _homeCategory = 'All';
  String _homeSearchQuery = '';
  int _featuredPageIndex = 0;

  /// Controller for the search bar on the All Events directory tab.
  final TextEditingController allSearchController = TextEditingController();
  String _allModeFilter = 'All';
  String _allCategory = 'All';
  String _allSearchQuery = '';

  /// Controller for the event title input on the Create Event screen.
  final TextEditingController titleController = TextEditingController();

  /// Controller for the event date input on the Create Event screen.
  final TextEditingController dateController = TextEditingController(
    text: 'Nov 15, 2026',
  );

  /// Controller for the event time input on the Create Event screen.
  final TextEditingController timeController = TextEditingController(
    text: '06:00 PM',
  );

  /// Controller for the physical venue name when creating an offline event.
  final TextEditingController venueController = TextEditingController();

  /// Controller for the street address/distance when creating an offline event.
  final TextEditingController addressController = TextEditingController();

  /// Controller for the streaming platform name when creating an online event.
  final TextEditingController platformController = TextEditingController(
    text: 'Google Meet',
  );

  /// Controller for the meeting link when creating an online event.
  final TextEditingController meetingUrlController = TextEditingController();

  /// Controller for the ticket price when creating a paid event.
  final TextEditingController priceController = TextEditingController(
    text: '25',
  );

  /// Controller for a custom banner image URL when creating an event.
  final TextEditingController bannerUrlController = TextEditingController();

  /// Controller for the event description input.
  final TextEditingController descriptionController = TextEditingController();

  String _createMode = 'offline';
  String _createCategory = 'Tech';
  bool _createIsFree = true;
  bool _createIsFeatured = false;
  bool _isCreating = false;
  bool _isLoading = false;

  /// Creates an [EventsProvider] and immediately fetches events from Supabase.
  ///
  /// **How it works:**
  /// Schedules [fetchEventsFromServer] using [Future.microtask] so the initial
  /// network call runs right after widget initialization, and also listens to
  /// Supabase auth state changes so events are re-fetched when a user signs in.
  EventsProvider() {
    Future.microtask(fetchEventsFromServer);
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedIn ||
            data.event == AuthChangeEvent.initialSession) {
          Future.microtask(fetchEventsFromServer);
        }
      },
      onError: (_, _) {},
    );
  }

  // Safely notifies listeners without triggering Flutter's "setState() or
  // markNeedsBuild() called during build" exception.
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

  /// All events currently loaded from Supabase.
  List<EventItem> get allEvents => _allEvents;

  /// Currently selected category chip on the Home screen.
  String get homeCategory => _homeCategory;

  /// Current search query text on the Home screen.
  String get homeSearchQuery => _homeSearchQuery;

  /// Active slide index of the Featured Events carousel on the Home screen.
  int get featuredPageIndex => _featuredPageIndex;

  /// Selected mode filter (`'All'`, `'Offline'`, `'Online'`, etc.) on All Events.
  String get allModeFilter => _allModeFilter;

  /// Selected category filter on the All Events screen.
  String get allCategory => _allCategory;

  /// Current search query text on the All Events screen.
  String get allSearchQuery => _allSearchQuery;

  /// Selected event mode (`'offline'` or `'online'`) in the Create Event form.
  String get createMode => _createMode;

  /// Selected event category in the Create Event form.
  String get createCategory => _createCategory;

  /// Whether the event being created is marked as free.
  bool get createIsFree => _createIsFree;

  /// Whether the event being created should appear in the Featured carousel.
  bool get createIsFeatured => _createIsFeatured;

  /// Whether a new event submission is currently in progress.
  bool get isCreating => _isCreating;

  /// Whether events are currently being fetched from Supabase.
  bool get isLoading => _isLoading;

  /// Alias for [isLoading] indicating whether a server sync is in progress.
  bool get isSyncing => _isLoading;

  /// Looks up a single [EventItem] by its [id].
  ///
  /// **Purpose:**
  /// Used by `EventDetailsSheet` and `AttendeesListSheet` so they always read
  /// the freshest state of an event (such as updated attendee counts) from
  /// [EventsProvider].
  EventItem? getEventById(String id) {
    for (final e in _allEvents) {
      if (e.id == id) return e;
    }
    return _allEvents.isNotEmpty ? _allEvents.first : null;
  }

  /// Events marked as `isFeatured`, filtered by the Home search and category.
  List<EventItem> get featuredEvents => _filterHomeSection(
    _allEvents.where((e) => e.isFeatured).toList(),
  );

  /// Events marked as `isNearby`, filtered by the Home search and category.
  List<EventItem> get nearbyEvents => _filterHomeSection(
    _allEvents.where((e) => e.isNearby).toList(),
  );

  /// Standard upcoming events (neither featured nor nearby), filtered for Home.
  List<EventItem> get upcomingEvents => _filterHomeSection(
    _allEvents.where((e) => !e.isFeatured && !e.isNearby).toList(),
  );

  /// Filtered list of all events for the "All Events" directory tab.
  ///
  /// **Purpose:**
  /// Combines three filters simultaneously: mode (`Offline`, `Online`,
  /// `Featured`, `Nearby`), category (`Tech`, `Music`, etc.), and free-text
  /// search query.
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

  // Helper that applies the Home screen's category and search query filters to
  // a subset of events (Featured, Nearby, or Upcoming).
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

  /// Updates the selected [category] chip on the Home screen and notifies UI.
  void setHomeCategory(String category) {
    _homeCategory = category;
    _featuredPageIndex = 0;
    _safeNotify();
  }

  /// Updates the Home search [query] as the user types and notifies UI.
  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    _featuredPageIndex = 0;
    _safeNotify();
  }

  /// Clears the Home search text field and resets the search filter.
  void clearHomeSearch() {
    homeSearchController.clear();
    setHomeSearchQuery('');
  }

  /// Updates the active dot indicator [index] for the Featured Events carousel.
  void setFeaturedPageIndex(int index) {
    if (_featuredPageIndex == index) return;
    _featuredPageIndex = index;
    _safeNotify();
  }

  /// Updates the mode [filter] (`All`, `Offline`, `Online`, etc.) on All Events.
  void setAllModeFilter(String filter) {
    _allModeFilter = filter;
    _safeNotify();
  }

  /// Updates the selected [category] chip on the All Events screen.
  void setAllCategory(String category) {
    _allCategory = category;
    _safeNotify();
  }

  /// Updates the search [query] on the All Events screen.
  void setAllSearchQuery(String query) {
    _allSearchQuery = query;
    _safeNotify();
  }

  /// Clears the All Events search input and resets the search query.
  void clearAllSearch() {
    allSearchController.clear();
    setAllSearchQuery('');
  }

  /// Sets the event delivery [mode] (`'offline'` or `'online'`) in Create Event.
  void setCreateMode(String mode) {
    _createMode = mode;
    _safeNotify();
  }

  /// Sets the event [category] in the Create Event form.
  void setCreateCategory(String category) {
    _createCategory = category;
    _safeNotify();
  }

  /// Sets whether the new event is free ([isFree]) in the Create Event form.
  void setCreateIsFree(bool isFree) {
    _createIsFree = isFree;
    _safeNotify();
  }

  /// Sets whether the new event is featured ([isFeatured]) in Create Event.
  void setCreateIsFeatured(bool isFeatured) {
    _createIsFeatured = isFeatured;
    _safeNotify();
  }

  /// Resets all text fields and toggles in the Create Event form to defaults.
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
    _safeNotify();
  }

  /// Pulls all events and their attendee registrations directly from Supabase.
  ///
  /// **Purpose:**
  /// Synchronizes the app's `_allEvents` list with the remote `public.events`
  /// and `public.event_registrations` tables in Supabase.
  ///
  /// **How it works:**
  /// 1. Sets `_isLoading = true` so the UI can show a loading spinner.
  /// 2. Runs a relational `SELECT` query on `events` that also joins
  ///    `event_registrations` and each attendee's `profiles` row.
  /// 3. Converts each JSON map into an [EventItem] using
  ///    [EventItem.fromSupabaseMap] and notifies listeners to refresh the UI.
  Future<(bool, String)> fetchEventsFromServer() async {
    if (_isLoading) return (false, 'Already refreshing events...');
    _isLoading = true;
    _safeNotify();

    try {
      final client = Supabase.instance.client;
      final serverRows = await client
          .from('events')
          .select(
            '*, event_registrations(user_id, registered_at, profiles(id, full_name, email, avatar_url))',
          )
          .order('created_at', ascending: true);

      _allEvents = serverRows
          .whereType<Map<String, dynamic>>()
          .map(EventItem.fromSupabaseMap)
          .toList();
      _safeNotify();

      return (
        true,
        'Loaded ${_allEvents.length} events from Supabase!',
      );
    } catch (e) {
      debugPrint('Failed to fetch events from Supabase: $e');
      return (false, 'Could not fetch events from Supabase: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Toggles the current user's attendance for [event] and persists it to Supabase.
  ///
  /// **Purpose:**
  /// Lets a user book/attend an event or cancel their registration with instant
  /// UI feedback.
  ///
  /// **How it works:**
  /// 1. Performs an **optimistic UI update** first: immediately adds or removes
  ///    the user from `event.attendeeList` and increments/decrements the count
  ///    so the button updates without lag.
  /// 2. Persists the change to `public.event_registrations` in Supabase using
  ///    `upsert` (when joining) or `delete` (when cancelling).
  /// 3. Calls [fetchEventsFromServer] to ensure local state matches the server.
  Future<bool> toggleAttendance(EventItem event, Profile? profile) async {
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    final userId = profile?.id ?? authUser?.id ?? 'guest-user';
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
    _safeNotify();

    try {
      if (authUser != null) {
        if (alreadyAttending) {
          await client.from('event_registrations').delete().match({
            'event_id': event.id,
            'user_id': authUser.id,
          });
        } else {
          await client.from('event_registrations').upsert({
            'event_id': event.id,
            'user_id': authUser.id,
          }, onConflict: 'event_id,user_id');
        }
        await fetchEventsFromServer();
      }
    } catch (e) {
      debugPrint('Failed to update attendance in Supabase: $e');
    }

    return !alreadyAttending;
  }

  /// Creates a new event from the form controllers and inserts it into Supabase.
  ///
  /// **Purpose:**
  /// Called when an Admin submits the "Create Event" form.
  ///
  /// **How it works:**
  /// 1. Reads values from the form's [TextEditingController]s and state flags.
  /// 2. Constructs an [EventItem] and converts it via [EventItem.toSupabaseMap].
  /// 3. Inserts the row into `public.events` in Supabase and prepends the newly
  ///    created event to `_allEvents` so it appears immediately in the app.
  Future<EventItem> submitNewEvent(Profile? organizer) async {
    _isCreating = true;
    _safeNotify();

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

      var newEvent = EventItem(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        title: titleController.text.trim(),
        category: _createCategory,
        eventMode: isOnline ? 'online' : 'offline',
        date: dateController.text.trim(),
        time: timeController.text.trim(),
        location: locationDisplay.isEmpty ? 'TBA' : locationDisplay,
        distance: isOnline
            ? 'Online Event'
            : (addressController.text.trim().isNotEmpty
                  ? addressController.text.trim()
                  : '1.0 km away'),
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

      try {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        if (user != null) {
          final inserted = await client
              .from('events')
              .insert(newEvent.toSupabaseMap(user.id))
              .select(
                '*, event_registrations(user_id, registered_at, profiles(id, full_name, email, avatar_url))',
              )
              .single();
          newEvent = EventItem.fromSupabaseMap(inserted);
        }
      } catch (e) {
        debugPrint('Failed to insert new event into Supabase: $e');
      }

      _allEvents = <EventItem>[newEvent, ..._allEvents];
      _safeNotify();

      resetCreateEventForm();
      return newEvent;
    } finally {
      _isCreating = false;
      _safeNotify();
    }
  }

  @override
  void dispose() {
    // Always dispose TextEditingControllers when the provider is disposed to
    // free memory and prevent memory leaks.
    homeSearchController.dispose();
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
