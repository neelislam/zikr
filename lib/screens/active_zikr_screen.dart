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
    _zikrProvider.stopListeningSilent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZikrProvider>(context);
    final task = provider.currentTask;

    if (task == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: Text(task.title), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${task.currentCount}', style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.teal)),
          Text('of ${task.targetCount}', style: const TextStyle(fontSize: 24, color: Colors.grey)),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () => provider.isListening ? provider.stopListening() : provider.startListening(),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: provider.isListening ? Colors.red : Colors.teal,
              child: Icon(provider.isListening ? Icons.mic : Icons.mic_none, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Text('System: ${provider.debugMessage}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Heard: ${provider.lastWords}', style: const TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}