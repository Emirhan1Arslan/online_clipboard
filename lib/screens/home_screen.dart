import 'package:flutter/material.dart';
import 'package:myappon/models/clipboard_item.dart';
import 'package:myappon/screens/settings_screen.dart';
import 'package:myappon/services/clipboard_service.dart';
import 'package:myappon/services/theme_service.dart';
import 'package:myappon/widgets/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyText(ClipboardItem item) async {
    final clipboardService = context.read<ClipboardService>();
    await clipboardService.copyToClipboard(item.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulating refresh with a small delay
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all clipboard items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ClipboardService>().clearAll();
            },
            child: Text(
              'CLEAR ALL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipboardService = context.watch<ClipboardService>();
    final themeService = context.watch<ThemeService>();
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Online Clipboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode 
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeService.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: clipboardService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : clipboardService.items.isEmpty
              ? EmptyState(
                  icon: Icons.content_paste_outlined,
                  title: 'No Clipboard Items',
                  message: 'Copy text to your clipboard and it will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16, 
                      right: 16, 
                      top: 16, 
                      bottom: 80,
                    ),
                    itemCount: clipboardService.items.length,
                    itemBuilder: (context, index) {
                      final item = clipboardService.items[index];
                      final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
                      final formattedDate = DateFormat.yMMMd().add_jm().format(date);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => _copyText(item),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                icon: Icons.copy,
                                label: 'Copy',
                                borderRadius: BorderRadius.circular(12),
                              ),
                              SlidableAction(
                                onPressed: (_) => clipboardService.deleteItem(item.id),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _copyText(item),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.text,
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: clipboardService.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showClearAllConfirmation,
              tooltip: 'Clear All',
              child: const Icon(Icons.clear_all),
            )
          : null,
    );
  }
}