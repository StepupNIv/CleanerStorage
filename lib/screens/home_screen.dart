
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/ad_service.dart';
import '../widgets/common_widgets.dart';
import 'junk_cleaner_screen.dart';
import 'large_files_screen.dart';
// ❌ removed duplicate_finder_screen import
import 'storage_analyzer_screen.dart';
import 'app_manager_screen.dart';

class HomeScreen extends StatelessWidget {
  final AdService adService;
  const HomeScreen({super.key, required this.adService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _StorageOverviewCard(),
                      const SizedBox(height: 24),
                      const _SectionLabel('Quick Clean'),
                      const SizedBox(height: 12),
                      _FeatureGrid(adService: adService),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          BannerAdWidget(adService: adService),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.bg,
      floating: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Smart Cleaner',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Keep your device clean & fast',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1040), Color(0xFF0D1F3C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Tap any feature below to scan your device.',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final AdService adService;
  const _FeatureGrid({required this.adService});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureConfig(
        title: 'Junk Cleaner',
        subtitle: 'Cache & temp files',
        icon: Icons.auto_delete_rounded,
        colors: [Colors.blue, Colors.black],
        accent: AppTheme.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JunkCleanerScreen(adService: adService),
          ),
        ),
      ),
      _FeatureConfig(
        title: 'Large Files',
        subtitle: 'Files over 10 MB',
        icon: Icons.folder_zip_rounded,
        colors: [Colors.purple, Colors.black],
        accent: AppTheme.secondary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LargeFilesScreen(adService: adService),
          ),
        ),
      ),

      // ✅ FIXED (Duplicate replaced)
      _FeatureConfig(
        title: 'Duplicates',
        subtitle: 'Coming Soon',
        icon: Icons.copy_all_rounded,
        colors: [Colors.green, Colors.black],
        accent: AppTheme.accent,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Feature coming soon")),
        ),
      ),

      _FeatureConfig(
        title: 'Storage Map',
        subtitle: 'Usage by category',
        icon: Icons.donut_large_rounded,
        colors: [Colors.orange, Colors.black],
        accent: AppTheme.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StorageAnalyzerScreen(),
          ),
        ),
      ),
      _FeatureConfig(
        title: 'App Manager',
        subtitle: 'Uninstall apps',
        icon: Icons.apps_rounded,
        colors: [Colors.red, Colors.black],
        accent: AppTheme.danger,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppManagerScreen(),
          ),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: features.length,
      itemBuilder: (_, i) => _FeatureCard(config: features[i]),
    );
  }
}

class _FeatureConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;

  _FeatureConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.accent,
    required this.onTap,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureConfig config;
  const _FeatureCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: config.onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(config.icon, size: 40, color: config.accent),
            Text(config.title),
            Text(config.subtitle),
          ],
        ),
      ),
    );
  }
}


