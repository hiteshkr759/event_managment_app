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
  /// Number of events requested per page from Supabase (`LIMIT 5`).
  ///
  /// **Why 5?**
  /// Fetching small pages (e.g., 5 rows at a time instead of thousands) keeps
  /// initial startup fast and reduces mobile data usage.
  static const int pageSize = 5;

  List<EventItem> _allEvents = <EventItem>[];

  // Server-side pagination state
  int _currentPage = 0;
  bool _hasMoreEvents = true;
  bool _isLoadingMore = false;

  /// Scroll controller attached to the Home tab's `CustomScrollView` to detect
  /// when the user scrolls near the bottom and auto-trigger [loadMoreEvents].
  final ScrollController homeScrollController = ScrollController();

  /// Scroll controller attached to the All Events tab's `CustomScrollView` to
  /// detect when the user scrolls near the bottom and auto-trigger [loadMoreEvents].
  final ScrollController allEventsScrollController = ScrollController();

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

  /// Creates an [EventsProvider], attaches infinite-scroll listeners, and fetches
  /// the first page (`Page 0`) of events from Supabase.
  EventsProvider() {
    homeScrollController.addListener(() => _onScroll(homeScrollController));
    allEventsScrollController.addListener(
      () => _onScroll(allEventsScrollController),
    );

    Future.microtask(fetchEventsFromServer);
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedIn) {
          Future.microtask(fetchEventsFromServer);
        }
      },
      onError: (_, _) {},
    );
  }

  // Triggered whenever the user scrolls on the Home or All Events screen.
  // When the scroll position is within 200 pixels of the bottom, it requests
  // the next page of events from Supabase.
  void _onScroll(ScrollController controller) {
    if (!controller.hasClients) return;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      loadMoreEvents();
    }
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

  /// All events currently loaded across fetched pages from Supabase.
  List<EventItem> get allEvents => _allEvents;

  /// Zero-based index of the last page fetched from Supabase (`0` = first page).
  int get currentPage => _currentPage;

  /// Whether additional pages of events are still available on the server.
  bool get hasMoreEvents => _hasMoreEvents;

  /// Whether the next page of events (`page > 0`) is currently being loaded.
  bool get isLoadingMore => _isLoadingMore;

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

  /// Whether the initial page (`Page 0`) of events is being fetched from Supabase.
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

  /// Paginated upcoming events feed for the Home screen.
  List<EventItem> get upcomingEvents => _filterHomeSection(_allEvents);

  /// Filtered list of loaded events for the "All Events" directory tab.
  ///
  /// **Purpose:**
  /// Returns the currently loaded pages of events matching the active mode,
  /// category, and search filters.
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

  /// Updates the selected [category] chip on the Home screen and fetches Page 0.
  void setHomeCategory(String category) {
    if (_homeCategory == category) return;
    _homeCategory = category;
    _featuredPageIndex = 0;
    _safeNotify();
    fetchEventsFromServer();
  }

  /// Updates the Home search [query] as the user types and fetches Page 0.
  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    _featuredPageIndex = 0;
    _safeNotify();
    fetchEventsFromServer();
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

  /// Updates the mode [filter] (`All`, `Offline`, `Online`, etc.) on All Events
  /// and fetches Page 0 from the server with the new filter.
  void setAllModeFilter(String filter) {
    if (_allModeFilter == filter) return;
    _allModeFilter = filter;
    _safeNotify();
    fetchEventsFromServer();
  }

  /// Updates the selected [category] chip on the All Events screen and fetches Page 0.
  void setAllCategory(String category) {
    if (_allCategory == category) return;
    _allCategory = category;
    _safeNotify();
    fetchEventsFromServer();
  }

  /// Updates the search [query] on the All Events screen and fetches Page 0.
  void setAllSearchQuery(String query) {
    _allSearchQuery = query;
    _safeNotify();
    fetchEventsFromServer();
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

  // Builds and executes a server-side paginated query on `public.events` for
  // the requested zero-based `page` index.
  //
  // **How Server-Side Pagination works in Supabase:**
  // - Calculates `from = page * pageSize` and `to = from + pageSize - 1`.
  // - Applies active filters (`.eq`, `.or`) directly in PostgreSQL.
  // - Calls `.range(from, to)`, which translates to SQL `LIMIT 5 OFFSET <from>`
  //   so only 5 rows travel over the network per request.
  Future<List<EventItem>> _fetchPageFromSupabase(int page) async {
    final client = Supabase.instance.client;
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = client.from('events').select(
      '*, event_registrations(user_id, registered_at, profiles(id, full_name, email, avatar_url))',
    );

    // 1. Apply Server-Side Mode Filter (if set on All Events tab)
    switch (_allModeFilter) {
      case 'Offline':
        query = query.eq('event_mode', 'offline');
      case 'Online':
        query = query.eq('event_mode', 'online');
      case 'Featured':
        query = query.eq('is_featured', true);
      case 'Nearby':
        query = query.eq('city', 'nearby');
    }

    // 2. Apply Server-Side Category Filter
    final activeCategory = _allCategory != 'All'
        ? _allCategory
        : (_homeCategory != 'All' ? _homeCategory : 'All');
    if (activeCategory != 'All') {
      query = query.eq('category', activeCategory);
    }

    // 3. Apply Server-Side Search Filter (case-insensitive ILIKE)
    final activeQuery = _allSearchQuery.trim().isNotEmpty
        ? _allSearchQuery.trim()
        : _homeSearchQuery.trim();
    if (activeQuery.isNotEmpty) {
      query = query.or(
        'title.ilike.%$activeQuery%,venue_name.ilike.%$activeQuery%,category.ilike.%$activeQuery%,online_platform.ilike.%$activeQuery%',
      );
    }

    // 4. Order chronologically and request ONLY the current page slice [from..to]
    final serverRows = await query
        .order('starts_at', ascending: true)
        .range(from, to);

    return serverRows
        .whereType<Map<String, dynamic>>()
        .map(EventItem.fromSupabaseMap)
        .toList();
  }

  /// Resets pagination to `Page 0` and fetches the first [pageSize] events from Supabase.
  ///
  /// **Purpose:**
  /// Loads only the initial page of events (`0..4`) on app startup, pull-to-refresh,
  /// or when filters change, instead of downloading the entire database table at once.
  ///
  /// **How it works:**
  /// 1. Resets `_currentPage = 0` and `_hasMoreEvents = true`.
  /// 2. Calls `_fetchPageFromSupabase(0)` which runs `.range(0, pageSize - 1)`.
  /// 3. If the server returns fewer than [pageSize] items, sets `_hasMoreEvents = false`
  ///    so no further pages are requested.
  Future<(bool, String)> fetchEventsFromServer() async {
    _isLoading = true;
    _currentPage = 0;
    _hasMoreEvents = true;
    _safeNotify();

    try {
      final firstPageItems = await _fetchPageFromSupabase(0);
      _allEvents = firstPageItems;
      _hasMoreEvents = firstPageItems.length >= pageSize;
      _safeNotify();

      return (
        true,
        'Loaded page 1 (${_allEvents.length} events) from Supabase!',
      );
    } catch (e) {
      debugPrint('Failed to fetch events from Supabase: $e');
      return (false, 'Could not fetch events from Supabase: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Fetches the next page of events from Supabase and appends them to [allEvents].
  ///
  /// **Purpose:**
  /// Powers infinite scrolling and the "Load More Events" button so additional
  /// events are fetched on-demand from the server as the user scrolls down.
  ///
  /// **How it works:**
  /// 1. Guards against duplicate calls: returns immediately if [_isLoading],
  ///    [_isLoadingMore], or `![hasMoreEvents]`.
  /// 2. Requests `nextPage = _currentPage + 1` using `.range(from, to)`.
  /// 3. Appends the newly returned items to `_allEvents` (deduplicating by `id`).
  /// 4. Sets `_hasMoreEvents = false` once Supabase returns fewer than [pageSize] rows.
  Future<void> loadMoreEvents() async {
    if (_isLoading || _isLoadingMore || !_hasMoreEvents) return;

    _isLoadingMore = true;
    _safeNotify();

    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPageFromSupabase(nextPage);

      if (nextItems.isEmpty) {
        _hasMoreEvents = false;
      } else {
        final existingIds = _allEvents.map((e) => e.id).toSet();
        final uniqueNewItems = nextItems
            .where((e) => !existingIds.contains(e.id))
            .toList();
        _allEvents = <EventItem>[..._allEvents, ...uniqueNewItems];
        _currentPage = nextPage;
        _hasMoreEvents = nextItems.length >= pageSize;
      }
    } catch (e) {
      debugPrint('Failed to load next page from Supabase: $e');
    } finally {
      _isLoadingMore = false;
      _safeNotify();
    }
  }

  /// Toggles the current user's attendance for [event] and persists it to Supabase.
  ///
  /// **Purpose:**
  /// Lets a user book/attend an event or cancel their registration with instant
  /// UI feedback while preserving the currently loaded pagination state.
  ///
  /// **How it works:**
  /// 1. Performs an **optimistic UI update** first: immediately adds or removes
  ///    the user from `event.attendeeList` and increments/decrements the count
  ///    so the button updates without lag.
  /// 2. Persists the change to `public.event_registrations` in Supabase using
  ///    `upsert` (when joining) or `delete` (when cancelling).
  /// 3. Refreshes only that single event row from Supabase so the user's loaded
  ///    pages and scroll position are preserved.
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
        // Fetch only the updated event row so we don't reset loaded pages
        final refreshedRow = await client
            .from('events')
            .select(
              '*, event_registrations(user_id, registered_at, profiles(id, full_name, email, avatar_url))',
            )
            .eq('id', event.id)
            .maybeSingle();
        if (refreshedRow != null) {
          final refreshedItem = EventItem.fromSupabaseMap(refreshedRow);
          _allEvents = _allEvents
              .map((item) => item.id == event.id ? refreshedItem : item)
              .toList();
          _safeNotify();
        }
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
    // Always dispose ScrollControllers and TextEditingControllers when the
    // provider is disposed to free memory and prevent memory leaks.
    homeScrollController.dispose();
    allEventsScrollController.dispose();
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
