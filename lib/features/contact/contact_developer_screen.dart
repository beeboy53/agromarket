import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_card.dart';

/// Lets the user reach the developer via email, phone, or a website
/// link, using url_launcher to open the device's default app for
/// each (mail client, phone dialer, or browser).
///
/// NOTE: Replace the placeholder contact details below with your
/// own before submitting/defending the project.
class ContactDeveloperScreen extends StatelessWidget {
  const ContactDeveloperScreen({super.key});

  static const String _developerName = 'MK Tech';
  static const String _email = 'awwalmalik4@gmail.com';
  static const String _phone = '+2348142678825';
  static const String _website = 'https://mktech.com.ng';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.contactDeveloper)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _developerName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            Text(
              'Developer of AgroMarket',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomCard(
              onTap: () => _launch(context, Uri(scheme: 'mailto', path: _email)),
              child: const _ContactRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _email,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              onTap: () => _launch(context, Uri(scheme: 'tel', path: _phone)),
              child: const _ContactRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: _phone,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              onTap: () => _launch(context, Uri.parse(_website)),
              child: const _ContactRow(
                icon: Icons.language_outlined,
                label: 'Website',
                value: _website,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
      ],
    );
  }
}