import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/models.dart';
import '../providers/marketplace_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

const _categories = [
  ('all', 'All Items', '🌍'),
  ('clothing', 'Clothing', '👕'),
  ('home', 'Home', '🏠'),
  ('electronics', 'Electronics', '📱'),
  ('books', 'Books', '📚'),
  ('accessories', 'Accessories', '👜'),
  ('other', 'Other', '✨'),
];

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MarketplaceProvider>();

    return Scaffold(
      backgroundColor: ecoDark,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(gradient: ecoHeaderGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🌊 ', style: TextStyle(fontSize: 22)),
                      const Text('EcoWave',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ]),
                    Text('Discover sustainable products',
                        style: TextStyle(color: ecoMuted, fontSize: 13)),
                    const SizedBox(height: 14),

                    // Search
                    TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) {
                        setState(() {});
                        mp.setSearch(v);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search eco products...',
                        hintStyle: TextStyle(color: ecoMuted),
                        prefixIcon: Icon(Icons.search, color: ecoMuted),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: ecoMuted),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                  mp.setSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: ecoCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: ecoBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: ecoBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: ecoGreen, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CO2 pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ecoCard,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: ecoBorder),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🌿', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Total CO₂ Saved',
                              style: TextStyle(color: ecoMuted, fontSize: 10)),
                          const Text('25,847 kg',
                              style: TextStyle(
                                  color: ecoGreenLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ]),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category chips ────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final (id, label, emoji) = _categories[i];
                final selected = mp.selectedCategory == id;
                return FilterChip(
                  label: Text('$emoji $label', style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => mp.setCategory(id),
                  selectedColor: ecoGreen,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : ecoMuted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(color: selected ? ecoGreen : ecoBorder),
                  backgroundColor: ecoCard,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            ),
          ),

          // ── Product grid ──────────────────────────────────────────────────
          Expanded(child: _ProductGrid(mp: mp)),
        ],
      ),
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final MarketplaceProvider mp;
  const _ProductGrid({required this.mp});

  @override
  Widget build(BuildContext context) {
    if (mp.isLoading) {
      return const Center(child: CircularProgressIndicator(color: ecoGreen));
    }
    if (mp.error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('⚠️ ${mp.error}',
              style: TextStyle(color: ecoMuted), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: ecoGreen),
            onPressed: mp.refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    if (mp.products.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text('No products found',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text('Try different filters', style: TextStyle(color: ecoMuted, fontSize: 13)),
          TextButton(
            onPressed: () {
              mp.setCategory('all');
              mp.setSearch('');
            },
            child: const Text('Clear filters', style: TextStyle(color: ecoGreenLight)),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: ecoGreen,
      backgroundColor: ecoCard,
      onRefresh: mp.loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: mp.products.length,
        itemBuilder: (_, i) => _ProductCard(product: mp.products[i]),
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: ecoSurface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => ProductDetailSheet(product: product),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ecoCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ecoBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(fit: StackFit.expand, children: [
                ProductImage(image: product.image),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ecoLeaf.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(product.badge,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: ecoGreenLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const Spacer(),
                    if (product.ecoImpact != null)
                      Row(children: [
                        const Text('🌿', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text('${product.ecoImpact!.co2.toInt()}kg CO₂',
                            style: TextStyle(color: ecoMuted, fontSize: 10)),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product image ─────────────────────────────────────────────────────────────

class ProductImage extends StatelessWidget {
  final String image;
  const ProductImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.startsWith('data:')) {
      try {
        final bytes = Uri.parse(image).data!.contentAsBytes();
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: ecoCard),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
      color: ecoCard,
      child: const Center(child: Text('🌿', style: TextStyle(fontSize: 40))));
}

// ── Product detail bottom sheet ───────────────────────────────────────────────

class ProductDetailSheet extends StatefulWidget {
  final Product product;
  const ProductDetailSheet({super.key, required this.product});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final success = await ApiService().verifyPayment({
      'razorpay_order_id': response.orderId,
      'razorpay_payment_id': response.paymentId,
      'razorpay_signature': response.signature,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '🎉 Payment Successful!' : '❌ Verification Failed'),
          backgroundColor: success ? ecoGreen : ecoError,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Payment Failed: ${response.message}'), backgroundColor: ecoError),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _startPayment() async {
    try {
      final user = context.read<AuthProvider>().user;
      final order = await ApiService().createPaymentOrder(widget.product.price);
      
      var options = {
        'key': 'rzp_test_YOUR_KEY_ID', // Replace with your key from .env or config
        'amount': order['amount'],
        'name': 'EcoWave',
        'description': widget.product.title,
        'order_id': order['id'],
        'prefill': {
          'name': user?.name ?? 'Eco User',
          'email': user?.email ?? 'user@ecowave.com',
        },
        'theme': {'color': '#2E7D32'}
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: ecoBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(height: 220, child: ProductImage(image: product.image)),
          ),
          const SizedBox(height: 16),

          Text(product.title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 6),
          Text('₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: ecoGreenLight, fontWeight: FontWeight.w900, fontSize: 26)),

          if (product.ecoImpact != null) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 6, children: [
              _ImpactBadge('🌿 ${product.ecoImpact!.co2.toInt()}kg CO₂'),
              _ImpactBadge('💧 ${product.ecoImpact!.water.toInt()}L Water'),
              _ImpactBadge('♻️ ${product.ecoImpact!.waste}kg Waste'),
            ]),
          ],

          const SizedBox(height: 16),
          const Text('Description',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Text(product.description,
              style: TextStyle(color: ecoMuted, fontSize: 14, height: 1.6)),

          if (product.sellerLocation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('📍 ${product.sellerLocation}',
                    style: TextStyle(color: ecoMuted, fontSize: 13)),
                if (product.location != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push('/map', extra: product),
                    icon: const Icon(Icons.map, size: 16, color: ecoGreenLight),
                    label: const Text('View Map', style: TextStyle(color: ecoGreenLight, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: ecoGreenGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: _startPayment,
                    child: const Text('Buy Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ecoGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/chat', extra: product);
                  },
                  child: const Text('Chat', style: TextStyle(color: ecoGreenLight)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ImpactBadge extends StatelessWidget {
  final String text;
  const _ImpactBadge(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: ecoGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(text, style: const TextStyle(color: ecoGreenLight, fontSize: 11)),
  );
}

// ── Contact Seller Dialog ─────────────────────────────────────────────────────

class ContactSellerDialog extends StatefulWidget {
  final Product product;
  const ContactSellerDialog({super.key, required this.product});

  @override
  State<ContactSellerDialog> createState() => _ContactSellerDialogState();
}

class _ContactSellerDialogState extends State<ContactSellerDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _msgCtrl.text.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    setState(() { _sending = true; _error = null; });
    try {
      await ApiService().sendInquiry(InquiryRequest(
        productId: widget.product.id,
        buyerName: _nameCtrl.text.trim(),
        buyerEmail: _emailCtrl.text.trim(),
        buyerMessage: _msgCtrl.text.trim(),
      ));
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to send. Try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ecoSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _SuccessView(email: _emailCtrl.text) : _FormView(
          nameCtrl: _nameCtrl,
          emailCtrl: _emailCtrl,
          msgCtrl: _msgCtrl,
          product: widget.product,
          sending: _sending,
          error: _error,
          onSend: _send,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('✅', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 12),
    const Text('Inquiry Sent!',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text('The seller will contact you at $email',
        textAlign: TextAlign.center,
        style: TextStyle(color: ecoMuted, fontSize: 13)),
    const SizedBox(height: 20),
    SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done', style: TextStyle(color: ecoGreenLight)),
      ),
    ),
  ]);
}

class _FormView extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, msgCtrl;
  final Product product;
  final bool sending;
  final String? error;
  final VoidCallback onSend, onClose;

  const _FormView({
    required this.nameCtrl, required this.emailCtrl, required this.msgCtrl,
    required this.product, required this.sending, required this.error,
    required this.onSend, required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Row(children: [
      const Text('💬 ', style: TextStyle(fontSize: 18)),
      const Text('Contact Seller',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
    Text('About: ${product.title}',
        style: TextStyle(color: ecoMuted, fontSize: 12),
        overflow: TextOverflow.ellipsis),
    const SizedBox(height: 16),
    _DlgField(ctrl: nameCtrl, hint: 'Your Name'),
    const SizedBox(height: 10),
    _DlgField(ctrl: emailCtrl, hint: 'Your Email', type: TextInputType.emailAddress),
    const SizedBox(height: 10),
    _DlgField(ctrl: msgCtrl, hint: 'Your message...', maxLines: 4),
    if (error != null) ...[
      const SizedBox(height: 8),
      Text(error!, style: const TextStyle(color: ecoError, fontSize: 12)),
    ],
    const SizedBox(height: 16),
    SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: ecoGreenGradient, borderRadius: BorderRadius.circular(12)),
        child: TextButton(
          onPressed: sending ? null : onSend,
          child: sending
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Send Inquiry',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    ),
  ]);
}

class _DlgField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? type;
  final int maxLines;
  const _DlgField({required this.ctrl, required this.hint, this.type, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: type,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: ecoMuted, fontSize: 13),
      filled: true, fillColor: ecoCard,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: ecoBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: ecoBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ecoGreen)),
    ),
  );
}
