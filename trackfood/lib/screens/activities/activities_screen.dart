import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  // Exakt die gleichen Aktivitäten wie in der WebApp (activities-list.ts)
  static const List<Map<String, dynamic>> _webAppActivities = [
    {'id': 'aerobic', 'name': 'Aerobic Dancing', 'emoji': '💃', 'met': 7.0},
    {'id': 'aikido', 'name': 'Aikido', 'emoji': '🥋', 'met': 5.0},
    {'id': 'angeln', 'name': 'Angeln', 'emoji': '🎣', 'met': 2.5},
    {'id': 'aquajogging', 'name': 'Aquajogging', 'emoji': '🏊‍♂️', 'met': 7.0},
    {
      'id': 'ausfallschritte',
      'name': 'Ausfallschritte',
      'emoji': '💪',
      'met': 5.0,
    },
    {'id': 'badminton', 'name': 'Badminton', 'emoji': '🏸', 'met': 4.5},
    {'id': 'basketball', 'name': 'Basketball', 'emoji': '🏀', 'met': 6.5},
    {
      'id': 'basketball_wettkampf',
      'name': 'Basketball, wettkampfmäßig',
      'emoji': '🏀',
      'met': 8.3,
    },
    {'id': 'beinpresse', 'name': 'Beinpresse', 'emoji': '💪', 'met': 5.0},
    {'id': 'bergsteigen', 'name': 'Bergsteigen', 'emoji': '🧗‍♂️', 'met': 8.0},
    {'id': 'boxen', 'name': 'Boxen', 'emoji': '🥊', 'met': 7.8},
    {
      'id': 'boxen_wettkampf',
      'name': 'Boxen, wettkampfmäßig',
      'emoji': '🥊',
      'met': 12.0,
    },
    {
      'id': 'crosstrainer',
      'name': 'Crosstrainer',
      'emoji': '🏋️‍♂️',
      'met': 5.0,
    },
    {
      'id': 'fahrrad',
      'name': 'Fahrradfahren, generell',
      'emoji': '🚴‍♂️',
      'met': 6.0,
    },
    {'id': 'fussball', 'name': 'Fußball', 'emoji': '⚽', 'met': 7.0},
    {
      'id': 'fussball_wettkampf',
      'name': 'Fußball, wettkampfmäßig',
      'emoji': '⚽',
      'met': 10.0,
    },
    {'id': 'handball', 'name': 'Handball', 'emoji': '🤾‍♂️', 'met': 8.0},
    {
      'id': 'handball_wettkampf',
      'name': 'Handball, wettkampfmäßig',
      'emoji': '🤾‍♂️',
      'met': 12.0,
    },
    {'id': 'hiit', 'name': 'HIIT', 'emoji': '🔥', 'met': 8.0},
    {'id': 'joggen', 'name': 'Joggen, Laufen', 'emoji': '🏃‍♂️', 'met': 8.0},
    {'id': 'klettern', 'name': 'Klettern', 'emoji': '🧗‍♂️', 'met': 8.0},
    {
      'id': 'krafttraining',
      'name': 'Krafttraining, Fitnessstudio',
      'emoji': '💪',
      'met': 6.0,
    },
    {'id': 'laufen', 'name': 'Laufen (schnell)', 'emoji': '🏃‍♂️', 'met': 10.0},
    {
      'id': 'mountainbike',
      'name': 'Mountainbiken',
      'emoji': '🚵‍♂️',
      'met': 8.5,
    },
    {
      'id': 'nordicwalking',
      'name': 'Nordic Walking',
      'emoji': '🚶‍♀️',
      'met': 4.5,
    },
    {'id': 'pilates', 'name': 'Pilates', 'emoji': '🧘‍♀️', 'met': 3.0},
    {'id': 'reiten', 'name': 'Reiten', 'emoji': '🏇', 'met': 5.5},
    {'id': 'rudern', 'name': 'Rudern', 'emoji': '🚣‍♂️', 'met': 7.0},
    {
      'id': 'rudern_wettkampf',
      'name': 'Rudern, wettkampfmäßig',
      'emoji': '🚣‍♂️',
      'met': 12.0,
    },
    {'id': 'schwimmen', 'name': 'Schwimmen', 'emoji': '🏊‍♂️', 'met': 6.0},
    {
      'id': 'schwimmen_kraulen',
      'name': 'Schwimmen, Kraulen',
      'emoji': '🏊‍♂️',
      'met': 9.8,
    },
    {'id': 'skifahren', 'name': 'Ski fahren', 'emoji': '⛷️', 'met': 7.0},
    {
      'id': 'skifahren_wettkampf',
      'name': 'Ski fahren, wettkampfmäßig',
      'emoji': '⛷️',
      'met': 10.0,
    },
    {'id': 'skilanglauf', 'name': 'Ski Langlauf', 'emoji': '🎿', 'met': 7.5},
    {
      'id': 'spazieren',
      'name': 'Spazieren gehen',
      'emoji': '🚶‍♂️',
      'met': 3.0,
    },
    {'id': 'springen', 'name': 'Seilspringen', 'emoji': '🤾‍♂️', 'met': 12.0},
    {'id': 'tanzen', 'name': 'Tanzen', 'emoji': '💃', 'met': 5.5},
    {'id': 'tanzen_salsa', 'name': 'Tanzen: Salsa', 'emoji': '💃', 'met': 7.0},
    {'id': 'tennis', 'name': 'Tennis', 'emoji': '🎾', 'met': 7.3},
    {'id': 'tischtennis', 'name': 'Tischtennis', 'emoji': '🏓', 'met': 4.0},
    {
      'id': 'trampolin',
      'name': 'Trampolin springen',
      'emoji': '🤸‍♂️',
      'met': 3.5,
    },
    {'id': 'volleyball', 'name': 'Volleyball', 'emoji': '🏐', 'met': 3.5},
    {
      'id': 'volleyball_wettkampf',
      'name': 'Volleyball, wettkampfmäßig',
      'emoji': '🏐',
      'met': 8.0,
    },
    {'id': 'wandern', 'name': 'Wandern', 'emoji': '🥾', 'met': 6.0},
    {'id': 'yoga', 'name': 'Yoga', 'emoji': '🧘‍♂️', 'met': 3.0},
    {'id': 'zufussgehen', 'name': 'Zufußgehen', 'emoji': '🚶‍♂️', 'met': 3.5},
    {'id': 'zumba', 'name': 'Zumba', 'emoji': '🧘‍♂️', 'met': 5.5},
  ];

  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _filteredActivities = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      // Versuche zuerst, aus Supabase zu laden
      final response = await SupabaseService().client
          .from('activities')
          .select('id, activity_name, emoji, met')
          .order('activity_name');

      if (response.isNotEmpty) {
        setState(() {
          _activities = response
              .map<Map<String, dynamic>>(
                (activity) => {
                  'id': activity['id'],
                  'name': activity['activity_name'] ?? 'Unbekannte Aktivität',
                  'emoji': activity['emoji'] ?? '🏃‍♂️',
                  'met': (activity['met'] as num?)?.toDouble() ?? 5.0,
                },
              )
              .toList();
          _filteredActivities = _activities;
          _isLoading = false;
        });
      } else {
        // Falls keine Aktivitäten in Supabase, verwende WebApp-Liste
        await _ensureActivitiesInSupabase();
      }
    } catch (e) {
      print('Error loading activities: $e');
      // Fallback: Verwende lokale WebApp-Liste
      setState(() {
        _activities = _webAppActivities;
        _filteredActivities = _activities;
        _isLoading = false;
      });
    }
  }

  Future<void> _ensureActivitiesInSupabase() async {
    try {
      // Importiere WebApp-Aktivitäten in Supabase
      final insertData = _webAppActivities
          .map(
            (activity) => {
              'id': activity['id'],
              'activity_name': activity['name'],
              'emoji': activity['emoji'],
              'met': activity['met'],
            },
          )
          .toList();

      await SupabaseService().client.from('activities').upsert(insertData);

      setState(() {
        _activities = _webAppActivities;
        _filteredActivities = _activities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error importing activities: $e');
      setState(() {
        _activities = _webAppActivities;
        _filteredActivities = _activities;
        _isLoading = false;
      });
    }
  }

  void _filterActivities(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredActivities = _activities;
      } else {
        _filteredActivities = _activities
            .where(
              (activity) =>
                  activity['name'].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Apple White
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFF6F1E7),
        middle: Text(
          'Aktivität hinzufügen',
          style: AppTypography.headline.copyWith(color: AppColors.label),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(CupertinoIcons.back, color: AppColors.primary),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wähle eine Aktivität',
                style: AppTypography.largeTitle.copyWith(
                  color: AppColors.label,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_webAppActivities.length} Aktivitäten verfügbar',
                style: AppTypography.body.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 16),
              // Suchfeld
              CupertinoSearchTextField(
                placeholder: 'Aktivität suchen...',
                onChanged: _filterActivities,
                style: AppTypography.body.copyWith(color: AppColors.label),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: _filteredActivities.length,
                        itemBuilder: (context, index) {
                          final activity = _filteredActivities[index];
                          return _buildActivityCard(activity);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return GestureDetector(
      onTap: () => _showActivityDetailsDialog(activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
          border: Border.all(color: AppColors.separator, width: 1),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  activity['emoji'],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity['name'],
              style: AppTypography.body.copyWith(
                color: AppColors.label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${activity['met']} MET',
              style: AppTypography.body.copyWith(
                color: AppColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsDialog(Map<String, dynamic> activity) {
    int duration = 30; // Default duration in minutes

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(activity['emoji']),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                activity['name'],
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Wie lange warst du aktiv?',
              style: AppTypography.body.copyWith(color: AppColors.label),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  duration = (index + 1) * 5; // 5, 10, 15, ... minutes
                },
                children: List.generate(24, (index) {
                  final minutes = (index + 1) * 5;
                  return Center(
                    child: Text(
                      '$minutes min',
                      style: AppTypography.body.copyWith(
                        color: AppColors.label,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _saveActivity(activity, duration);
            },
            child: Text(
              'Hinzufügen',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveActivity(
    Map<String, dynamic> activity,
    int duration,
  ) async {
    try {
      // Use ref.read to get the profile from the Riverpod provider
      final profileState = ref.read(profileProvider);
      final profile = profileState.profile;
      if (profile?.id == null) return;

      // Calculate calories burned (gleiche Formel wie WebApp)
      final weightKg = profile!.weightKg ?? 70.0;
      final met = activity['met'] as double;
      final calories = ((met * weightKg * duration) / 60).round();

      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Genau die gleichen Felder wie in der WebApp
      await SupabaseService().client.from('user_activities').insert({
        'user_id': profile.id,
        'activity_id': activity['id'],
        'activity_name': activity['name'],
        'emoji': activity['emoji'],
        'met': met,
        'duration_min': duration,
        'weight_kg': weightKg,
        'calories': calories,
        'activity_date': dateString,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('${activity['emoji']} Aktivität hinzugefügt!'),
            content: Text(
              '${activity['name']} für $duration Minuten\n$calories Kalorien verbrannt',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                  // We stay on the ActivitiesScreen to allow adding more activities.
                  // The user can navigate back manually using the back button.
                },
                child: Text('OK', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error saving activity: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Fehler'),
            content: Text('Aktivität konnte nicht gespeichert werden: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Lade Aktivitäten...',
            style: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              CupertinoIcons.search,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Aktivitäten gefunden',
            style: AppTypography.body.copyWith(
              color: AppColors.label,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Versuche einen anderen Suchbegriff',
            style: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
