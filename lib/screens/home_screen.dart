import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zikr_provider.dart';
import 'active_zikr_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zikrProvider = Provider.of<ZikrProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Zikr Missions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: zikrProvider.dailyMissions.length,
        itemBuilder: (context, index) {
          final task = zikrProvider.dailyMissions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${task.currentCount} / ${task.targetCount}'),
              trailing: task.isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!task.isCompleted) {
                  zikrProvider.setCurrentTask(task);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActiveZikrScreen()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
