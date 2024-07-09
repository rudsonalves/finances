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

class CustomBottomAppBarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int index;
  final String? tooltip;
  final void Function(int) changePage;

  const CustomBottomAppBarItem({
    super.key,
    required this.changePage,
    required this.icon,
    required this.index,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        changePage(index);
      },
      icon: Icon(
        icon,
        color: color,
      ),
    );
  }
}
