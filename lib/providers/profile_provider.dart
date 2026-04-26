import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _listings = [];
  ImpactStats? _impactStats;
  bool _isLoading = false;
  String? _error;

  List<Product> get listings => _listings;
  ImpactStats? get impactStats => _impactStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _listings = await _api.getProductsBySeller(email);
    } catch (e) {
      _error = e.toString().replaceAll('DioException', 'Network error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // Load impact stats silently (doesn't block UI)
    _impactStats = await _api.getUserImpact();
    notifyListeners();
  }

  Future<void> deleteListing(String id) async {
    try {
      await _api.deleteProduct(id);
      _listings = _listings.where((p) => p.id != id).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> sendInquiry(InquiryRequest req) async {
    try {
      await _api.sendInquiry(req);
      return true;
    } catch (_) {
      return false;
    }
  }
}
