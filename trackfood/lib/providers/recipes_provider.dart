import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/recipe.dart';
import 'package:trackfood/services/supabase_service.dart';

class RecipesState {
  final List<Recipe> recipes;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool canLoadMore;
  final int offset;

  RecipesState({
    this.recipes = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.canLoadMore = true,
    this.offset = 0,
  });

  RecipesState copyWith({
    List<Recipe>? recipes,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    bool? canLoadMore,
    int? offset,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      offset: offset ?? this.offset,
    );
  }
}

class RecipesNotifier extends StateNotifier<RecipesState> {
  final SupabaseService _supabaseService;

  RecipesNotifier(this._supabaseService) : super(RecipesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    final categories = await _supabaseService.getRecipeCategories();
    await _loadRecipes(isInitial: true);
    state = state.copyWith(categories: categories, isLoading: false);
  }

  Future<void> _loadRecipes({bool isInitial = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final newRecipes = await _supabaseService.getRecipes(
      offset: isInitial ? 0 : state.offset,
      query: state.searchQuery,
      category: state.selectedCategory,
    );

    state = state.copyWith(
      recipes: isInitial ? newRecipes : [...state.recipes, ...newRecipes],
      offset: isInitial ? newRecipes.length : state.offset + newRecipes.length,
      canLoadMore: newRecipes.isNotEmpty,
      isLoading: false,
    );
  }

  Future<void> loadMore() async {
    if (state.canLoadMore) {
      await _loadRecipes();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _loadRecipes(isInitial: true);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _loadRecipes(isInitial: true);
  }
}

final recipesProvider = StateNotifierProvider<RecipesNotifier, RecipesState>((
  ref,
) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return RecipesNotifier(supabaseService);
});
