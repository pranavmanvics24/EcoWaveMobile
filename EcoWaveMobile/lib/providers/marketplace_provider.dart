import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  Future<void> loadProducts({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    
    try {
      final results = await _api.getProducts(
        category: _selectedCategory,
        search: _searchQuery,
      );
      _products = results;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('DioException', 'Network error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String cat) {
    if (_selectedCategory == cat) return;
    _selectedCategory = cat;
    loadProducts();
  }

  void setSearch(String q) {
    if (_searchQuery == q) return;
    _searchQuery = q;
    // For search, we might want a slight debounce or just load
    loadProducts(silent: true);
  }

  void refresh() => loadProducts();
}
