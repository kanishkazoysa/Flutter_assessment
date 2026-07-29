import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// The main screen that displays a searchable grid of products.
///
/// Features:
/// - Clean search bar with notification icon.
/// - Promotional banner card.
/// - Horizontal scrollable category filter chips.
/// - "Featured Products" section header.
/// - 2-column grid layout of product cards.
/// - Loading, error, and empty state handling.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  static const List<_PromoSlide> _promoSlides = [
    _PromoSlide(
      image: 'assets/images/promo_banner_2.png',
      title: 'New arrivals added to the catalogue every week',
      subtitle: 'Check out the latest styles',
    ),
    _PromoSlide(
      image: 'assets/images/promo_banner_3.png',
      title: 'Free shipping on your first order today',
      subtitle: 'Limited time offer',
    ),
    _PromoSlide(
      image: 'assets/images/promo_banner.png',
      title: 'Discount up to 45% on every dress rental for events',
      subtitle: 'Only for this week',
    ),
  ];

  Timer? _promoTimer;
  int _promoPage = 0;

  @override
  void initState() {
    super.initState();
    _startPromoAutoScroll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: filteredProducts.when(
              loading: () => const LoadingWidget(),
              error: (error, stackTrace) => ErrorDisplayWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(productProvider);
                },
              ),
              data: (products) {
                return CustomScrollView(
                  slivers: [
                    // ── Search Bar Section ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            // Search field (Clean borderless rounded container)
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      ref
                                              .read(
                                                searchQueryProvider.notifier,
                                              )
                                              .state =
                                          value;
                                    },
                                    style: theme.textTheme.bodyMedium,
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Colors.grey.shade500,
                                        size: 22,
                                      ),
                                      suffixIcon: searchQuery.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                _searchController.clear();
                                                ref
                                                        .read(
                                                          searchQueryProvider
                                                              .notifier,
                                                        )
                                                        .state =
                                                    '';
                                              },
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.grey.shade500,
                                                size: 20,
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Theme toggle button (Smaller rounded square with light border)
                            GestureDetector(
                              onTap: () {
                                ref.read(themeProvider.notifier).toggleTheme();
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  themeMode == ThemeMode.dark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: theme.colorScheme.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Promotional Banner ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildPromoBanner(context),
                      ),
                    ),

                    // ── Category Chips ────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: categoriesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (categories) => Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: categories.length + 1, // +1 for "All"
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildCategoryChip(
                                    context,
                                    label: 'All',
                                    isSelected: selectedCategory == null,
                                    onTap: () {
                                      ref
                                              .read(
                                                selectedCategoryProvider
                                                    .notifier,
                                              )
                                              .state =
                                          null;
                                    },
                                  );
                                }
                                final category = categories[index - 1];
                                return _buildCategoryChip(
                                  context,
                                  label: _capitalizeCategory(category),
                                  isSelected: selectedCategory == category,
                                  onTap: () {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state = selectedCategory == category
                                        ? null
                                        : category;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Section Header ────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Products',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Product count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${products.length} items',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Product Grid or Empty State ───────────────────────────
                    if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateWidget(
                          title: searchQuery.isNotEmpty
                              ? 'No results for "$searchQuery"'
                              : selectedCategory != null
                              ? 'No products in this category'
                              : 'No products available',
                          subtitle: searchQuery.isNotEmpty
                              ? 'Try a different search term.'
                              : selectedCategory != null
                              ? 'Try selecting a different category.'
                              : 'Check back later for new products.',
                          icon: searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.inventory_2_outlined,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          90,
                        ), // Bottom padding so items scroll behind floating bar
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 294,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 18,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              index: index,
                              onTap: () => _navigateToDetail(context, product),
                            );
                          }, childCount: products.length),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Floating Bottom Navigation Bar ───────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262626) : Colors.white,
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.12),
                    blurRadius: isDark ? 24 : 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Home
                  IconButton(
                    icon: Icon(
                      _selectedNavIndex == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color: _selectedNavIndex == 0
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 0;
                      });
                    },
                  ),
                  // 2. Categories / List
                  IconButton(
                    icon: Icon(
                      _selectedNavIndex == 1
                          ? Icons.dashboard_rounded
                          : Icons.dashboard_outlined,
                      color: _selectedNavIndex == 1
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 1;
                      });
                    },
                  ),
                  // 3. Cart
                  IconButton(
                    icon: Icon(
                      _selectedNavIndex == 2
                          ? Icons.shopping_bag_rounded
                          : Icons.shopping_bag_outlined,
                      color: _selectedNavIndex == 2
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 2;
                      });
                    },
                  ),
                  // 4. Favourites
                  IconButton(
                    icon: Icon(
                      _selectedNavIndex == 3
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _selectedNavIndex == 3
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 3;
                      });
                    },
                  ),
                  // 5. User Profile
                  IconButton(
                    icon: Icon(
                      _selectedNavIndex == 4
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      color: _selectedNavIndex == 4
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 4;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPromoAutoScroll() {
    _promoTimer?.cancel();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _promoPage = (_promoPage + 1) % _promoSlides.length;
      });
    });
  }

  /// Builds a single promotional banner whose image and content animate in-place.
  Widget _buildPromoBanner(BuildContext context) {
    final theme = Theme.of(context);
    final slide = _promoSlides[_promoPage];

    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1100),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                  reverseCurve: Curves.easeInOutCubic,
                );
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(opacity: curved, child: child),
                );
              },
              child: SizedBox.expand(
                key: ValueKey(slide.image),
                child: Transform.flip(
                  flipX: true,
                  child: Image.asset(
                    slide.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF042E2B));
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 220,
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 950),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                        reverseCurve: Curves.easeInOutCubic,
                      );
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.025, 0),
                          end: Offset.zero,
                        ).animate(curved),
                        child: FadeTransition(opacity: curved, child: child),
                      );
                    },
                    child: Column(
                      key: ValueKey(slide.title),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            slide.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          slide.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Buy Now',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_promoSlides.length, (
                          dotIndex,
                        ) {
                          final isActive = dotIndex == _promoPage;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isActive ? 14 : 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a category filter chip.
  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.0,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  /// Capitalizes the first letter of each word in a category name.
  String _capitalizeCategory(String category) {
    return category
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : word,
        )
        .join(' ');
  }

  /// Navigates to the product detail screen with a smooth custom transition.
  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductDetailScreen(product: product);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curveAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.06),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Data for a single slide in the promotional banner carousel.
class _PromoSlide {
  final String image;
  final String title;
  final String subtitle;

  const _PromoSlide({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
