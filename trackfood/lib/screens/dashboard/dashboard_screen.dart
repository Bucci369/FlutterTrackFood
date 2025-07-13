import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/app_providers.dart';
import 'package:trackfood/screens/chat/chat_screen.dart';
import 'package:trackfood/screens/diary/diary_screen.dart';
import 'package:trackfood/screens/profile/profile_screen.dart';
import 'dashboard_content.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabControllerProvider);

    final List<Widget> _tabs = [
      DashboardContent(), // Index 0
      DiaryScreen(), // Index 1
      ChatScreen(), // Index 2
      ProfileScreen(), // Index 3
    ];

    return CupertinoTabScaffold(
      controller: CupertinoTabController(initialIndex: tabIndex),
      tabBar: CupertinoTabBar(
        onTap: (index) {
          ref.read(tabControllerProvider.notifier).state = index;
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Tagebuch',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profil',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _tabs[index];
          },
        );
      },
    );
  }
}
