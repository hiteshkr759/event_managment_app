import 'package:flutter/material.dart';

/// Reusable footer widget for server-side paginated event lists.
///
/// **Purpose:**
/// Displays the current pagination status at the bottom of a scrollable event
/// list:
/// - A loading spinner while the next page is being fetched from Supabase.
/// - A **"Load More Events"** button when additional pages exist on the server
///   (also triggered automatically by scrolling to the bottom).
/// - A subtle completion message once all server pages have been loaded.
///
/// **How it works:**
/// Receives [isLoadingMore], [hasMore], [loadedCount], [currentPage], and an
/// [onLoadMore] callback from the parent screen watching `EventsProvider`.
class PaginationFooter extends StatelessWidget {
  /// Whether the next page is currently being fetched from Supabase.
  final bool isLoadingMore;

  /// Whether more pages are available on the server.
  final bool hasMore;

  /// Total number of events loaded so far across all fetched pages.
  final int loadedCount;

  /// Zero-based index of the last loaded page.
  final int currentPage;

  /// Callback triggered when the user taps the "Load More Events" button.
  final VoidCallback onLoadMore;

  /// Creates a [PaginationFooter] widget.
  const PaginationFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    required this.loadedCount,
    required this.currentPage,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (loadedCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      child: Center(
        child: isLoadingMore
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Loading page ${currentPage + 2} from Supabase...',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : hasMore
            ? OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more_rounded),
                label: Text(
                  'Load More Events (Loaded $loadedCount • Page ${currentPage + 1})',
                ),
              )
            : Text(
                'You have reached the end • $loadedCount events loaded from server',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

