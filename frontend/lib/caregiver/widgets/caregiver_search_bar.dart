import 'package:flutter/material.dart';

class CaregiverSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CaregiverSearchBar({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search by name or specialty...",
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}