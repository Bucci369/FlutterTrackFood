import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/app_providers.dart';
import 'package:trackfood/screens/chat/chat_screen.dart';
import 'package:trackfood/screens/diary/diary_screen.dart';
import 'package:trackfood/screens/profile/profile_screen.dart';
import 'package:trackfood/screens/recipes/recipes_screen.dart';
import 'package:trackfood/theme/app_colors.dart';
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
    return Stack(
      children: [
        CupertinoTabScaffold(
          controller: _tabController,
          tabBar: CupertinoTabBar(
            activeColor: AppColors.vibrantBlue, // Vibrant active color
            inactiveColor: AppColors.sharpGray, // Sharp inactive color
            backgroundColor: AppColors.deepBlack.withValues(
              alpha: 0.9,
            ), // Dark glass background
            border: Border(
              top: BorderSide(
                color: AppColors.glassWhite, // Glass border effect
                width: 0.5,
              ),
            ),
            onTap: (index) {
              if (index != 2) {
                // Skip chat (center) button - handled by floating button
                ref.read(tabControllerProvider.notifier).state = index;
              }
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(CupertinoIcons.house_fill),
                ), // Modern filled home icon
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(CupertinoIcons.book_fill),
                ), // Modern filled book icon
                label: 'Tagebuch',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for floating button
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(CupertinoIcons.doc_text_search),
                ), // Modern search/recipe icon
                label: 'Rezepte',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(CupertinoIcons.person_fill),
                ), // Modern filled person icon
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
        ),
        // Floating Chat Button
        Positioned(
          bottom: 30, // Lowered to sit on the tab bar, creating a notch effect
          left:
              MediaQuery.of(context).size.width / 2 -
              34, // Centered for the new larger size
          child: Container(
            width: 68, // Made the button larger
            height: 68, // Made the button larger
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.vibrantBlueGradient, // Vibrant blue gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.pureWhite.withValues(
                  alpha: 0.3,
                ), // Crisp white border
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vibrantBlue.withValues(
                    alpha: 0.4,
                  ), // Vibrant glow
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.deepBlack.withValues(
                    alpha: 0.3,
                  ), // Drop shadow
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                ref.read(tabControllerProvider.notifier).state = 2;
                _tabController.index = 2;
              },
              child: Icon(
                CupertinoIcons.chat_bubble_fill,
                color: AppColors.pureWhite, // Pure white icon
                size: 32, // Larger icon to fit the new button size
              ),
            ),
          ),
        ),
      ],
    );
  }
}
