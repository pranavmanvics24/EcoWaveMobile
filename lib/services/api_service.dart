import 'package:dio/dio.dart';
import '../models/models.dart';
import '../config/server_config.dart';

final String _baseUrl = serverUrl;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      request: false,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // ── Auth helper ──────────────────────────────────────────────────────────
  String? _token;
  void setToken(String? token) => _token = token;

  Options get _authOptions => Options(headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

  Future<User> login(String email, String name) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email,
      'name': name,
    });
    final data = res.data;
    final token = data['token'] as String;
    final userMap = data['user'] as Map<String, dynamic>;
    userMap['token'] = token;
    return User.fromJson(userMap);
  }

  // ── Products ─────────────────────────────────────────────────────────────
  Future<List<Product>> getProducts({
    String? category,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (category != null && category != 'all') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _dio.get('/api/products', queryParameters: params);
    final list = res.data['products'] as List<dynamic>? ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(String id) async {
    final res = await _dio.get('/api/products/$id');
    return Product.fromJson(res.data['product'] as Map<String, dynamic>);
  }

  Future<Product> createProduct(CreateProductRequest req) async {
    final res = await _dio.post('/api/products', data: req.toJson());
    return Product.fromJson(res.data['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('/api/products/$id');
  }

  Future<List<Product>> getProductsBySeller(String email) async {
    final res = await _dio.get('/api/products/seller/$email');
    final list = res.data['products'] as List<dynamic>? ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Inquiries ────────────────────────────────────────────────────────────
  Future<void> sendInquiry(InquiryRequest req) async {
    await _dio.post('/api/inquiries', data: req.toJson());
  }

  // ── User impact ──────────────────────────────────────────────────────────
  Future<ImpactStats?> getUserImpact() async {
    try {
      final res = await _dio.get('/api/user/impact', options: _authOptions);
      if (res.data['impact'] != null) {
        return ImpactStats.fromJson(res.data['impact'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // ── UPI Payments ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createTransaction({
    required String productId,
    required String buyerEmail,
    required String sellerUpiId,
    required double amount,
  }) async {
    final res = await _dio.post('/api/payments/create-transaction', data: {
      'product_id': productId,
      'buyer_email': buyerEmail,
      'seller_upi_id': sellerUpiId,
      'amount': amount,
    });
    return res.data['transaction'] as Map<String, dynamic>;
  }

  Future<bool> confirmPayment({
    required String txnId,
    required String productId,
    required String buyerEmail,
  }) async {
    try {
      final res = await _dio.post('/api/payments/confirm', data: {
        'txn_id': txnId,
        'product_id': productId,
        'buyer_email': buyerEmail,
      });
      return res.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
