import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';

/// The real Settings tab: working Dark Mode toggle, account info
/// with Logout, Admin Tools (only visible to admin accounts), and
/// links to About App / About Project / Contact Developer.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Account ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (authProvider.username ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.username ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        authProvider.isAdmin ? 'Admin account' : 'User account',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  tooltip: AppStrings.logout,
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Preferences ---
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
              title: const Text(AppStrings.darkMode),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),

          // --- Admin tools ---
          if (authProvider.isAdmin) ...[
            const SizedBox(height: 20),
            Text(AppStrings.adminTools, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
           Card(
              child: ListTile(
                leading: const Icon(Icons.add_business_outlined, color: AppColors.primary),
                title: const Text(AppStrings.manageMarketPrices),
                subtitle: const Text('Add, edit, or delete market price records'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageMarkets),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text(AppStrings.aboutApp),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.aboutApp),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                  title: const Text(AppStrings.aboutProject),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.aboutProject),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mail_outline, color: AppColors.primary),
                  title: const Text(AppStrings.contactDeveloper),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.contactDeveloper),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}