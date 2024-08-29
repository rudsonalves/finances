// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class TimePickerForm extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const TimePickerForm({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  State<TimePickerForm> createState() => _TimePickerFormState();
}

class _TimePickerFormState extends State<TimePickerForm> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = formatTimeOfDay(TimeOfDay.now());
  }

  String formatTimeOfDay(TimeOfDay time) {
    String timeStr = time.toString();
    return timeStr.substring(timeStr.indexOf('(') + 1, timeStr.indexOf(')'));
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
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            setState(() {
              widget.controller.text = formatTimeOfDay(picked);
            });
          }
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: const Icon(Icons.schedule),
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
