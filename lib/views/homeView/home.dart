import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/widget/event_carousel.dart';
import 'package:event_managment_app/widget/event_details_sheet.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:event_managment_app/widget/search_filter_bar.dart';
import 'package:event_managment_app/widget/section_header.dart';
import 'package:event_managment_app/widget/upcoming_event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The primary discovery dashboard shown on the first bottom navigation tab.
///
/// **Purpose:**
/// Displays a personalized greeting, search bar, category chips, a "Featured
/// Events" carousel, an "Events Near Me" carousel, and an "Upcoming Events"
/// list.
///
/// **How it works:**
/// 1. Calls `context.watch<EventsProvider>()` so any change to the search query,
///    category chip, or server-loaded events triggers a rebuild.
/// 2. Uses a [CustomScrollView] with `Sliver` widgets so horizontal carousels
///    and vertical lists scroll smoothly together inside a single scrollable
///    viewport.
class HomePage extends StatelessWidget {
  /// Creates the [HomePage] widget.
  const HomePage({super.key});

  // Switches the All Events filter and jumps to Tab 1 ("Events") when the user
  // taps "See All" on any section header.
  void _onSeeAllEvents(BuildContext context, String modeFilter) {
    context.read<EventsProvider>().setAllModeFilter(modeFilter);
    context.read<NavigationProvider>().setTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final featuredEvents = eventsProvider.featuredEvents;
    final nearbyEvents = eventsProvider.nearbyEvents;
    final upcomingEvents = eventsProvider.upcomingEvents;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: CustomScrollView(
              slivers: [
                // 1. Greeting & Reusable Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _GreetingHeader(),
                        const SizedBox(height: 16),
                        AppSearchBar(
                          controller: eventsProvider.homeSearchController,
                          query: eventsProvider.homeSearchQuery,
                          hintText: 'Search events, locations, categories...',
                          onChanged: eventsProvider.setHomeSearchQuery,
                          onClear: eventsProvider.clearHomeSearch,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Reusable Horizontal Category Chips
                SliverToBoxAdapter(
                  child: HorizontalChipSelector(
                    items: eventCategories,
                    selectedItem: eventsProvider.homeCategory,
                    onSelected: eventsProvider.setHomeCategory,
                  ),
                ),

                // 3. Featured Events Horizontal Carousel
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Featured Events',
                    subtitle: 'Handpicked highlights for you',
                    onSeeAll: () => _onSeeAllEvents(context, 'All'),
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
                    onSeeAll: () => _onSeeAllEvents(context, 'All'),
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
                    onSeeAll: () => _onSeeAllEvents(context, 'All'),
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
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = upcomingEvents[index];
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
    final profile = context.watch<ProfileProvider>().profile;
    final displayName = profile?.displayName ?? 'Explorer';

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
        const RoleModeToggleChip(),
      ],
    );
  }
}
