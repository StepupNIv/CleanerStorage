
import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../services/cleaner_service.dart';
import '../services/ad_service.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class LargeFilesScreen extends StatefulWidget {
  final AdService adService;
  const LargeFilesScreen({super.key, required this.adService});

  @override
  State<LargeFilesScreen> createState() => _LargeFilesScreenState();
}

class _LargeFilesScreenState extends State<LargeFilesScreen> {
  final CleanerService _service = CleanerService();
  List<FileItem> _files = [];
  bool _loading = false;
  bool _scanned = false;
  bool _isDeleting = false;

  int get _selectedSize =>
      _files.where((f) => f.isSelected).fold(0, (s, f) => s + f.size);

  Future<void> _scan() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _scanned = false;
      _files = [];
    });

    final files = await _service.scanLargeFiles();

    if (!mounted) return;
    setState(() {
      _files = files;
      _loading = false;
      _scanned = true;
    });

    widget.adService.showInterstitial();
  }

  Future<void> _deleteSelected() async {
    final selected = _files.where((f) => f.isSelected).toList();
    if (selected.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${selected.length} File(s)?',
      message:
          'This will permanently delete ${formatBytes(_selectedSize)}. This cannot be undone.',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    final paths = selected.map((f) => f.path).toList();
    await _service.deleteFiles(paths);

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
      _files.removeWhere((f) => f.isSelected);
    });

    widget.adService.showInterstitial();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Freed ${formatBytes(_selectedSize)}'),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _files.where((f) => f.isSelected).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Large Files'),
        actions: [
          if (_scanned && _files.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final f in _files) {
                    f.isSelected = true;
                  }
                });
              },
              child: const Text(
                'Select All',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildBody()),
              BannerAdWidget(adService: widget.adService),
            ],
          ),
          if (_isDeleting)
            const LoadingOverlay(message: 'Deleting files...'),
        ],
      ),
      floatingActionButton: selectedCount > 0
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              backgroundColor: AppTheme.danger,
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              label: Text(
                'Delete $selectedCount file(s)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
            ),
            SizedBox(height: 20),
            Text(
              'Scanning for large files...',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
      );
    }

    if (!_scanned) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_zip_rounded, size: 60),
              SizedBox(height: 24),
              const Text(
                'Find Large Files',
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _scan,
                icon: const Icon(Icons.search),
                label: const Text('Scan Now'),
              ),
            ],
          ),
        ),
      );
    }

    if (_files.isEmpty) {
      return const Center(child: Text('No large files found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: _files.length,
      itemBuilder: (_, i) {
        final f = _files[i];
        return _LargeFileTile(
          file: f,
          rank: i + 1,
          onChanged: (val) =>
              setState(() => f.isSelected = val ?? false),
        );
      },
    );
  }
}

class _LargeFileTile extends StatelessWidget {
  final FileItem file;
  final int rank;
  final ValueChanged<bool?> onChanged;

  const _LargeFileTile({
    required this.file,
    required this.rank,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: file.isSelected,
            onChanged: onChanged,
          ),
          Expanded(
            child: ListTile(
              title: Text(file.name),
              subtitle: Text(file.path),
              trailing: SizeBadge(
                size: file.formattedSize,
                color: AppTheme.secondary, // ✅ FIXED
              ),
            ),
          ),
        ],
      ),
    );
  }
}


