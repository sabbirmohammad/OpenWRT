import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_bottom_bar.dart';
import '../widgets/glossy_sidebar_drawer.dart';
import 'dashboard_screen.dart';
import 'devices_screen.dart';
import 'network_screen.dart';
import 'tools_screen.dart';
import 'wireless_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final RouterController controller;

  const MainNavigationShell({super.key, required this.controller});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  double? _dragStartX;

  void _openEndDrawer() {
    HapticFeedback.selectionClick();
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onTabTapped(int index) {
    if (index == 4) {
      _openEndDrawer();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double screenWidth) {
    // Detect edge drag from the right edge inward (to the left)
    if (_dragStartX != null && _dragStartX! > screenWidth - 60) {
      if (_dragStartX! - details.globalPosition.dx > 35) {
        _openEndDrawer();
        _dragStartX = null;
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragStartX = null;
  }

  @override
  Widget build(BuildContext context) {
    final clientCount = widget.controller.status?.clients.length ?? 0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: GlossyColors.backgroundPrimary,
      endDrawerEnableOpenDragGesture: true,
      endDrawer: GlossySidebarDrawer(
        controller: widget.controller,
        isEndDrawer: true,
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, screenWidth),
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              controller: widget.controller,
              onNavigateToTab: _onTabTapped,
            ),
            DevicesScreen(controller: widget.controller),
            WirelessScreen(controller: widget.controller),
            NetworkScreen(controller: widget.controller),
            ToolsScreen(controller: widget.controller),
          ],
        ),
      ),
      bottomNavigationBar: GlossyBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        clientCount: clientCount,
      ),
    );
  }
}
