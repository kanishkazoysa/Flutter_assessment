import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/products/screens/product_list_screen.dart';

/// Root application widget.
///
/// Wraps the app with Riverpod's [ConsumerWidget] to listen
/// to the theme provider and apply light/dark themes.
class ProductCatalogueApp extends ConsumerWidget {
  const ProductCatalogueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Product Catalogue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const ProductListScreen(),
    );
  }
}
