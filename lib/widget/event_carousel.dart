import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/widget/featured_event_card.dart';
import 'package:event_managment_app/widget/nearby_event_card.dart';
import 'package:flutter/material.dart';

/// Reusable horizontal carousel with page indicator dots for Featured Events.
class FeaturedEventsCarousel extends StatefulWidget {
  final List<EventItem> events;
  final ValueChanged<EventItem> onEventTap;
  final double height;

  const FeaturedEventsCarousel({
    super.key,
    required this.events,
    required this.onEventTap,
    this.height = 230,
  });

  @override
  State<FeaturedEventsCarousel> createState() => _FeaturedEventsCarouselState();
}

class _FeaturedEventsCarouselState extends State<FeaturedEventsCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const EmptyEventsPlaceholder(
        message: 'No featured events match your filter.',
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final activeIndex = _currentPage.clamp(0, widget.events.length - 1);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.events.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: FeaturedEventCard(
                  event: event,
                  onTap: () => widget.onEventTap(event),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.events.length, (index) {
            final isActive = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: isActive ? 22 : 7,
              decoration: BoxDecoration(
                color: isActive ? scheme.primary : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Reusable horizontal scrolling carousel for "Events Near Me".
class NearbyEventsCarousel extends StatelessWidget {
  final List<EventItem> events;
  final ValueChanged<EventItem> onEventTap;

  const NearbyEventsCarousel({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyEventsPlaceholder(
        message: 'No nearby events match your filter.',
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final event = events[index];
          return NearbyEventCard(
            event: event,
            onTap: () => onEventTap(event),
          );
        },
      ),
    );
  }
}

/// Shown when a category or search filter returns zero events.
class EmptyEventsPlaceholder extends StatelessWidget {
  final String message;

  const EmptyEventsPlaceholder({super.key, required this.message});

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
            Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

