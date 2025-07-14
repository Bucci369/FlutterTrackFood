import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/dashboard_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../activities/activities_screen.dart';

class RecentActivities extends ConsumerWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A), // Dark card background start
            const Color(0xFF2A2A2A), // Dark card background middle (lighter)
            const Color(0xFF1A1A1A), // Dark card background end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(
            alpha: 0.2,
          ), // Card border - subtle white border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.white.withValues(
              alpha: 0.05,
            ), // Reduced glow
            blurRadius: 20, // Softened blur
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(
              alpha: 0.5,
            ), // Softened shadow
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitäten',
                style: AppTypography.headline.copyWith(
                  color: CupertinoColors.white, // Activity title text color
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: CupertinoColors.white.withValues(
                        alpha: 0.3,
                      ), // Activity title text shadow
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ActivitiesScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.3,
                        ), // "Show all" button background gradient start - blue
                        AppColors.primary.withValues(
                          alpha: 0.1,
                        ), // "Show all" button background gradient end - blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.4,
                      ), // "Show all" button border - blue
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.2,
                        ), // "Show all" button glow shadow - blue (reduced)
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Text(
                    'Alle anzeigen',
                    style: AppTypography.body.copyWith(
                      color:
                          CupertinoColors.white, // "Show all" button text color
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: activitiesAsync.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Fehler: $err',
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.8),
                  ), // Error text color
                ),
              ),
              data: (activities) {
                if (activities.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityRow(activity, index, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    Map<String, dynamic> activity,
    int index,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Add padding to the bottom
      child:
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2A2A2A), // Activity item background start
                      const Color(
                        0xFF1A1A1A,
                      ), // Activity item background middle (darker)
                      const Color(0xFF2A2A2A), // Activity item background end
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(
                      alpha: 0.15,
                    ), // Activity item border - subtle white
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.white.withValues(
                        alpha: 0.05,
                      ), // Activity item glow shadow
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(
                              alpha: 0.3,
                            ), // Activity icon background gradient start - blue
                            AppColors.primary.withValues(
                              alpha: 0.1,
                            ), // Activity icon background gradient end - blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(
                            alpha: 0.4,
                          ), // Activity icon border - blue
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: 0.2,
                            ), // Activity icon glow shadow - blue (reduced)
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          activity['emoji'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['name'],
                            style: AppTypography.body.copyWith(
                              color: CupertinoColors
                                  .white, // Activity name text color
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activity['duration']} • ${activity['calories']} kcal',
                            style: AppTypography.body.copyWith(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.7,
                              ), // Activity duration/calories text color
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      activity['time'],
                      style: AppTypography.body.copyWith(
                        color: CupertinoColors.white.withValues(
                          alpha: 0.6,
                        ), // Activity time text color
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.3, end: 0),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(
                    alpha: 0.3,
                  ), // Empty state icon background gradient start - blue
                  AppColors.primary.withValues(
                    alpha: 0.1,
                  ), // Empty state icon background gradient end - blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.4,
                ), // Empty state icon border - blue
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.2,
                  ), // Empty state icon glow shadow - blue (reduced)
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.sportscourt,
              color: CupertinoColors.white, // Empty state icon color
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keine Aktivitäten heute',
            style: AppTypography.body.copyWith(
              color: CupertinoColors.white, // Empty state title text color
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Starte dein erstes Workout!',
            style: AppTypography.body.copyWith(
              color: CupertinoColors.white.withValues(
                alpha: 0.7,
              ), // Empty state subtitle text color
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors
                      .primary, // Empty state button background gradient start - blue
                  AppColors.primary.withValues(
                    alpha: 0.8,
                  ), // Empty state button background gradient end - blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.25,
                  ), // Empty state button glow shadow - blue (reduced)
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ActivitiesScreen(),
                  ),
                );
              },
              child: const Text(
                'Aktivität hinzufügen',
                style: TextStyle(
                  color: CupertinoColors.white, // Empty state button text color
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
