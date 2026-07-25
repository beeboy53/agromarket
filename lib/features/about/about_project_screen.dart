import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Describes the academic project itself — title, objective, and
/// scope. Useful to show during project defense.
class AboutProjectScreen extends StatelessWidget {
  const AboutProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aboutProject)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section(
              context,
              title: 'Project Title',
              body:
                  'Development of a Mobile Application for Real-Time '
                  'Agricultural Market Price Information in Nigeria.',
            ),
            _section(
              context,
              title: 'Objective',
              body:
                  'To design and implement a mobile application that '
                  'provides users with accessible, searchable, and '
                  'filterable agricultural commodity price information '
                  'across different markets and states in Nigeria, with '
                  'offline access and the ability for an administrator '
                  'to add new market price records.',
            ),
            _section(
              context,
              title: 'Scope',
              body:
                  '• Commodity categories: Grains, Tubers, Vegetables, '
                  'Legumes, Livestock\n'
                  '• Search and filter by state, market, and category\n'
                  '• Commodity details with price trend charts\n'
                  '• Favourite commodities with offline persistence\n'
                  '• Local user accounts (login/register) and an '
                  'admin role for adding new market prices\n'
                  '• Offline-first design using a local SQLite/web cache',
            ),
            _section(
              context,
              title: 'Tools & Technologies',
              body:
                  '• Flutter & Dart (single codebase for Android and Web)\n'
                  '• Provider (state management)\n'
                  '• SQLite via sqflite (mobile) / SharedPreferences (web)\n'
                  '• fl_chart (data visualisation)\n'
                  '• Local JSON as the initial data source, structured so '
                  'it can later be replaced by a real backend API without '
                  'changing any screen code.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, {required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5, color: AppColors.textPrimaryLight),
          ),
        ],
      ),
    );
  }
}