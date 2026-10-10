import 'package:event_managment_app/notifiers/home_events_notifier.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: 'Nov 15, 2026',
  );
  final TextEditingController _timeController = TextEditingController(
    text: '06:00 PM',
  );
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _platformController = TextEditingController(
    text: 'Google Meet',
  );
  final TextEditingController _meetingUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(
    text: '25',
  );
  final TextEditingController _bannerUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _platformController.dispose();
    _meetingUrlController.dispose();
    _priceController.dispose();
    _bannerUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
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
      _dateController.text =
          '${months[picked.month - 1]} $day, ${picked.year}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && mounted) {
      _timeController.text = picked.format(context);
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the highlighted required fields.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final mode = createEventModeNotifier.value;
    final created = await createNewEvent(
      title: _titleController.text,
      category: createEventCategoryNotifier.value,
      eventMode: mode,
      date: _dateController.text,
      time: _timeController.text,
      description: _descriptionController.text,
      isFree: createEventIsFreeNotifier.value,
      priceText: _priceController.text,
      isFeatured: createEventIsFeaturedNotifier.value,
      venueName: _venueController.text,
      cityAndAddress: _addressController.text,
      onlinePlatform: _platformController.text,
      meetingUrl: _meetingUrlController.text,
      imageUrl: _bannerUrlController.text,
    );

    if (!mounted) return;
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
    final scheme = Theme.of(context).colorScheme;
    final categories = eventCategories.where((c) => c != 'All').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
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

                    // 1. Offline vs Online Mode Card
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: ValueListenableBuilder<String>(
                          valueListenable: createEventModeNotifier,
                          builder: (context, mode, _) {
                            final isOnline = mode == 'online';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1. Select Event Type (Offline or Online)',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                                      createEventModeNotifier.value =
                                          selection.first;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (!isOnline) ...[
                                  AuthTextField(
                                    controller: _venueController,
                                    label: 'Venue Name',
                                    hint: 'e.g. Grand Convention Center',
                                    prefixIcon: Icons.business_outlined,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) {
                                      if (createEventModeNotifier.value ==
                                              'offline' &&
                                          (val == null || val.trim().isEmpty)) {
                                        return 'Venue name is required for Offline events';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  AuthTextField(
                                    controller: _addressController,
                                    label: 'City & Street Address',
                                    hint: 'e.g. Sector 4, Downtown',
                                    prefixIcon: Icons.map_outlined,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) {
                                      if (createEventModeNotifier.value ==
                                              'offline' &&
                                          (val == null || val.trim().isEmpty)) {
                                        return 'City / Address is required for Offline events';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else ...[
                                  AuthTextField(
                                    controller: _platformController,
                                    label: 'Online Platform',
                                    hint: 'e.g. Zoom, Google Meet, YouTube Live',
                                    prefixIcon: Icons.laptop_mac_outlined,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) {
                                      if (createEventModeNotifier.value ==
                                              'online' &&
                                          (val == null || val.trim().isEmpty)) {
                                        return 'Platform name is required for Online events';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  AuthTextField(
                                    controller: _meetingUrlController,
                                    label: 'Meeting / Stream Link URL',
                                    hint: 'https://meet.google.com/...',
                                    prefixIcon: Icons.link_rounded,
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) {
                                      if (createEventModeNotifier.value ==
                                              'online' &&
                                          (val == null || val.trim().isEmpty)) {
                                        return 'Meeting link is required for Online events';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Event Details Card
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2. Event Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _titleController,
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
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<String>(
                              valueListenable: createEventCategoryNotifier,
                              builder: (context, selectedCat, _) {
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: categories.map((cat) {
                                    return ChoiceChip(
                                      label: Text(cat),
                                      selected: cat == selectedCat,
                                      onSelected: (_) {
                                        createEventCategoryNotifier.value = cat;
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: AuthTextField(
                                    controller: _dateController,
                                    label: 'Date',
                                    hint: 'Nov 15, 2026',
                                    prefixIcon: Icons.calendar_today_outlined,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.edit_calendar),
                                      onPressed: _pickDate,
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
                                        ? 'Enter a date'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AuthTextField(
                                    controller: _timeController,
                                    label: 'Start Time',
                                    hint: '06:00 PM',
                                    prefixIcon: Icons.access_time_outlined,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.schedule),
                                      onPressed: _pickTime,
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
                                        ? 'Enter a time'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: createEventIsFreeNotifier,
                              builder: (context, isFree, _) {
                                return Column(
                                  children: [
                                    SwitchListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('Free Event'),
                                      subtitle: Text(
                                        isFree
                                            ? 'Anyone can attend for free'
                                            : 'Paid ticket required',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                      value: isFree,
                                      onChanged: (val) {
                                        createEventIsFreeNotifier.value = val;
                                      },
                                    ),
                                    if (!isFree)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: AuthTextField(
                                          controller: _priceController,
                                          label: 'Ticket Price (USD)',
                                          hint: '25',
                                          prefixIcon:
                                              Icons.attach_money_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: (val) {
                                            if (!createEventIsFreeNotifier
                                                    .value &&
                                                (val == null ||
                                                    val.trim().isEmpty)) {
                                              return 'Enter ticket price';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: createEventIsFeaturedNotifier,
                              builder: (context, isFeatured, _) {
                                return SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Highlight in Featured Carousel',
                                  ),
                                  subtitle: Text(
                                    'Show this event in the top Featured carousel on Home Page',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: isFeatured,
                                  onChanged: (val) {
                                    createEventIsFeaturedNotifier.value = val;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            AuthTextField(
                              controller: _bannerUrlController,
                              label: 'Banner Image URL (Optional)',
                              hint: 'https://images.unsplash.com/...',
                              prefixIcon: Icons.image_outlined,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Event Description',
                                hintText:
                                    'Describe agenda, speakers, and what attendees will learn...',
                                alignLabelWithHint: true,
                                filled: true,
                                fillColor: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: scheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: scheme.error,
                                    width: 1.2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: scheme.error,
                                    width: 1.5,
                                  ),
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
                            ValueListenableBuilder<bool>(
                              valueListenable: createEventLoadingNotifier,
                              builder: (context, loading, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton.icon(
                                    onPressed: loading ? null : _submitForm,
                                    icon: loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.publish_rounded,
                                          ),
                                    label: Text(
                                      loading
                                          ? 'Publishing Event...'
                                          : 'Publish Event',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
