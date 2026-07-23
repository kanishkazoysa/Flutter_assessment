import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../favourites/providers/favourites_provider.dart';
import '../models/product.dart';

/// Screen that displays the full details of a selected product.
///
/// Shows a hero-animated image, product name, price, category,
/// full description, rating information, and a favourite toggle.
class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favourites = ref.watch(favouritesProvider);
    final isFavourite = favourites.contains(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing App Bar with Product Image ──────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.surface.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.surface.withValues(alpha: 0.85),
                  child: IconButton(
                    icon: Icon(
                      isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavourite
                          ? AppTheme.favouriteActiveColor
                          : theme.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      ref
                          .read(favouritesProvider.notifier)
                          .toggleFavourite(product.id);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-image-${product.id}',
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Product Details ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product title
                  Text(
                    product.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  // Price and rating row
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildRatingChip(context),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 16),

                  // Description header
                  Text(
                    'Description',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Full description
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Favourite FAB ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref
              .read(favouritesProvider.notifier)
              .toggleFavourite(product.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavourite
                    ? '${product.title} removed from favourites'
                    : '${product.title} added to favourites',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        icon: Icon(
          isFavourite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
        ),
        label: Text(
          isFavourite ? 'Remove Favourite' : 'Add to Favourites',
        ),
        backgroundColor: isFavourite
            ? AppTheme.favouriteActiveColor
            : theme.colorScheme.primaryContainer,
        foregroundColor: isFavourite
            ? Colors.white
            : theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Builds the rating indicator chip.
  Widget _buildRatingChip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 18,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '${product.rating.rate}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${product.rating.count})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
