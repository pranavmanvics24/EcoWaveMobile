import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/marketplace_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ProfileProvider>().load(user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final profile = context.watch<ProfileProvider>();

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: ecoDark,
      body: CustomScrollView(
        slivers: [
          // ── App header ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(gradient: ecoHeaderGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('👤 My Profile',
                          style: TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      // Logout
                      TextButton.icon(
                        onPressed: () {
                          context.read<AuthProvider>().logout();
                          context.go('/landing');
                        },
                        icon: Icon(Icons.logout, color: ecoMuted, size: 18),
                        label: Text('Logout', style: TextStyle(color: ecoMuted, fontSize: 13)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Avatar + name
                    Row(children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          gradient: ecoGreenGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text(user.email,
                            style: TextStyle(color: ecoMuted, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ])),
                    ]),
                  ]),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Eco impact stats ─────────────────────────────────────
                const Text('🌍 Your Eco Impact',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _ImpactGrid(stats: profile.impactStats),
                const SizedBox(height: 28),

                // ── My listings ──────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('📦 My Listings',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('${profile.listings.length} items',
                      style: TextStyle(color: ecoMuted, fontSize: 12)),
                ]),
                const SizedBox(height: 12),

                if (profile.isLoading)
                  const Center(child: CircularProgressIndicator(color: ecoGreen))
                else if (profile.listings.isEmpty)
                  _EmptyListings()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: profile.listings.length,
                    itemBuilder: (_, i) => _ListingCard(
                      product: profile.listings[i],
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => _DeleteDialog(
                              title: profile.listings[i].title),
                        );
                        if (ok == true && mounted) {
                          profile.deleteListing(profile.listings[i].id);
                        }
                      },
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Eco Impact Grid ───────────────────────────────────────────────────────────

class _ImpactGrid extends StatelessWidget {
  final ImpactStats? stats;
  const _ImpactGrid({this.stats});

  @override
  Widget build(BuildContext context) {
    final s = stats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatCard('🌿', 'CO₂ Saved', s != null ? '${s.co2Saved.toStringAsFixed(1)} kg' : '0 kg'),
        _StatCard('💧', 'Water Saved', s != null ? '${s.waterSaved.toStringAsFixed(0)}L' : '0L'),
        _StatCard('♻️', 'Items Recycled', s != null ? '${s.itemsRecycled}' : '0'),
        _StatCard('🛍️', 'Items Bought', s != null ? '${s.itemsPurchased}' : '0'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  const _StatCard(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: ecoCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ecoBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              color: ecoGreenLight, fontWeight: FontWeight.w800, fontSize: 18)),
      Text(label, style: TextStyle(color: ecoMuted, fontSize: 11)),
    ]),
  );
}

// ── Listing Card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  const _ListingCard({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: ecoCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ecoBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 5,
        child: Stack(fit: StackFit.expand, children: [
          ProductImage(image: product.image),
          // Status badge
          Positioned(
            top: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: product.status == 'sold'
                    ? ecoMuted.withValues(alpha: 0.8)
                    : ecoLeaf.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                product.status == 'sold' ? 'Sold' : 'Active',
                style: const TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 6, right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: ecoError.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ]),
      ),
      Flexible(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('₹${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: ecoGreenLight, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ),
    ]),
  );
}

// ── Empty Listings ────────────────────────────────────────────────────────────

class _EmptyListings extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: ecoCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ecoBorder),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🌱', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 8),
      const Text('No listings yet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text('List your first eco-product!', style: TextStyle(color: ecoMuted, fontSize: 13)),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: ecoGreenGradient, borderRadius: BorderRadius.circular(12)),
          child: TextButton(
            onPressed: () => context.go('/sell'),
            child: const Text('Sell an Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]),
  );
}

// ── Delete Confirmation ───────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String title;
  const _DeleteDialog({required this.title});

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: ecoSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: const Text('Delete Listing', style: TextStyle(color: Colors.white)),
    content: Text('Remove "$title" from your listings?',
        style: TextStyle(color: ecoMuted)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel', style: TextStyle(color: ecoMuted)),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Delete', style: TextStyle(color: ecoError)),
      ),
    ],
  );
}
