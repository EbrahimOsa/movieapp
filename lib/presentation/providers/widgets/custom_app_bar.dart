import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onSearchPressed;
  final VoidCallback onThemePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onSearchPressed,
    required this.onThemePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SafeArea(
        child: Row(
          children: [
            // App Title
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Search Button
            IconButton(
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search),
              tooltip: 'Search Movies',
            ),

            // Theme Toggle Button
            IconButton(
              onPressed: onThemePressed,
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
      ),
    );
  }
}
