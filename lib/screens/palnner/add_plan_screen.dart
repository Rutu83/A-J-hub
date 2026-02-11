import 'dart:convert'; // Import for jsonEncode

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- ENUMS ---
enum PlanCategory { DAY_MOVEMENT, MONTH_SCHEDULE, CELEBRATION, HEALTH_REMINDER }

enum HealthSubCategory { MEDICINE, WATER }

enum MedicineSchedule {
  BREAKFAST,
  BEFORE_LUNCH,
  AFTER_LUNCH,
  BEFORE_DINNER,
  AFTER_DINNER,
  BEFORE_SLEEP
}

enum MonthScheduleType { PHYSICAL, ONLINE_MEETING }

enum MeetingPlatform { ZOOM, GOOGLE_MEET, OTHER }

enum Weekday { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }

// Helper extensions
extension MedicineScheduleExtension on MedicineSchedule {
  String get displayName {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // --- MODIFIED CODE START ---
  // Default times for the time picker for a better user experience
  TimeOfDay get defaultTime {
    switch (this) {
      case MedicineSchedule.BREAKFAST:
        return const TimeOfDay(hour: 8, minute: 0);
      case MedicineSchedule.BEFORE_LUNCH:
        return const TimeOfDay(hour: 12, minute: 30);
      case MedicineSchedule.AFTER_LUNCH:
        return const TimeOfDay(hour: 14, minute: 0);
      case MedicineSchedule.BEFORE_DINNER:
        return const TimeOfDay(hour: 18, minute: 30);
      case MedicineSchedule.AFTER_DINNER:
        return const TimeOfDay(hour: 20, minute: 0);
      case MedicineSchedule.BEFORE_SLEEP:
        return const TimeOfDay(hour: 22, minute: 0);
    }
  }
// --- MODIFIED CODE END ---
}

extension MeetingPlatformExtension on MeetingPlatform {
  String get displayName => name == 'GOOGLE_MEET'
      ? 'Google Meet'
      : name[0] + name.substring(1).toLowerCase();
}

extension WeekdayExtension on Weekday {
  String get displayName {
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  String get shortName {
    return name.substring(0, 3);
  }
}

class AddPlanScreen extends StatefulWidget {
  const AddPlanScreen({super.key});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- FORM STATE VARIABLES ---
  PlanCategory _selectedCategory = PlanCategory.MONTH_SCHEDULE;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  String? _selectedReminder;

  // --- DAY MOVEMENT STATE ---
  final Set<Weekday> _selectedWeekdays = {};

  // --- HEALTH REMINDER STATE ---
  HealthSubCategory _selectedHealthSubCategory = HealthSubCategory.MEDICINE;
  // --- MODIFIED CODE START ---
  // Changed from a Set to a Map to store the time for each schedule.
  final Map<MedicineSchedule, TimeOfDay> _selectedMedicineSchedules = {};
  // --- MODIFIED CODE END ---
  final TextEditingController _waterStartTimeController =
      TextEditingController();
  final TextEditingController _waterEndTimeController = TextEditingController();
  TimeOfDay? _waterStartTime;
  TimeOfDay? _waterEndTime;
  int _waterIntervalMinutes = 120;

  // --- MONTH SCHEDULE STATE ---
  MonthScheduleType _monthScheduleType = MonthScheduleType.PHYSICAL;
  MeetingPlatform _meetingPlatform = MeetingPlatform.ZOOM;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  final TextEditingController _meetingPasswordController =
      TextEditingController();
  final TextEditingController _zoomIdController = TextEditingController();

  // --- STYLING CONSTANTS ---
  static const Color primaryRed = Color(0xFFE53935);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF757575);

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    _waterStartTimeController.dispose();
    _waterEndTimeController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    _meetingPasswordController.dispose();
    _zoomIdController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == PlanCategory.DAY_MOVEMENT &&
        _selectedWeekdays.isEmpty &&
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a date for a one-time movement.'),
          backgroundColor: Colors.orangeAccent));
      return;
    }

    if (_selectedCategory == PlanCategory.HEALTH_REMINDER) {
      if (_selectedHealthSubCategory == HealthSubCategory.MEDICINE) {
        if (_selectedMedicineSchedules.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Please select and set a time for at least one medicine schedule.'),
              backgroundColor: Colors.orangeAccent));
          return;
        }
      } else {
        // WATER
        if (_waterStartTime == null || _waterEndTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Please select a start and end time for water reminders.'),
              backgroundColor: Colors.orangeAccent));
          return;
        }
        final startTimeInMinutes =
            _waterStartTime!.hour * 60 + _waterStartTime!.minute;
        final endTimeInMinutes =
            _waterEndTime!.hour * 60 + _waterEndTime!.minute;

        if (startTimeInMinutes >= endTimeInMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Start time must be earlier than end time.'),
              backgroundColor: Colors.orangeAccent));
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    // --- BUILD PAYLOAD ---
    final Map<String, dynamic> payload = {
      'category': _selectedCategory.name,
      'title': _titleController.text,
      'is_recurring': 0,
    };

    if (_selectedCategory == PlanCategory.HEALTH_REMINDER) {
      payload['sub_category'] = _selectedHealthSubCategory.name;
      payload['is_recurring'] = 1;
      payload['event_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (_selectedHealthSubCategory == HealthSubCategory.MEDICINE) {
        // --- MODIFIED CODE START ---
        // The logic is now more robust, using user-defined times.
        payload['reminder_setting'] = 'ON_SCHEDULE';

        // Find the earliest TimeOfDay selected by the user.
        final TimeOfDay earliestTime =
            _selectedMedicineSchedules.values.reduce((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes < bMinutes ? a : b;
        });

        // Set event_time to the earliest user-defined schedule for the day.
        payload['event_time'] =
            '${earliestTime.hour.toString().padLeft(2, '0')}:${earliestTime.minute.toString().padLeft(2, '0')}:00';

        // Create the JSON for reminder_schedule, mapping schedule names to their set times.
        final schedulePayload = _selectedMedicineSchedules.map((key, value) {
          final formattedTime =
              '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:00';
          return MapEntry(key.name, formattedTime);
        });
        payload['reminder_schedule'] = jsonEncode(schedulePayload);
        // --- MODIFIED CODE END ---
      } else {
        // WATER
        payload['reminder_schedule'] = jsonEncode({
          'start_time':
              '${_waterStartTime!.hour.toString().padLeft(2, '0')}:${_waterStartTime!.minute.toString().padLeft(2, '0')}:00',
          'end_time':
              '${_waterEndTime!.hour.toString().padLeft(2, '0')}:${_waterEndTime!.minute.toString().padLeft(2, '0')}:00',
          'interval_minutes': _waterIntervalMinutes,
        });
        payload['reminder_setting'] = 'Every $_waterIntervalMinutes minutes';
        payload['event_time'] =
            '${_waterStartTime!.hour.toString().padLeft(2, '0')}:${_waterStartTime!.minute.toString().padLeft(2, '0')}:00';
      }

      if (_notesController.text.isNotEmpty) {
        payload['notes'] = _notesController.text;
      }
    } else if (_selectedCategory == PlanCategory.MONTH_SCHEDULE) {
      payload['reminder_setting'] = _selectedReminder!;
      payload['event_date'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      payload['event_time'] = DateFormat('HH:mm:ss').format(_selectedTime!);
      if (_notesController.text.isNotEmpty) {
        payload['notes'] = _notesController.text;
      }

      if (_monthScheduleType == MonthScheduleType.PHYSICAL) {
        if (_locationController.text.isNotEmpty) {
          payload['link_or_location'] = jsonEncode({
            'type': _monthScheduleType.name,
            'address': _locationController.text,
          });
        }
      } else {
        Map<String, String> meetingDetails = {
          'type': _monthScheduleType.name,
          'platform': _meetingPlatform.name,
        };
        if (_meetingLinkController.text.isNotEmpty) {
          meetingDetails['link'] = _meetingLinkController.text;
        }
        if (_zoomIdController.text.isNotEmpty) {
          meetingDetails['zoom_id'] = _zoomIdController.text;
        }
        if (_meetingPasswordController.text.isNotEmpty) {
          meetingDetails['password'] = _meetingPasswordController.text;
        }
        payload['link_or_location'] = jsonEncode(meetingDetails);
      }
    } else {
      // DAY_MOVEMENT & CELEBRATION
      payload['reminder_setting'] = _selectedReminder!;

      if (_selectedCategory == PlanCategory.DAY_MOVEMENT) {
        if (_selectedWeekdays.isNotEmpty) {
          payload['is_recurring'] = 1;
          payload['reminder_schedule'] =
              jsonEncode(_selectedWeekdays.map((d) => d.name).toList());
        } else {
          if (_selectedDate != null) {
            payload['event_date'] =
                DateFormat('yyyy-MM-dd').format(_selectedDate!);
          }
        }
      } else {
        // CELEBRATION
        if (_selectedDate != null) {
          payload['event_date'] =
              DateFormat('yyyy-MM-dd').format(_selectedDate!);
        }
      }

      if (_selectedTime != null) {
        payload['event_time'] = DateFormat('HH:mm:ss').format(_selectedTime!);
      }
    }

    // --- API Call ---
    await createPlan(
      payload: payload,
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green));
        if (mounted) Navigator.pop(context);
      },
      onFail: (errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage), backgroundColor: Colors.redAccent));
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create a New Plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1.0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Plan Type'),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 30),
              _buildSectionTitle('Plan Details'),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _titleController,
                label: 'Title',
                hint: _getHintTextForTitle(),
                icon: _getIconForTitle(),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              if (_selectedCategory == PlanCategory.MONTH_SCHEDULE) ...[
                _buildMonthScheduleFields(),
              ] else if (_selectedCategory == PlanCategory.DAY_MOVEMENT) ...[
                _buildDayMovementFields(),
              ] else if (_selectedCategory == PlanCategory.CELEBRATION) ...[
                _buildDatePickerField(),
                const SizedBox(height: 20),
              ] else if (_selectedCategory == PlanCategory.HEALTH_REMINDER) ...[
                _buildHealthReminderFields(),
              ],
              if (_selectedCategory != PlanCategory.HEALTH_REMINDER) ...[
                const SizedBox(height: 20),
                _buildReminderDropdown(),
              ],
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  String _getHintTextForTitle() {
    switch (_selectedCategory) {
      case PlanCategory.DAY_MOVEMENT:
        return 'e.g., Gym, Yoga, Morning Walk';
      case PlanCategory.MONTH_SCHEDULE:
        return 'e.g., Team Sync, Dentist Appointment';
      case PlanCategory.CELEBRATION:
        return 'e.g., Mom\'s Birthday';
      case PlanCategory.HEALTH_REMINDER:
        return _selectedHealthSubCategory == HealthSubCategory.MEDICINE
            ? 'e.g., Paracetamol, Vitamins'
            : 'e.g., Daily Hydration Goal';
    }
  }

  IconData _getIconForTitle() {
    switch (_selectedCategory) {
      case PlanCategory.HEALTH_REMINDER:
        return Icons.medication_outlined;
      case PlanCategory.MONTH_SCHEDULE:
        return Icons.edit_calendar_outlined;
      default:
        return Icons.edit_note;
    }
  }

  Widget _buildCategorySelector() {
    return Row(
      children: [
        Expanded(
            child: _buildCategoryChip(
                'Day Movement', Icons.sunny, PlanCategory.DAY_MOVEMENT)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildCategoryChip('Month Schedule', Icons.calendar_month,
                PlanCategory.MONTH_SCHEDULE)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildCategoryChip(
                'Celebration', Icons.cake, PlanCategory.CELEBRATION)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildCategoryChip('Health', Icons.medical_services,
                PlanCategory.HEALTH_REMINDER)),
      ],
    );
  }

  Widget _buildCategoryChip(
      String label, IconData icon, PlanCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = category;
        _formKey.currentState?.reset();
        _titleController.clear();
        _dateController.clear();
        _timeController.clear();
        _notesController.clear();
        _locationController.clear();
        _meetingLinkController.clear();
        _meetingPasswordController.clear();
        _zoomIdController.clear();
        _selectedDate = null;
        _selectedTime = null;
        _selectedReminder = null;
        _selectedMedicineSchedules.clear();
        _selectedWeekdays.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
            color: isSelected ? primaryRed : lightGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? primaryRed : Colors.grey.shade300)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : darkGray),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                color: isSelected ? Colors.white : darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayMovementFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimePickerField(),
        const SizedBox(height: 20),
        _buildSectionTitle('Repeat On'),
        const SizedBox(height: 16),
        _buildWeekdaySelector(),
        const SizedBox(height: 20),
        if (_selectedWeekdays.isEmpty) ...[
          Text('Or select a specific date for a one-time movement:',
              style: TextStyle(color: darkGray)),
          const SizedBox(height: 8),
          _buildDatePickerField(isOptional: true),
        ],
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    return Center(
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center, // Center the chips in each line
        children: Weekday.values.map((day) {
          final isSelected = _selectedWeekdays.contains(day);
          return ChoiceChip(
            label: Text(day.displayName), // Use full name like "Monday"
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : darkGray,
              fontWeight: FontWeight.w600,
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedWeekdays.add(day);
                } else {
                  _selectedWeekdays.remove(day);
                }
                // If a recurring day is selected, clear the one-time date.
                _dateController.clear();
                _selectedDate = null;
              });
            },
            // Appearance
            selectedColor: primaryRed,
            backgroundColor: lightGray,
            // A stadium (pill) shape fits the full day name nicely
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? primaryRed : Colors.grey.shade300,
                width: 0.6,
              ),
            ),
            // Add padding inside the chip for a roomier feel
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            // Use a custom icon for the checkmark for a more attractive look
            avatar: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
            showCheckmark: false, // We use a custom avatar, so hide the default
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthScheduleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePickerField(),
        const SizedBox(height: 20),
        _buildTimePickerField(),
        const SizedBox(height: 20),
        Center(
          child: ToggleButtons(
            isSelected: [
              _monthScheduleType == MonthScheduleType.PHYSICAL,
              _monthScheduleType == MonthScheduleType.ONLINE_MEETING
            ],
            onPressed: (index) => setState(() => _monthScheduleType = index == 0
                ? MonthScheduleType.PHYSICAL
                : MonthScheduleType.ONLINE_MEETING),
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: primaryRed,
            color: primaryRed,
            borderColor: primaryRed,
            selectedBorderColor: primaryRed,
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 18),
                    SizedBox(width: 8),
                    Text('Physical Event')
                  ])),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Icon(Icons.videocam, size: 18),
                    SizedBox(width: 8),
                    Text('Online Meeting')
                  ])),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_monthScheduleType == MonthScheduleType.PHYSICAL)
          _buildTextFormField(
            controller: _locationController,
            label: 'Address or Location',
            hint: 'e.g., 123 Main St, City Hall',
            icon: Icons.location_on_outlined,
          )
        else
          _buildOnlineMeetingFields(),
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _notesController,
          label: 'Notes / Agenda (Optional)',
          hint: 'e.g., Discuss Q3 performance',
          icon: Icons.list_alt,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildOnlineMeetingFields() {
    return Column(
      children: [
        DropdownButtonFormField<MeetingPlatform>(
          value: _meetingPlatform,
          decoration: _inputDecoration(
              label: 'Platform', icon: Icons.people_alt_outlined),
          items: MeetingPlatform.values
              .map(
                  (p) => DropdownMenuItem(value: p, child: Text(p.displayName)))
              .toList(),
          onChanged: (value) => setState(() => _meetingPlatform = value!),
        ),
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _meetingLinkController,
          label: 'Meeting Link (Optional)',
          hint: 'https://zoom.us/j/...',
          icon: Icons.link,
        ),
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _zoomIdController,
          label: 'Zoom ID (Optional)',
          hint: 'e.g., 812 3456 7890',
          icon: Icons.tag,
        ),
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _meetingPasswordController,
          label: 'Password / Passcode (Optional)',
          hint: 'e.g., 123456',
          icon: Icons.lock_outline,
        ),
      ],
    );
  }

  Widget _buildHealthReminderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ToggleButtons(
            isSelected: [
              _selectedHealthSubCategory == HealthSubCategory.MEDICINE,
              _selectedHealthSubCategory == HealthSubCategory.WATER
            ],
            onPressed: (index) {
              setState(() {
                _selectedHealthSubCategory = index == 0
                    ? HealthSubCategory.MEDICINE
                    : HealthSubCategory.WATER;
                _titleController.clear();
              });
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: primaryRed,
            color: primaryRed,
            borderColor: primaryRed,
            selectedBorderColor: primaryRed,
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Medicine')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Water')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // --- THIS IS THE FIX ---
        // We use the spread operator '...' to insert the list of widgets
        // directly into this Column, avoiding a nested Column.
        if (_selectedHealthSubCategory == HealthSubCategory.MEDICINE)
          ..._buildMedicineReminderFields()
        else
          _buildWaterReminderFields(),
        // --- END OF FIX ---
        const SizedBox(height: 20),
        _buildTextFormField(
          controller: _notesController,
          label: 'Notes (Optional)',
          hint: 'e.g., Take with food, store in fridge',
          icon: Icons.notes_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // --- MODIFIED CODE START ---
  // This entire widget has been updated to handle the time-picking logic.
// MODIFIED WIDGET
// This method now returns a List<Widget> instead of a single Column widget.
  List<Widget> _buildMedicineReminderFields() {
    // Helper to format TimeOfDay to a readable string like "08:30 AM"
    String formatTimeOfDay(TimeOfDay tod) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm(); //"6:00 AM"
      return format.format(dt);
    }

    // Handles the tap on a medicine chip
    Future<void> _handleMedicineChipTap(MedicineSchedule schedule) async {
      final bool isCurrentlySelected =
          _selectedMedicineSchedules.containsKey(schedule);

      if (isCurrentlySelected) {
        setState(() {
          _selectedMedicineSchedules.remove(schedule);
        });
      } else {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: schedule.defaultTime,
          helpText: 'Set time for ${schedule.displayName}',
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: primaryRed)),
            child: child!,
          ),
        );

        if (pickedTime != null) {
          setState(() {
            _selectedMedicineSchedules[schedule] = pickedTime;
          });
        }
      }
    }

    // --- THIS IS THE FIX ---
    // Instead of returning a Column, we return a List of its children.
    return [
      _buildSectionTitle('Intake Schedule'),
      const SizedBox(height: 8),
      Text('Tap a schedule to set a reminder time for it.',
          style: TextStyle(color: darkGray, fontSize: 14)),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8.0,
        runSpacing: 10.0,
        children: MedicineSchedule.values.map((schedule) {
          final isSelected = _selectedMedicineSchedules.containsKey(schedule);
          final selectedTime = _selectedMedicineSchedules[schedule];

          return GestureDetector(
            onTap: () => _handleMedicineChipTap(schedule),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? primaryRed : lightGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryRed : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? Colors.white : darkGray,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        schedule.displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : darkGray),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        Text(
                          formatTimeOfDay(selectedTime!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      )
    ];
    // --- END OF FIX ---
  } // --- MODIFIED CODE END ---

  Widget _buildWaterReminderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reminder Period & Frequency'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildWaterTimePickerField(
                    controller: _waterStartTimeController,
                    label: 'Start Time',
                    onTimePicked: (time) {
                      setState(() {
                        _waterStartTime = time;
                        final now = DateTime.now();
                        final dt = DateTime(now.year, now.month, now.day,
                            time.hour, time.minute);
                        _waterStartTimeController.text =
                            DateFormat('hh:mm a').format(dt);
                      });
                    })),
            const SizedBox(width: 16),
            Expanded(
                child: _buildWaterTimePickerField(
                    controller: _waterEndTimeController,
                    label: 'End Time',
                    onTimePicked: (time) {
                      setState(() {
                        _waterEndTime = time;
                        final now = DateTime.now();
                        final dt = DateTime(now.year, now.month, now.day,
                            time.hour, time.minute);
                        _waterEndTimeController.text =
                            DateFormat('hh:mm a').format(dt);
                      });
                    })),
          ],
        ),
        const SizedBox(height: 20),
        _buildWaterIntervalDropdown(),
      ],
    );
  }

  Widget _buildWaterTimePickerField(
      {required TextEditingController controller,
      required String label,
      required Function(TimeOfDay) onTimePicked}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Required' : null,
      decoration: _inputDecoration(label: label, icon: Icons.access_time),
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: primaryRed)),
            child: child!,
          ),
        );
        if (pickedTime != null) onTimePicked(pickedTime);
      },
    );
  }

  Widget _buildWaterIntervalDropdown() {
    final intervalOptions = {
      30: 'Every 30 minutes',
      60: 'Every 1 hour',
      120: 'Every 2 hours',
      180: 'Every 3 hours',
      240: 'Every 4 hours',
    };

    return DropdownButtonFormField<int>(
      value: _waterIntervalMinutes,
      validator: (value) => value == null ? 'Please select an interval' : null,
      decoration:
          _inputDecoration(label: 'Remind me...', icon: Icons.timer_outlined),
      items: intervalOptions.entries
          .map((entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)))
          .toList(),
      onChanged: (value) => setState(() => _waterIntervalMinutes = value!),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: darkGray),
      filled: true,
      fillColor: lightGray,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2)),
      labelStyle: const TextStyle(color: darkGray),
    );
  }

  Widget _buildTextFormField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
    );
  }

  Widget _buildDatePickerField({bool isOptional = false}) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      validator: (v) {
        if (isOptional) return null;
        return (v == null || v.isEmpty) ? 'Date is required' : null;
      },
      decoration: _inputDecoration(
          label: 'Date', icon: Icons.calendar_today, hint: 'Select a date'),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: primaryRed)),
              child: child!),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _dateController.text = DateFormat('MMMM dd, yyyy').format(picked);
            _selectedWeekdays.clear();
          });
        }
      },
    );
  }

  Widget _buildTimePickerField() {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      validator: (v) => (v == null || v.isEmpty) ? 'Time is required' : null,
      decoration: _inputDecoration(
          label: 'Time', icon: Icons.access_time, hint: 'Select a time'),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime != null
              ? TimeOfDay.fromDateTime(_selectedTime!)
              : TimeOfDay.now(),
          builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: primaryRed)),
              child: child!),
        );
        if (picked != null) {
          final now = DateTime.now();
          final dt = DateTime(
              now.year, now.month, now.day, picked.hour, picked.minute);
          setState(() {
            _selectedTime = dt;
            _timeController.text = DateFormat('hh:mm a').format(dt);
          });
        }
      },
    );
  }

  Widget _buildReminderDropdown() {
    List<String> reminderOptions = [
      'At time of event',
      '5 minutes before',
      '15 minutes before',
      '1 hour before',
      '1 day before',
      '1 week before'
    ];
    return DropdownButtonFormField<String>(
      value: _selectedReminder,
      validator: (v) => v == null ? 'Please select a reminder' : null,
      decoration:
          _inputDecoration(label: 'Set Reminder', icon: Icons.notifications),
      items: reminderOptions
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => _selectedReminder = v),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : const Text('SAVE PLAN',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
      ),
    );
  }
}
