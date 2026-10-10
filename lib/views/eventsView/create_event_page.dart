import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/views/eventsView/widgets/create_event_sections.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  Future<void> _pickDate(
    BuildContext context,
    EventsProvider eventsProvider,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      const months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = picked.day.toString().padLeft(2, '0');
      eventsProvider.dateController.text =
          '${months[picked.month - 1]} $day, ${picked.year}';
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    EventsProvider eventsProvider,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && context.mounted) {
      eventsProvider.timeController.text = picked.format(context);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final eventsProvider = context.read<EventsProvider>();
    final isValid =
        eventsProvider.createEventFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the highlighted required fields.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final organizer = context.read<ProfileProvider>().profile;
    final created = await eventsProvider.submitNewEvent(organizer);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Created ${created.isOnline ? 'Online' : 'Offline'} event "${created.title}"!',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: eventsProvider.createEventFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderBanner(
                      badgeText: 'ADMIN • ORGANIZER',
                      title: 'Host an Event',
                      subtitle:
                          'Choose Offline (In-Person) or Online (Virtual) and publish your event to all users.',
                      icon: Icons.add_reaction_rounded,
                    ),
                    const SizedBox(height: 20),
                    const EventModeFormCard(),
                    const SizedBox(height: 16),
                    EventDetailsFormCard(
                      onPickDate: () => _pickDate(context, eventsProvider),
                      onPickTime: () => _pickTime(context, eventsProvider),
                      onSubmit: () => _submitForm(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
