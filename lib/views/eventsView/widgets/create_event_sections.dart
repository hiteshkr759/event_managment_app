import 'package:event_managment_app/models/event_model.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Card 1 of CreateEventPage: Offline vs Online mode selector and dynamic fields.
class EventModeFormCard extends StatelessWidget {
  const EventModeFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final mode = eventsProvider.createMode;
    final isOnline = mode == 'online';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Select Event Type (Offline or Online)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'offline',
                    icon: Icon(Icons.location_on_outlined),
                    label: Text('Offline (In-Person)'),
                  ),
                  ButtonSegment<String>(
                    value: 'online',
                    icon: Icon(Icons.videocam_outlined),
                    label: Text('Online (Virtual)'),
                  ),
                ],
                selected: <String>{mode},
                onSelectionChanged: (selection) {
                  eventsProvider.setCreateMode(selection.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            if (!isOnline) ...[
              AuthTextField(
                controller: eventsProvider.venueController,
                label: 'Venue Name',
                hint: 'e.g. Grand Convention Center',
                prefixIcon: Icons.business_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (eventsProvider.createMode == 'offline' &&
                      (val == null || val.trim().isEmpty)) {
                    return 'Venue name is required for Offline events';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: eventsProvider.addressController,
                label: 'City & Street Address',
                hint: 'e.g. Sector 4, Downtown',
                prefixIcon: Icons.map_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (eventsProvider.createMode == 'offline' &&
                      (val == null || val.trim().isEmpty)) {
                    return 'City / Address is required for Offline events';
                  }
                  return null;
                },
              ),
            ] else ...[
              AuthTextField(
                controller: eventsProvider.platformController,
                label: 'Online Platform',
                hint: 'e.g. Zoom, Google Meet, YouTube Live',
                prefixIcon: Icons.laptop_mac_outlined,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (eventsProvider.createMode == 'online' &&
                      (val == null || val.trim().isEmpty)) {
                    return 'Platform name is required for Online events';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: eventsProvider.meetingUrlController,
                label: 'Meeting / Stream Link URL',
                hint: 'https://meet.google.com/...',
                prefixIcon: Icons.link_rounded,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (eventsProvider.createMode == 'online' &&
                      (val == null || val.trim().isEmpty)) {
                    return 'Meeting link is required for Online events';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card 2 of CreateEventPage: Title, category, date/time, pricing, description, and submit button.
class EventDetailsFormCard extends StatelessWidget {
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onSubmit;

  const EventDetailsFormCard({
    super.key,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eventsProvider = context.watch<EventsProvider>();
    final categories = eventCategories.where((c) => c != 'All').toList();

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Event Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: eventsProvider.titleController,
              label: 'Event Title',
              hint: 'e.g. Flutter Forward Extended Meetup',
              prefixIcon: Icons.event_note_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Text('Category', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: cat == eventsProvider.createCategory,
                  onSelected: (_) => eventsProvider.setCreateCategory(cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: eventsProvider.dateController,
                    label: 'Date',
                    hint: 'Nov 15, 2026',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: onPickDate,
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Enter a date'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AuthTextField(
                    controller: eventsProvider.timeController,
                    label: 'Start Time',
                    hint: '06:00 PM',
                    prefixIcon: Icons.access_time_outlined,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.schedule),
                      onPressed: onPickTime,
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Enter a time'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Free Event'),
              subtitle: Text(
                eventsProvider.createIsFree
                    ? 'Anyone can attend for free'
                    : 'Paid ticket required',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              value: eventsProvider.createIsFree,
              onChanged: eventsProvider.setCreateIsFree,
            ),
            if (!eventsProvider.createIsFree)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AuthTextField(
                  controller: eventsProvider.priceController,
                  label: 'Ticket Price (USD)',
                  hint: '25',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (!eventsProvider.createIsFree &&
                        (val == null || val.trim().isEmpty)) {
                      return 'Enter ticket price';
                    }
                    return null;
                  },
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Highlight in Featured Carousel'),
              subtitle: Text(
                'Show this event in the top Featured carousel on Home Page',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              value: eventsProvider.createIsFeatured,
              onChanged: eventsProvider.setCreateIsFeatured,
            ),
            const SizedBox(height: 8),
            AuthTextField(
              controller: eventsProvider.bannerUrlController,
              label: 'Banner Image URL (Optional)',
              hint: 'https://images.unsplash.com/...',
              prefixIcon: Icons.image_outlined,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: eventsProvider.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Event Description',
                hintText:
                    'Describe agenda, speakers, and what attendees will learn...',
                alignLabelWithHint: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.error, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.error, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 5) {
                  return 'Please enter a short description';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: eventsProvider.isCreating ? null : onSubmit,
                icon: eventsProvider.isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish_rounded),
                label: Text(
                  eventsProvider.isCreating
                      ? 'Publishing Event...'
                      : 'Publish Event',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

