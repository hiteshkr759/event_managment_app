import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/views/eventsView/create_event_page.dart';
import 'package:event_managment_app/widget/event_carousel.dart';
import 'package:event_managment_app/widget/event_details_sheet.dart';
import 'package:event_managment_app/widget/eventora_logo.dart';
import 'package:event_managment_app/widget/pagination_footer.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:event_managment_app/widget/search_filter_bar.dart';
import 'package:event_managment_app/widget/upcoming_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Full searchable and filterable directory of all events (Tab 2).
///
/// **Purpose:**
/// Lets users browse events in Eventora using server-side pagination, filter by
/// delivery mode (`Offline`, `Online`, `Featured`, `Nearby`) or category, and—if
/// the user is in **Admin** mode—launch [CreateEventPage] via a Floating Action
/// Button.
///
/// **How it works:**
/// 1. Watches [EventsProvider] (for the paginated event list and pagination
///    flags) and [ProfileProvider] (to check `isAdmin`).
/// 2. Attaches [EventsProvider.allEventsScrollController] to the
///    [CustomScrollView] so scrolling near the bottom automatically fetches the
///    next page of events from Supabase.
class EventsPage extends StatelessWidget {
  /// Creates the [EventsPage] widget.
  const EventsPage({super.key});

  // Maps each mode filter name to a matching Material icon for the filter chips.
  IconData _iconForModeFilter(String filter) {
    return switch (filter) {
      'Offline' => Icons.location_on_outlined,
      'Online' => Icons.videocam_outlined,
      'Featured' => Icons.star_outline,
      'Nearby' => Icons.near_me_outlined,
      _ => Icons.apps_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eventsProvider = context.watch<EventsProvider>();
    final isAdmin = context.watch<ProfileProvider>().isAdmin;
    final filteredEvents = eventsProvider.filteredAllEvents;

    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateEventPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Event'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            controller: eventsProvider.allEventsScrollController,
            slivers: [
              // 1. Header & Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All Events Directory',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Loaded ${filteredEvents.length} events • Page ${eventsProvider.currentPage + 1} (${EventsProvider.pageSize} per page)',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const RoleModeToggleChip(),
                        ],
                      ),
                      if (!isAdmin) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: scheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Viewing as User. Tap "User Mode" above (or Profile tab) to switch to Admin and create events.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppSearchBar(
                        controller: eventsProvider.allSearchController,
                        query: eventsProvider.allSearchQuery,
                        hintText:
                            'Search all events by title, venue, online/offline...',
                        onChanged: eventsProvider.setAllSearchQuery,
                        onClear: eventsProvider.clearAllSearch,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Mode Filter Bar (All / Offline / Online / Featured / Nearby)
              SliverToBoxAdapter(
                child: HorizontalChipSelector(
                  items: eventModeFilters,
                  selectedItem: eventsProvider.allModeFilter,
                  onSelected: eventsProvider.setAllModeFilter,
                  iconBuilder: _iconForModeFilter,
                ),
              ),

              // 3. Category Filter Bar
              SliverToBoxAdapter(
                child: HorizontalChipSelector(
                  items: eventCategories,
                  selectedItem: eventsProvider.allCategory,
                  onSelected: eventsProvider.setAllCategory,
                ),
              ),

              // 4. Server-Paginated Events List
              if (eventsProvider.isLoading && filteredEvents.isEmpty)
                const SliverToBoxAdapter(
                  child: EventoraLoadingScreen(
                    fullScreen: false,
                    message: 'Searching Eventora Directory...',
                    subtitle: 'Fetching matching events from Supabase',
                  ),
                )
              else if (filteredEvents.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyEventsPlaceholder(
                    message:
                        'No events match your current mode or category filter.',
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverList.separated(
                    itemCount: filteredEvents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return UpcomingEventTile(
                        event: event,
                        onTap: () => showEventDetailsSheet(context, event),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 72),
                    child: PaginationFooter(
                      isLoadingMore: eventsProvider.isLoadingMore,
                      hasMore: eventsProvider.hasMoreEvents,
                      loadedCount: filteredEvents.length,
                      currentPage: eventsProvider.currentPage,
                      onLoadMore: eventsProvider.loadMoreEvents,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
