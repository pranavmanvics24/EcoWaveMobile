// ── Data models (mirrors Kotlin Models.kt) ──────────────────────────────────

class EcoImpact {
  final double co2;
  final double water;
  final double waste;

  const EcoImpact({this.co2 = 0, this.water = 0, this.waste = 0});

  factory EcoImpact.fromJson(Map<String, dynamic> j) => EcoImpact(
        co2: (j['co2'] as num?)?.toDouble() ?? 0,
        water: (j['water'] as num?)?.toDouble() ?? 0,
        waste: (j['waste'] as num?)?.toDouble() ?? 0,
      );
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String badge;
  final String image;
  final String category;
  final String material;
  final EcoImpact? ecoImpact;
  final String sellerId;
  final String sellerEmail;
  final String sellerLocation;
  final String sellerPhone;
  final String createdAt;
  final String status;

  const Product({
    this.id = '',
    this.title = '',
    this.description = '',
    this.price = 0,
    this.badge = '',
    this.image = '',
    this.category = '',
    this.material = '',
    this.ecoImpact,
    this.sellerId = '',
    this.sellerEmail = '',
    this.sellerLocation = '',
    this.sellerPhone = '',
    this.createdAt = '',
    this.status = 'active',
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        badge: j['badge'] as String? ?? '',
        image: j['image'] as String? ?? '',
        category: j['category'] as String? ?? '',
        material: j['material'] as String? ?? '',
        ecoImpact: j['eco_impact'] != null
            ? EcoImpact.fromJson(j['eco_impact'] as Map<String, dynamic>)
            : null,
        sellerId: j['seller_id'] as String? ?? '',
        sellerEmail: j['seller_email'] as String? ?? '',
        sellerLocation: j['seller_location'] as String? ?? '',
        sellerPhone: j['seller_phone'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
        status: j['status'] as String? ?? 'active',
      );
}

class ImpactStats {
  final double co2Saved;
  final double waterSaved;
  final double wasteSaved;
  final int itemsRecycled;
  final int itemsPurchased;

  const ImpactStats({
    this.co2Saved = 0,
    this.waterSaved = 0,
    this.wasteSaved = 0,
    this.itemsRecycled = 0,
    this.itemsPurchased = 0,
  });

  factory ImpactStats.fromJson(Map<String, dynamic> j) => ImpactStats(
        co2Saved: (j['co2_saved'] as num?)?.toDouble() ?? 0,
        waterSaved: (j['water_saved'] as num?)?.toDouble() ?? 0,
        wasteSaved: (j['waste_saved'] as num?)?.toDouble() ?? 0,
        itemsRecycled: j['items_recycled'] as int? ?? 0,
        itemsPurchased: j['items_purchased'] as int? ?? 0,
      );
}

class User {
  final String email;
  final String name;
  final String token;

  const User({this.email = '', this.name = '', this.token = ''});

  factory User.fromJson(Map<String, dynamic> j) => User(
        email: j['email'] as String? ?? '',
        name: j['name'] as String? ?? '',
        token: j['token'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'token': token,
      };
}

class InquiryRequest {
  final String productId;
  final String buyerName;
  final String buyerEmail;
  final String buyerMessage;

  const InquiryRequest({
    required this.productId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerMessage,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'buyer_name': buyerName,
        'buyer_email': buyerEmail,
        'buyer_message': buyerMessage,
      };
}

class CreateProductRequest {
  final String title;
  final String description;
  final double price;
  final String badge;
  final String image;
  final String category;
  final String material;
  final String sellerEmail;
  final String sellerLocation;
  final String sellerId;

  const CreateProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.badge,
    required this.image,
    required this.category,
    required this.material,
    required this.sellerEmail,
    required this.sellerLocation,
    this.sellerId = 'anonymous',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'badge': badge,
        'image': image,
        'category': category,
        'material': material,
        'seller_email': sellerEmail,
        'seller_location': sellerLocation,
        'seller_id': sellerId,
      };
}
