import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:event_managment_app/widget/event_carousel.dart';
import 'package:event_managment_app/widget/event_details_sheet.dart';
import 'package:event_managment_app/widget/section_header.dart';
import 'package:event_managment_app/widget/upcoming_event_tile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final searchController = TextEditingController(
      text: searchQueryNotifier.value,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListenableBuilder(
              listenable: Listenable.merge([
                selectedCategoryNotifier,
                searchQueryNotifier,
                featuredEventsNotifier,
                nearbyEventsNotifier,
                upcomingEventsNotifier,
              ]),
              builder: (context, _) {
                final selectedCategory = selectedCategoryNotifier.value;
                final searchQuery = searchQueryNotifier.value;

                final featuredEvents = filterEventsByCategory(
                  featuredEventsNotifier.value,
                  selectedCategory,
                  searchQuery: searchQuery,
                );
                final nearbyEvents = filterEventsByCategory(
                  nearbyEventsNotifier.value,
                  selectedCategory,
                  searchQuery: searchQuery,
                );
                final upcomingEvents = filterEventsByCategory(
                  upcomingEventsNotifier.value,
                  selectedCategory,
                  searchQuery: searchQuery,
                );

                return CustomScrollView(
                  slivers: [
                    // 1. Greeting & Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _GreetingHeader(),
                            const SizedBox(height: 16),
                            TextField(
                              controller: searchController,
                              onChanged: (value) {
                                searchQueryNotifier.value = value;
                                featuredPageNotifier.value = 0;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Search events, locations, categories...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          searchQueryNotifier.value = '';
                                          featuredPageNotifier.value = 0;
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

                    // 2. Horizontal Category Chips
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: eventCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = eventCategories[index];
                            return ChoiceChip(
                              label: Text(category),
                              selected: category == selectedCategory,
                              onSelected: (_) {
                                selectedCategoryNotifier.value = category;
                                featuredPageNotifier.value = 0;
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // 3. Featured Events Horizontal Carousel
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Featured Events',
                        subtitle: 'Handpicked highlights for you',
                        onSeeAll: () => openAllEventsPage(modeFilter: 'All'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FeaturedEventsCarousel(
                        events: featuredEvents,
                        height: isWide ? 260 : 230,
                        onEventTap: (event) =>
                            showEventDetailsSheet(context, event),
                      ),
                    ),

                    // 4. Events Near Me Horizontal Carousel
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Events Near Me',
                        subtitle: 'Happening around your location',
                        onSeeAll: () => openAllEventsPage(modeFilter: 'All'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: NearbyEventsCarousel(
                        events: nearbyEvents,
                        onEventTap: (event) =>
                            showEventDetailsSheet(context, event),
                      ),
                    ),

                    // 5. Upcoming Events Vertical List
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Upcoming Events',
                        subtitle: 'More events to explore',
                        onSeeAll: () => openAllEventsPage(modeFilter: 'All'),
                      ),
                    ),
                    if (upcomingEvents.isEmpty)
                      const SliverToBoxAdapter(
                        child: EmptyEventsPlaceholder(
                          message: 'No upcoming events match your filter.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: upcomingEvents.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = upcomingEvents[index];
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
        );
      },
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Profile?>(
      valueListenable: profileNotifier,
      builder: (context, profile, _) {
        final displayName = (profile?.fullName?.trim().isNotEmpty ?? false)
            ? profile!.fullName!.trim()
            : 'Explorer';
        final isAdmin = profile?.isAdmin ?? false;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName 👋',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Discover Amazing Events',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isAdmin
                    ? Colors.teal.shade700
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.location_on,
                    size: 16,
                    color: isAdmin ? Colors.white : scheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAdmin ? 'Admin' : 'Nearby',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAdmin
                          ? Colors.white
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
