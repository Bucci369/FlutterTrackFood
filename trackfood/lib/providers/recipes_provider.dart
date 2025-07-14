import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/recipe.dart';
import 'package:trackfood/services/supabase_service.dart';

// Category data structure like the webapp 
class CategoryWithCount {
  final String category;
  final int count;

  CategoryWithCount({required this.category, required this.count});
}

class RecipesState {
  final List<Recipe> recipes;
  final String? selectedCategory; // Changed from selectedKeyword to selectedCategory
  final String searchQuery;
  final bool isLoading;
  final bool canLoadMore;
  final int offset;
  final List<CategoryWithCount> categories; // Dynamic categories with counts
  final bool categoriesLoading;

  RecipesState({
    this.recipes = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.canLoadMore = true,
    this.offset = 0,
    this.categories = const [],
    this.categoriesLoading = false,
  });

  // A sentinel object to detect if a parameter was passed or not.
  static const _sentinel = Object();

  RecipesState copyWith({
    List<Recipe>? recipes,
    Object? selectedCategory = _sentinel,
    String? searchQuery,
    bool? isLoading,
    bool? canLoadMore,
    int? offset,
    List<CategoryWithCount>? categories,
    bool? categoriesLoading,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      offset: offset ?? this.offset,
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
    );
  }
}

class RecipesNotifier extends StateNotifier<RecipesState> {
  final SupabaseService _supabaseService;
  Timer? _debounce;

  RecipesNotifier(this._supabaseService) : super(RecipesState()) {
    _initialize();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Load categories and recipes in parallel like the webapp
    await Future.wait([
      _loadCategories(),
      _loadRecipes(isInitial: true),
    ]);
  }

  Future<void> _loadCategories() async {
    state = state.copyWith(categoriesLoading: true);
    
    final categoriesData = await _supabaseService.getRecipeCategories();
    final categories = categoriesData
        .map((data) => CategoryWithCount(
              category: data['category'] as String,
              count: data['count'] as int,
            ))
        .toList();
    
    state = state.copyWith(
      categories: categories,
      categoriesLoading: false,
    );
  }

  Future<void> _loadRecipes({bool isInitial = false}) async {
    // Prevent multiple simultaneous loads
    if (state.isLoading && !isInitial) return;

    state = state.copyWith(isLoading: true);

    final newRecipes = await _supabaseService.getRecipes(
      offset: isInitial ? 0 : state.offset,
      query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      category: state.selectedCategory, // Use exact category match like webapp
    );

    state = state.copyWith(
      recipes: isInitial ? newRecipes : [...state.recipes, ...newRecipes],
      offset: isInitial ? newRecipes.length : state.offset + newRecipes.length,
      canLoadMore: newRecipes.isNotEmpty,
      isLoading: false,
    );
  }

  Future<void> loadMore() async {
    if (state.canLoadMore && !state.isLoading) {
      await _loadRecipes();
    }
  }

  void setSearchQuery(String query) {
    // Debounce the search to avoid excessive API calls, just like in the web app
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query, offset: 0, recipes: []);
      _loadRecipes(isInitial: true);
    });
  }

  void setCategory(String? category) {
    // Toggle category selection like the webapp
    final newCategory = state.selectedCategory == category ? null : category;
    state = state.copyWith(
      selectedCategory: newCategory, 
      offset: 0, 
      recipes: [],
      searchQuery: '', // Clear search when selecting category like webapp
    );
    _loadRecipes(isInitial: true);
  }
}

final recipesProvider = StateNotifierProvider<RecipesNotifier, RecipesState>((
  ref,
) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return RecipesNotifier(supabaseService);
});
