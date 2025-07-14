import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/food_item.dart';
import 'package:trackfood/models/meal_type.dart';
import 'package:trackfood/providers/diary_provider.dart'
    hide supabaseServiceProvider; // Hide the conflicting provider
import 'package:trackfood/services/supabase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'barcode_scanner_screen.dart';

// A simple provider to manage the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// A future provider to fetch and combine search results from Supabase and OpenFoodFacts
final foodSearchProvider = FutureProvider<List<FoodItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) {
    return [];
  }

  final supabaseService = ref.watch(supabaseServiceProvider);

  // 1. Fetch results from Supabase and OpenFoodFacts in parallel
  final results = await Future.wait([
    supabaseService.searchProducts(query),
    http.get(
      Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=20',
      ),
    ),
  ]);

  // 2. Process Supabase results
  final supabaseResults = results[0] as List<FoodItem>;

  // 3. Process OpenFoodFacts results
  final List<FoodItem> offResults = [];
  final offResponse = results[1] as http.Response;
  if (offResponse.statusCode == 200) {
    final data = json.decode(offResponse.body);
    final products = data['products'] as List;
    offResults.addAll(products.map((product) => FoodItem.fromJson(product)));
  }

  // 4. Combine and rank results: Supabase results first, then OpenFoodFacts
  final combined = <String, FoodItem>{};

  // Add Supabase results first to prioritize them
  for (var item in supabaseResults) {
    combined[item.code] = item;
  }

  // Add OpenFoodFacts results, but don't overwrite existing ones from Supabase
  for (var item in offResults) {
    combined.putIfAbsent(item.code, () => item);
  }

  // Convert the map back to a list, maintaining the prioritized order
  return combined.values.toList();
});

class AddFoodScreen extends ConsumerStatefulWidget {
  final MealType mealType;

  const AddFoodScreen({super.key, required this.mealType});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerController.dispose(); // Dispose the new controller
    super.dispose();
  }

  // Function to handle live barcode scanning
  Future<void> _scanBarcode() async {
    final String? barcode = await Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (barcode != null) {
      _searchController.text = barcode;
    }
  }

  // Function to handle scanning from a photo
  Future<void> _scanFromPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        image.path,
      );
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? barcode = capture.barcodes.first.rawValue;
        if (barcode != null) {
          _searchController.text = barcode;
        } else {
          _showErrorDialog('Kein Barcode im Bild gefunden.');
        }
      } else {
        _showErrorDialog('Barcode konnte nicht analysiert werden.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(foodSearchProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Apple White
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFF6F1E7), // Apple White
        middle: const Text('Lebensmittel hinzufügen'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: _scanBarcode,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.barcode_viewfinder),
                          SizedBox(width: 8),
                          Text('Live Scan'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: _scanFromPhoto,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.photo_camera),
                          SizedBox(width: 8),
                          Text('Foto Scan'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: '...oder suche manuell',
              ),
            ),
            Expanded(
              child: searchResults.when(
                data: (foods) => ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return CupertinoListTile(
                      title: Text(food.productName),
                      subtitle: Text(
                        '${food.nutriments.energyKcal100g?.toStringAsFixed(0) ?? "N/A"} kcal / 100g',
                      ),
                      onTap: () => _showAddFoodDialog(food),
                    );
                  },
                ),
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (err, stack) => Center(child: Text('Fehler: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(FoodItem food) {
    double quantity = 100;
    final diaryNotifier = ref.read(diaryProvider.notifier);
    final quantityController = TextEditingController(text: quantity.toString());

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(food.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('Menge (in g):'),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quantity = double.tryParse(value) ?? 100;
              },
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () {
              print('DEBUG: Abbrechen pressed');
              quantityController.dispose();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Hinzufügen'),
            onPressed: () {
              print('DEBUG: Hinzufügen pressed');
              // Get final quantity from controller
              final finalQuantity =
                  double.tryParse(quantityController.text) ?? 100;
              print('DEBUG: Final quantity: $finalQuantity');

              final nutriments = food.nutriments;
              if (nutriments.energyKcal100g == null) {
                print('DEBUG: No nutrition data');
                quantityController.dispose();
                Navigator.pop(context);
                return;
              }

              // Calculate nutrition values
              final calories =
                  (nutriments.energyKcal100g ?? 0) * (finalQuantity / 100);
              final protein =
                  (nutriments.proteins100g ?? 0) * (finalQuantity / 100);
              final carbs =
                  (nutriments.carbohydrates100g ?? 0) * (finalQuantity / 100);
              final fat = (nutriments.fat100g ?? 0) * (finalQuantity / 100);
              final fiber = (nutriments.fiber100g ?? 0) * (finalQuantity / 100);
              final sugar =
                  (nutriments.sugars100g ?? 0) * (finalQuantity / 100);
              // Correct sodium calculation: use sodium_100g and convert to mg
              final sodium =
                  (nutriments.sodium100g ?? 0) * (finalQuantity / 100) * 1000;

              print(
                'DEBUG: Nutrition values - Calories: $calories, Protein: $protein, Carbs: $carbs, Fat: $fat',
              );
              print(
                'DEBUG: Additional nutrients - Fiber: $fiber, Sugar: $sugar, Sodium: $sodium',
              );

              print('DEBUG: Adding diary entry...');
              diaryNotifier.addDiaryEntry(
                mealType: widget.mealType.name,
                foodName: food.productName,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sugar: sugar,
                sodium: sodium,
                quantity: finalQuantity,
                productCode: food.code,
              );

              quantityController.dispose();

              // Use Navigator.popUntil to ensure we get back to the right screen
              Navigator.of(context).popUntil((route) {
                print('DEBUG: Route name: ${route.settings.name}');
                return route.isFirst || route.settings.name == '/diary';
              });

              // Show success animation/feedback
              _showSuccessAnimation(food.productName);

              print('DEBUG: Navigation completed successfully');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessAnimation(String foodName) {
    // Show a iOS-style haptic feedback and overlay
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: CupertinoColors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.activeGreen,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Hinzugefügt!',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Dialog was dismissed
    });

    // Auto dismiss after 0.8 seconds
    Timer(const Duration(milliseconds: 800), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
}
