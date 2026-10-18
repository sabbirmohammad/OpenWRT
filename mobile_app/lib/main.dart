import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/glossy_theme.dart';
import 'presentation/controllers/router_controller.dart';
import 'presentation/screens/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await PreferencesService.init();
  final controller = RouterController(prefs);

  runApp(ArcherGuardApp(controller: controller));

  // Initialize and connect to local router asynchronously
  controller.init();
}

class ArcherGuardApp extends StatefulWidget {
  final RouterController controller;

  const ArcherGuardApp({super.key, required this.controller});

  @override
  State<ArcherGuardApp> createState() => _ArcherGuardAppState();
}

class _ArcherGuardAppState extends State<ArcherGuardApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => widget.controller.resumePolling(),
      onPause: () => widget.controller.pausePolling(),
      onHide: () => widget.controller.pausePolling(),
      onInactive: () => widget.controller.pausePolling(),
      onDetach: () => widget.controller.pausePolling(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArcherGuard C6',
      debugShowCheckedModeBanner: false,
      theme: GlossyTheme.darkTheme,
      home: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return MainNavigationShell(controller: widget.controller);
        },
      ),
    );
  }
}
