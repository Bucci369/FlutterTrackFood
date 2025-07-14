import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/recipe.dart';
import 'package:trackfood/services/supabase_service.dart';

// Hardcoded keyword filters from the web app
const List<Map<String, String>> kKeywordFilters = [
  {'key': 'schnell', 'title': 'Schnell & einfach'},
  {'key': 'salat', 'title': 'Salate'},
  {'key': 'suppe', 'title': 'Suppen'},
  {'key': 'kuchen', 'title': 'Kuchen'},
  {'key': 'brot', 'title': 'Brot & Brötchen'},
  {'key': 'low carb', 'title': 'Low Carb'},
  {'key': 'vegan', 'title': 'Vegane Hits'},
  {'key': 'pasta', 'title': 'Pasta'},
  {'key': 'dessert', 'title': 'Desserts'},
  {'key': 'frühstück', 'title': 'Frühstück'},
  {'key': 'grillen', 'title': 'Grillen'},
  {'key': 'eintopf', 'title': 'Eintöpfe'},
  {'key': 'auflauf', 'title': 'Aufläufe'},
  {'key': 'smoothie', 'title': 'Smoothies'},
  {'key': 'fisch', 'title': 'Fisch'},
  {'key': 'fleisch', 'title': 'Fleisch'},
  {'key': 'geflügel', 'title': 'Geflügel'},
  {'key': 'vegetarisch', 'title': 'Vegetarisch'},
  {'key': 'glutenfrei', 'title': 'Glutenfrei'},
  {'key': 'laktosefrei', 'title': 'Laktosefrei'},
  {'key': 'kalorienarm', 'title': 'Kalorienarm'},
];

class RecipesState {
  final List<Recipe> recipes;
  final String? selectedKeyword; // NEW: For keyword filters
  final String searchQuery;
  final bool isLoading;
  final bool canLoadMore;
  final int offset;

  RecipesState({
    this.recipes = const [],
    this.selectedKeyword,
    this.searchQuery = '',
    this.isLoading = false,
    this.canLoadMore = true,
    this.offset = 0,
  });

  // A sentinel object to detect if a parameter was passed or not.
  static const _sentinel = Object();

  RecipesState copyWith({
    List<Recipe>? recipes,
    Object? selectedKeyword = _sentinel,
    String? searchQuery,
    bool? isLoading,
    bool? canLoadMore,
    int? offset,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      selectedKeyword: selectedKeyword == _sentinel
          ? this.selectedKeyword
          : selectedKeyword as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      offset: offset ?? this.offset,
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
    await _loadRecipes(isInitial: true);
  }

  Future<void> _loadRecipes({bool isInitial = false}) async {
    // Prevent multiple simultaneous loads
    if (state.isLoading && !isInitial) return;

    state = state.copyWith(isLoading: true);

    // Use selectedKeyword in the query if it exists
    final query = state.selectedKeyword ?? state.searchQuery;

    final newRecipes = await _supabaseService.getRecipes(
      offset: isInitial ? 0 : state.offset,
      query: query,
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

  void setKeyword(String? keyword) {
    final newKeyword = state.selectedKeyword == keyword ? null : keyword;
    state = state.copyWith(selectedKeyword: newKeyword, offset: 0, recipes: []);
    _loadRecipes(isInitial: true);
  }
}

final recipesProvider = StateNotifierProvider<RecipesNotifier, RecipesState>((
  ref,
) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return RecipesNotifier(supabaseService);
});
