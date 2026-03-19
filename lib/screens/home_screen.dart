import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zikr_provider.dart';
import 'active_zikr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZikrProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Smart Zikr', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 28)),
                    Row(
                      children: [
                        // Streak Counter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text('${provider.currentStreak}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dark/Light Mode Toggle
                        IconButton(
                          icon: Icon(provider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                          color: theme.colorScheme.primary,
                          onPressed: () => provider.toggleTheme(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // GITHUB-STYLE ACTIVITY CALENDAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activity History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60, // Restrict height for the native grid
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: provider.activityHistory.length,
                          itemBuilder: (context, index) {
                            int intensity = provider.activityHistory[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: intensity == 0
                                    ? theme.colorScheme.onSurface.withOpacity(0.05)
                                    : theme.colorScheme.primary.withOpacity(0.2 + (intensity * 0.2)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...provider.groupedMissions.entries.map((entry) {

              String categoryName = entry.key;
              var tasks = entry.value;

              return SliverToBoxAdapter(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(categoryName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ),
              ...tasks.map((task) {
              double progress = task.currentCount / task.targetCount;
              return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
              alignment: Alignment.center,
              children: [
              SizedBox(
              height: 44, width: 44,
              child: CircularProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              color: theme.colorScheme.secondary,
              strokeWidth: 3,
              ),
              ),
              if (task.isCompleted)
              Icon(Icons.check, color: theme.colorScheme.secondary, size: 20)
              else
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
              ),
              title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              subtitle: Text(task.arabicTitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              trailing: Icon(Icons.play_circle_fill, size: 28, color: theme.colorScheme.primary.withOpacity(0.2)),
              onTap: () {
              if (!task.isCompleted) {
              provider.setCurrentTask(task);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveZikrScreen()));
              }
              },
              ),
              );
              }).toList(),
              ],
              ),
              ),
              );
            }).toList(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)), // Bottom padding
          ],
        ),
      ),
    );
  }
}