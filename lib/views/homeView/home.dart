import 'package:event_managment_app/notifiers/event_notifer.dart';
import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _featuredCarouselController = PageController(
    viewportFraction: 0.88,
  );
  int _currentFeaturedPage = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _featuredCarouselController.dispose();
    super.dispose();
  }

  void _showEventDetails(BuildContext context, EventItem event) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _EventBannerImage(event: event),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.near_me_outlined,
                    size: 15,
                    color: scheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.distance,
                    style: TextStyle(
                      color: scheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    event.price,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${event.date} • ${event.time}',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${event.attendees}+ attending',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registered for "${event.title}"!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Book / Register Now'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ValueListenableBuilder<String>(
              valueListenable: selectedCategoryNotifier,
              builder: (context, selectedCategory, _) {
                final featuredEvents = filterEventsByCategory(
                  featuredEventsNotifier.value,
                  selectedCategory,
                  searchQuery: _searchQuery,
                );
                final nearbyEvents = filterEventsByCategory(
                  nearbyEventsNotifier.value,
                  selectedCategory,
                  searchQuery: _searchQuery,
                );
                final upcomingEvents = filterEventsByCategory(
                  upcomingEventsNotifier.value,
                  selectedCategory,
                  searchQuery: _searchQuery,
                );

                return CustomScrollView(
                  slivers: [
                    // 1. Greeting + Search Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<Profile?>(
                              valueListenable: profileNotifier,
                              builder: (context, profile, _) {
                                final displayName =
                                    (profile?.fullName?.trim().isNotEmpty ??
                                        false)
                                    ? profile!.fullName!.trim()
                                    : 'Explorer';
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hello, $displayName 👋',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Discover Amazing Events',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: scheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Nearby',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _currentFeaturedPage = 0;
                                });
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Search events, locations, categories...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _currentFeaturedPage = 0;
                                          });
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

                    // 2. Horizontal Category List
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
                            final isSelected = category == selectedCategory;
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) {
                                selectedCategoryNotifier.value = category;
                                setState(() {
                                  _currentFeaturedPage = 0;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // 3. Featured Events Horizontal Carousel
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Featured Events',
                        subtitle: 'Handpicked highlights for you',
                        onSeeAll: () => eventNotifier.value = 1,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: featuredEvents.isEmpty
                          ? const _EmptyCarouselPlaceholder(
                              message: 'No featured events match your filter.',
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: isWide ? 260 : 230,
                                  child: PageView.builder(
                                    controller: _featuredCarouselController,
                                    itemCount: featuredEvents.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentFeaturedPage = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final event = featuredEvents[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        child: _FeaturedEventCarouselCard(
                                          event: event,
                                          onTap: () => _showEventDetails(
                                            context,
                                            event,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                    featuredEvents.length,
                                    (index) {
                                      final isActive =
                                          index ==
                                          (_currentFeaturedPage.clamp(
                                            0,
                                            featuredEvents.length - 1,
                                          ));
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        height: 7,
                                        width: isActive ? 22 : 7,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? scheme.primary
                                              : scheme.outlineVariant,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // 4. Events Near Me Horizontal Carousel
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Events Near Me',
                        subtitle: 'Happening around your location',
                        onSeeAll: () => eventNotifier.value = 1,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: nearbyEvents.isEmpty
                          ? const _EmptyCarouselPlaceholder(
                              message: 'No nearby events match your filter.',
                            )
                          : SizedBox(
                              height: 245,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: nearbyEvents.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final event = nearbyEvents[index];
                                  return _NearbyEventCard(
                                    event: event,
                                    onTap: () =>
                                        _showEventDetails(context, event),
                                  );
                                },
                              ),
                            ),
                    ),

                    // 5. Upcoming Events List of Items
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Upcoming Events',
                        subtitle: 'More events to explore',
                        onSeeAll: () => eventNotifier.value = 1,
                      ),
                    ),
                    if (upcomingEvents.isEmpty)
                      const SliverToBoxAdapter(
                        child: _EmptyCarouselPlaceholder(
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
                            return _UpcomingEventListTile(
                              event: event,
                              onTap: () => _showEventDetails(context, event),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
        ],
      ),
    );
  }
}

class _FeaturedEventCarouselCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const _FeaturedEventCarouselCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _EventBannerImage(event: event),
            // Dark gradient overlay for readable text
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(
                            color: event.gradientColors.first,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${event.date} • ${event.time}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.attendees}+',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyEventCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const _NearbyEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 115,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _EventBannerImage(event: event),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 12,
                              color: Colors.tealAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.distance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.price,
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.category.toUpperCase(),
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.date} • ${event.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingEventListTile extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const _UpcomingEventListTile({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: _EventBannerImage(event: event),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          event.price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.date} • ${event.time}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${event.location} (${event.distance})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventBannerImage extends StatelessWidget {
  final EventItem event;

  const _EventBannerImage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      event.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: event.gradientColors,
            ),
          ),
          child: Center(
            child: Icon(
              event.icon,
              size: 42,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCarouselPlaceholder extends StatelessWidget {
  final String message;

  const _EmptyCarouselPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, color: scheme.outline, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

