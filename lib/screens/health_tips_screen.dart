import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final healthTipProvider = FutureProvider<String>((ref) async {
  return await ApiService.getHealthTip();
});

// News model for headline and details
class HealthNewsItem {
  final String title;
  final String? description;
  final String? url;
  HealthNewsItem({required this.title, this.description, this.url});
}

final healthNewsProvider = FutureProvider<List<HealthNewsItem>>((ref) async {
  final newsList = await ApiService.getHealthNewsDetailed();
  return newsList;
});

class HealthTipsScreen extends ConsumerWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(healthTipProvider);
    final newsAsync = ref.watch(healthNewsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tip',
            onPressed: () => ref.refresh(healthTipProvider),
          ),
          IconButton(
            icon: const Icon(Icons.article),
            tooltip: 'Refresh News',
            onPressed: () => ref.refresh(healthNewsProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.orange[50],
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: tipAsync.when(
                data: (tip) => Column(
                  children: [
                    Icon(Icons.lightbulb,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[200]
                            : Colors.orange,
                        size: 40),
                    const SizedBox(height: 12),
                    Text(
                      tip,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[100]
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Health News',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[100]
                    : Colors.black,
              )),
          const SizedBox(height: 12),
          newsAsync.when(
            data: (newsList) => Column(
              children: newsList
                  .map((newsItem) => Card(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.blue[50],
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            newsItem.title,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue[100]
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(newsItem.title),
                                content: Text(newsItem.description ??
                                    'No details available.'),
                                actions: [
                                  if (newsItem.url != null)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Optionally launch URL
                                      },
                                      child: const Text('Read More'),
                                    ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ))
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading news: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
