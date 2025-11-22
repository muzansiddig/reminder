import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'app_constant.dart';
import 'reminder_model.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  ReminderType _selectedType = ReminderType.time;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  ReminderCategory _selectedCategory = ReminderCategory.personal;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final newReminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        notes: _notesController.text,
        type: _selectedType,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        location: _locationController.text,
        category: _selectedCategory,
      );
      Navigator.pop(context, newReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Reminder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: AppConstant.BACKGROUND_COLOR,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Title', 'Enter reminder title'),
              const SizedBox(height: AppConstant.PADDING_MEDIUM),
              _buildTextField(_notesController, 'Notes (Optional)', 'Add some details', isRequired: false),
              const SizedBox(height: AppConstant.PADDING_LARGE),
              _buildTypeSelector(),
              const SizedBox(height: AppConstant.PADDING_LARGE),
              if (_selectedType == ReminderType.time) ...[
                _buildDateTimePickers(),
                const SizedBox(height: AppConstant.PADDING_LARGE),
              ] else ...[
                 _buildTextField(_locationController, 'Location', 'Enter a place or address'),
                 const SizedBox(height: AppConstant.PADDING_LARGE),
              ],
              _buildCategorySelector(),
              const SizedBox(height: AppConstant.PADDING_LARGE * 2),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
        ),
        filled: true,
        fillColor: AppConstant.SURFACE_COLOR,
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a ${label.toLowerCase()}';
        }
        return null;
      } : null,
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reminder Type', style: GoogleFonts.poppins(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.w500)),
        const SizedBox(height: AppConstant.PADDING_SMALL),
        SegmentedButton<ReminderType>(
          segments: const [
            ButtonSegment(value: ReminderType.time, label: Text('Time'), icon: Icon(Icons.timer)),
            ButtonSegment(value: ReminderType.location, label: Text('Location'), icon: Icon(Icons.location_on)),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<ReminderType> newSelection) {
            setState(() {
              _selectedType = newSelection.first;
            });
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: AppConstant.SURFACE_COLOR,
            selectedBackgroundColor: AppConstant.PRIMARY_COLOR,
            selectedForegroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text('Date & Time', style: GoogleFonts.poppins(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.w500)),
         const SizedBox(height: AppConstant.PADDING_SMALL),
         Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
                     filled: true, fillColor: AppConstant.SURFACE_COLOR,
                  ),
                  child: Text(_selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : 'Select Date'),
                ),
              ),
            ),
            const SizedBox(width: AppConstant.PADDING_MEDIUM),
             Expanded(
              child: InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
                     filled: true, fillColor: AppConstant.SURFACE_COLOR,
                  ),
                  child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Select Time'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: GoogleFonts.poppins(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.w500)),
        const SizedBox(height: AppConstant.PADDING_SMALL),
        DropdownButtonFormField<ReminderCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
            ),
            filled: true,
            fillColor: AppConstant.SURFACE_COLOR,
          ),
          items: ReminderCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.name.capitalize()),
            );
          }).toList(),
          onChanged: (ReminderCategory? newValue) {
            if(newValue != null) {
              setState(() {
              _selectedCategory = newValue;
            });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveReminder,
        icon: const Icon(Icons.save),
        label: const Text('Save Reminder'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_MEDIUM),
          textStyle: GoogleFonts.poppins(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
          ),
          backgroundColor: AppConstant.PRIMARY_COLOR,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}