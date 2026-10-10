import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Opens a modal bottom sheet listing the people attending [event].
void showAttendeesListSheet(BuildContext context, EventItem event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => AttendeesListSheet(event: event),
  );
}

/// Modal bottom sheet displaying the list of attendees for an event.
class AttendeesListSheet extends StatelessWidget {
  final EventItem event;

  const AttendeesListSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = context.watch<ProfileProvider>().isAdmin;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendees (${event.attendees})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Admin View (Emails Visible)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: event.attendeeList.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final attendee = event.attendeeList[index];
                final initial = attendee.name.isNotEmpty
                    ? attendee.name[0].toUpperCase()
                    : '?';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: attendee.avatarUrl != null
                        ? NetworkImage(attendee.avatarUrl!)
                        : null,
                    child: attendee.avatarUrl == null
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    attendee.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isAdmin
                        ? '${attendee.email} • ${attendee.registeredAtLabel}'
                        : attendee.registeredAtLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                );
              },
            ),
          ),
          if (event.attendees > event.attendeeList.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '+ ${event.attendees - event.attendeeList.length} more registered attendees',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

