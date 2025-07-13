import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/food_item.dart';
import 'package:trackfood/models/meal_type.dart';
import 'package:trackfood/providers/diary_provider.dart'
    hide supabaseServiceProvider; // Hide the conflicting provider
import 'package:trackfood/services/supabase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'barcode_scanner_screen.dart';

// A simple provider to manage the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// A future provider to fetch search results from Supabase and OpenFoodFacts
final foodSearchProvider = FutureProvider<List<FoodItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) {
    return [];
  }

  final supabaseService = ref.watch(supabaseServiceProvider);

  // 1. Search in Supabase first
  final supabaseResults = await supabaseService.searchProducts(query);
  if (supabaseResults.isNotEmpty) {
    return supabaseResults;
  }

  // 2. Fallback to OpenFoodFacts if no results in Supabase
  final response = await http.get(
    Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=20',
    ),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final products = data['products'] as List;
    return products.map((product) => FoodItem.fromJson(product)).toList();
  } else {
    throw Exception('Failed to load food items from OpenFoodFacts');
  }
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

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(food.productName),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text('Menge (in g):'),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: TextEditingController(text: quantity.toString()),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final nutriments = food.nutriments;
              if (nutriments.energyKcal100g == null) {
                // Optional: Show an error if there's no calorie data
                return;
              }
              diaryNotifier.addDiaryEntry(
                mealType: widget.mealType.name,
                foodName: food.productName,
                calories: (nutriments.energyKcal100g ?? 0) * (quantity / 100),
                protein: (nutriments.proteins100g ?? 0) * (quantity / 100),
                carbs: (nutriments.carbohydrates100g ?? 0) * (quantity / 100),
                fat: (nutriments.fat100g ?? 0) * (quantity / 100),
                quantity: quantity,
                productCode: food.code,
              );
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to diary screen

              // Show a confirmation dialog
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Erfolgreich'),
                  content: Text('${food.productName} wurde hinzugefügt.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}
