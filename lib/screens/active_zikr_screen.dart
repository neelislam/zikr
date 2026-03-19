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
    final theme = Theme.of(context);

    if (task == null) return const Scaffold();

    double progress = task.currentCount / task.targetCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(task.arabicTitle, style: TextStyle(fontSize: 36, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              Text(task.title, style: const TextStyle(fontSize: 18, color: Colors.grey)),

              const Spacer(),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250, height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${task.currentCount}', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: theme.colorScheme.onSurface, height: 1.0)),
                      Text('of ${task.targetCount}', style: const TextStyle(fontSize: 20, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              if (task.isCompleted)
                Text('Alhamdulillah, Mission Completed! 🎉', style: TextStyle(fontSize: 20, color: theme.colorScheme.primary, fontWeight: FontWeight.bold))
              else
                GestureDetector(
                  onTap: () => provider.isListening ? provider.stopListening() : provider.startListening(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                        color: provider.isListening ? theme.colorScheme.primary : theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: provider.isListening ? theme.colorScheme.primary.withOpacity(0.4) : Colors.black.withOpacity(0.1),
                            blurRadius: provider.isListening ? 20 : 10,
                          )
                        ]
                    ),
                    child: Icon(
                        provider.isListening ? Icons.mic : Icons.mic_none,
                        size: 35,
                        color: provider.isListening ? Colors.white : theme.colorScheme.primary
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              Text(provider.debugMessage, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}