import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown(
      {super.key, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
