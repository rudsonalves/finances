import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/constants/themes/app_text_styles.dart';

class DateTimePickerForm extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool enable;

  const DateTimePickerForm({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.enable = true,
  });

  @override
  State<DateTimePickerForm> createState() => _DateTimePickerFormState();
}

class _DateTimePickerFormState extends State<DateTimePickerForm> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      date = DateTime.parse(widget.controller.text);
      time = TimeOfDay.fromDateTime(DateTime.parse(widget.controller.text));
    } else {
      widget.controller.text = formatDate(date, time);
    }
  }

  String formatDate(DateTime date, TimeOfDay time) {
    return '${formatter.format(date)}T${formatTime(time)}:00.000000';
  }

  String formatTime(TimeOfDay time) {
    String hour = '${time.hour < 10 ? '0${time.hour}' : time.hour}';
    String minute = '${time.minute < 10 ? '0${time.minute}' : time.minute}';
    return '$hour:$minute';
  }

  Future<void> _onTapShowDatePicker() async {
    await showDatePicker(
      context: context,
      firstDate: DateTime(2005),
      initialDate: date,
      lastDate: DateTime(2040),
    ).then((selectDate) async {
      if (selectDate != null) date = selectDate;

      final TimeOfDay? selectTime = await showTimePicker(
        context: context,
        initialTime: time,
      );

      if (selectTime != null) time = selectTime;
    });

    setState(() {
      widget.controller.text = formatDate(date, time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: InkWell(
        onTap: widget.enable ? _onTapShowDatePicker : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormat.yMMMd().format(date)} - ${formatTime(time)}h',
                style: AppTextStyles.textStyleMedium16,
              ),
              const Row(
                children: [
                  Icon(Icons.calendar_month),
                  Icon(Icons.schedule),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
