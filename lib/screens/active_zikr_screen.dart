import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zikr_provider.dart';

class ActiveZikrScreen extends StatefulWidget {
  const ActiveZikrScreen({super.key});

  @override
  State<ActiveZikrScreen> createState() => _ActiveZikrScreenState();
}

class _ActiveZikrScreenState extends State<ActiveZikrScreen> {
  late ZikrProvider _zikrProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ZikrProvider>(context, listen: false).initSpeech();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _zikrProvider = Provider.of<ZikrProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // FIX: Safely stop listening without crashing the app!
    _zikrProvider.stopListeningSilent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZikrProvider>(context);
    final task = provider.currentTask;

    if (task == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Targets: ${task.targetWords.join(", ")}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              '${task.currentCount}',
              style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            Text(
              'out of ${task.targetCount}',
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            if (task.isCompleted)
              const Text(
                'Mission Completed! 🎉',
                style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
              )
            else
              GestureDetector(
                onTap: () {
                  if (provider.isListening) {
                    provider.stopListening();
                  } else {
                    provider.startListening();
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: provider.isListening ? Colors.red : Colors.teal,
                  child: Icon(
                    provider.isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (provider.isListening)
              const Text('Listening...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
            else if (!task.isCompleted)
              const Text('Tap mic to start hands-free counting'),

            // --- THE DEBUG TEXT IS NOW VISIBLE ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Heard: ${provider.lastWords}', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
            )
          ],
        ),
      ),
    );
  }
}