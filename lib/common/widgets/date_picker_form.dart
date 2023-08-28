import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerForm extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const DatePickerForm({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  State<DatePickerForm> createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    widget.controller.text = formatter.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: TextFormField(
        readOnly: true,
        validator: widget.validator,
        controller: widget.controller,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2005),
            initialDate: DateTime.now(),
            lastDate: DateTime(2040),
          );
          if (picked != null) {
            setState(() {
              widget.controller.text = formatter.format(picked);
            });
          }
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: const Icon(Icons.calendar_month),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          labelText: widget.labelText.toUpperCase(),
        ),
      ),
    );
  }
}
