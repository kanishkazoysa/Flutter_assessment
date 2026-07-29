import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../favourites/providers/favourites_provider.dart';
import '../models/product.dart';

/// A card widget that displays a product's summary information.
///
/// Designed to match a clean, modern e-commerce card layout with:
/// - Rounded product image with white background
/// - Favourite heart icon overlay (top-right)
/// - Product name, price, and rating below the image
class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final int index;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.index,
    required this.onTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  double _favouriteScale = 1.0;
  double _cardScale = 1.0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    final delay = 80 + 40 * (widget.index % 6);
    Future<void>.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _isVisible = true;
      });
    });
  }

  Future<void> _handleFavouriteTap() async {
    setState(() {
      _favouriteScale = 0.82;
    });

    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;

    setState(() {
      _favouriteScale = 1.12;
    });

    ref.read(favouritesProvider.notifier).toggleFavourite(widget.product.id);

    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;

    setState(() {
      _favouriteScale = 1.0;
    });
  }

  Future<void> _handleCardTap() async {
    setState(() {
      _cardScale = 0.985;
    });

    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (!mounted) return;

    setState(() {
      _cardScale = 1.0;
    });

    widget.onTap();
  }

  String _formatCategory(String category) {
    return category
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favourites = ref.watch(favouritesProvider);
    final isFavourite = favourites.contains(widget.product.id);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 360 + (widget.index % 4) * 40),
      curve: Curves.easeOutCubic,
      opacity: _isVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 420 + (widget.index % 4) * 45),
        curve: Curves.easeOutCubic,
        offset: _isVisible ? Offset.zero : const Offset(0, 0.08),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _cardScale,
          child: GestureDetector(
            onTap: _handleCardTap,
            onTapDown: (_) {
              setState(() {
                _cardScale = 0.985;
              });
            },
            onTapCancel: () {
              setState(() {
                _cardScale = 1.0;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Hero(
                                  tag: 'product-image-${widget.product.id}',
                                  child: Container(
                                    color: isDark
                                        ? const Color(0xFF1E1E1E)
                                        : const Color(0xFFF0F0F0),
                                    padding: const EdgeInsets.all(20),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.product.image,
                                      fit: BoxFit.contain,
                                      fadeInDuration: const Duration(
                                        milliseconds: 320,
                                      ),
                                      fadeOutDuration: const Duration(
                                        milliseconds: 120,
                                      ),
                                      fadeInCurve: Curves.easeOutCubic,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.broken_image_rounded,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _handleFavouriteTap,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF2C2C2C)
                                            : Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedScale(
                                          scale: _favouriteScale,
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          curve: Curves.easeOutBack,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            transitionBuilder:
                                                (child, animation) {
                                                  final curved =
                                                      CurvedAnimation(
                                                        parent: animation,
                                                        curve:
                                                            Curves.easeOutBack,
                                                      );
                                                  return ScaleTransition(
                                                    scale: Tween<double>(
                                                      begin: 0.7,
                                                      end: 1.0,
                                                    ).animate(curved),
                                                    child: RotationTransition(
                                                      turns: Tween<double>(
                                                        begin: 0.08,
                                                        end: 0.0,
                                                      ).animate(curved),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                            child: Icon(
                                              isFavourite
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              key: ValueKey(isFavourite),
                                              size: 20,
                                              color: isFavourite
                                                  ? const Color(0xFF149C68)
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCategory(widget.product.category),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.product.rating.rate}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.product.rating.count})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.45,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
