import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:event_managment_app/views/eventsView/create_event_page.dart';
import 'package:event_managment_app/widget/event_carousel.dart';
import 'package:event_managment_app/widget/event_details_sheet.dart';
import 'package:event_managment_app/widget/upcoming_event_tile.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final searchController = TextEditingController(
      text: allEventsSearchNotifier.value,
    );

    return ValueListenableBuilder<Profile?>(
      valueListenable: profileNotifier,
      builder: (context, profile, _) {
        final isAdmin = profile?.isAdmin ?? false;

        return Scaffold(
          // Only Admin users see the "+ Create Event" button
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
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  allEventsListNotifier,
                  allEventsModeFilterNotifier,
                  allEventsCategoryNotifier,
                  allEventsSearchNotifier,
                ]),
                builder: (context, _) {
                  final modeFilter = allEventsModeFilterNotifier.value;
                  final selectedCategory = allEventsCategoryNotifier.value;
                  final searchQuery = allEventsSearchNotifier.value;

                  final filteredEvents = filterAllEvents(
                    events: allEventsListNotifier.value,
                    modeFilter: modeFilter,
                    category: selectedCategory,
                    searchQuery: searchQuery,
                  );

                  return CustomScrollView(
                    slivers: [
                      // 1. Page Header & Role Status Banner
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'All Events Directory',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Showing ${filteredEvents.length} of ${allEventsListNotifier.value.length} total events',
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quick Role Chip
                                  ActionChip(
                                    avatar: Icon(
                                      isAdmin
                                          ? Icons.admin_panel_settings
                                          : Icons.person_outline,
                                      size: 16,
                                      color: isAdmin
                                          ? Colors.white
                                          : scheme.primary,
                                    ),
                                    backgroundColor: isAdmin
                                        ? Colors.teal.shade700
                                        : scheme.surfaceContainerHighest,
                                    label: Text(
                                      isAdmin ? 'Admin Mode' : 'User Mode',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin
                                            ? Colors.white
                                            : scheme.onSurface,
                                      ),
                                    ),
                                    onPressed: () {
                                      final nextRole = isAdmin
                                          ? 'user'
                                          : 'admin';
                                      updateUserRole(nextRole);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            nextRole == 'admin'
                                                ? 'Switched to Admin Mode: "+ Create Event" button unlocked!'
                                                : 'Switched to User Mode: Create button hidden.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
                                          'Viewing as User. Tap "User Mode" above (or go to Profile) to switch to Admin and create events.',
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
                              // Search Bar
                              TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  allEventsSearchNotifier.value = value;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Search all events by title, venue, online/offline...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            searchController.clear();
                                            allEventsSearchNotifier.value = '';
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Mode Filter Bar (All / Offline / Online / Featured / Nearby)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 46,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: eventModeFilters.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = eventModeFilters[index];
                              final selected = filter == modeFilter;
                              return FilterChip(
                                selected: selected,
                                label: Text(filter),
                                avatar: Icon(
                                  switch (filter) {
                                    'Offline' => Icons.location_on_outlined,
                                    'Online' => Icons.videocam_outlined,
                                    'Featured' => Icons.star_outline,
                                    'Nearby' => Icons.near_me_outlined,
                                    _ => Icons.apps_rounded,
                                  },
                                  size: 16,
                                ),
                                onSelected: (_) {
                                  allEventsModeFilterNotifier.value = filter;
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // 3. Category Filter Chips
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 48,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: eventCategories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = eventCategories[index];
                              return ChoiceChip(
                                label: Text(cat),
                                selected: cat == selectedCategory,
                                onSelected: (_) {
                                  allEventsCategoryNotifier.value = cat;
                                },
                              );
                            },
                          ),
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              return UpcomingEventTile(
                                event: event,
                                onTap: () =>
                                    showEventDetailsSheet(context, event),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

