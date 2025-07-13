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

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Rezepte')),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: state.isLoading && state.recipes.isEmpty
                  ? const Center(child: CupertinoActivityIndicator())
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount:
                          state.recipes.length + (state.canLoadMore ? 1 : 0),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        onChanged: (query) {
          ref.read(recipesProvider.notifier).setSearchQuery(query);
        },
        placeholder: 'Suche nach Rezepten...',
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final state = ref.watch(recipesProvider);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: state.categories.length + 1,
        itemBuilder: (context, index) {
          final isAllCategory = index == 0;
          final category = isAllCategory ? 'Alle' : state.categories[index - 1];
          final isSelected = isAllCategory
              ? state.selectedCategory == null
              : state.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CupertinoButton(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.tertiarySystemFill,
              onPressed: () {
                ref
                    .read(recipesProvider.notifier)
                    .setCategory(isAllCategory ? null : category);
              },
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? CupertinoColors.white : AppColors.label,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: recipe.imageUrl != null
                  ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
                  : Container(color: AppColors.tertiarySystemFill),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      CupertinoColors.black.withOpacity(0.8),
                      CupertinoColors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Text(
                  recipe.title,
                  style: AppTypography.body.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
