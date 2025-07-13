import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/app_providers.dart';
import 'package:trackfood/screens/chat/chat_screen.dart';
import 'package:trackfood/screens/diary/diary_screen.dart';
import 'package:trackfood/screens/profile/profile_screen.dart';
import 'package:trackfood/screens/recipes/recipes_screen.dart';
import 'dashboard_content.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(tabControllerProvider);
    _tabController = CupertinoTabController(initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: const Color.fromARGB(255, 46, 71, 196),
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: const Color(0xFFF6F1E7), // Apple White
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
            icon: Icon(CupertinoIcons.search_circle_fill), // Example icon
            label: 'Rezepte',
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
            switch (index) {
              case 0:
                return const DashboardContent();
              case 1:
                return const DiaryScreen();
              case 2:
                return const ChatScreen();
              case 3:
                return const RecipesScreen();
              case 4:
                return const ProfileScreen();
              default:
                return const DashboardContent();
            }
          },
        );
      },
    );
  }
}
