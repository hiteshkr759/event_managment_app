import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/views/eventsView/create_event_page.dart';
import 'package:event_managment_app/widget/event_carousel.dart';
import 'package:event_managment_app/widget/event_details_sheet.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:event_managment_app/widget/search_filter_bar.dart';
import 'package:event_managment_app/widget/upcoming_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

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
                                  'Showing ${filteredEvents.length} of ${eventsProvider.allEvents.length} total events',
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

              // 4. Exhaustive Events List
              if (filteredEvents.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyEventsPlaceholder(
                    message:
                        'No events match your current mode or category filter.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
            ],
          ),
        ),
      ),
    );
  }
}
