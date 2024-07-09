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

class OfxInfoButton extends StatefulWidget {
  final String title;
  final String value;
  final void Function() callBack;

  const OfxInfoButton({
    super.key,
    required this.title,
    required this.value,
    required this.callBack,
  });

  @override
  State<OfxInfoButton> createState() => _OfxInfoButtonState();
}

class _OfxInfoButtonState extends State<OfxInfoButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.callBack,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(widget.value),
          ),
        ),
      ],
    );
  }
}
