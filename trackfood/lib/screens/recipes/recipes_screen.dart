import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/recipe.dart';
import 'package:trackfood/providers/recipes_provider.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(recipesProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipesProvider);
    final notifier = ref.read(recipesProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Rezepte')),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(notifier),
            _buildCategoryFilter(state, notifier), // Dynamic categories with counts
            Expanded(
              child: state.isLoading && state.recipes.isEmpty
                  ? const Center(child: CupertinoActivityIndicator())
                  : state.recipes.isEmpty
                  ? const Center(child: Text('Keine Rezepte gefunden.'))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount:
                          state.recipes.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.recipes.length) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                        final recipe = state.recipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(RecipesNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        onChanged: notifier.setSearchQuery,
        placeholder: 'Suche nach Rezepten...',
      ),
    );
  }

  Widget _buildCategoryFilter(RecipesState state, RecipesNotifier notifier) {
    // Show loading state while categories are loading
    if (state.categoriesLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    // Show dynamic categories with counts like the webapp
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final categoryData = state.categories[index];
          final isSelected = state.selectedCategory == categoryData.category;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: isSelected
                  ? AppColors.primary
                  : AppColors.tertiarySystemFill,
              onPressed: () => notifier.setCategory(categoryData.category),
              child: Text(
                '${categoryData.category} (${categoryData.count})', // Show count like webapp
                style: TextStyle(
                  color: isSelected ? CupertinoColors.white : AppColors.label,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        if (recipe.link != null &&
            await canLaunchUrl(Uri.parse(recipe.link!))) {
          await launchUrl(Uri.parse(recipe.link!));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.separator, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image without a fixed aspect ratio
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit
                          .cover, // Cover the width, height will be dynamic
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150, // Fallback height
                          color: AppColors.tertiarySystemFill,
                          child: const Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.secondaryLabel,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 150, // Fallback height
                      color: AppColors.tertiarySystemFill,
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 40,
                        color: AppColors.secondaryLabel,
                      ),
                    ),
            ),
            // Text content below the image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe.title,
                style: AppTypography.body.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
