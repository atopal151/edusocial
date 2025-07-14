import 'package:flutter/material.dart';

class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadMore,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (!isLoading && items.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('Veri bulunamadı'),
          );
    }

    Widget listView = ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      // 🚀 Performans optimizasyonları
      addAutomaticKeepAlives: false, // Widget'ları hafızada tutma
      addRepaintBoundaries: false,   // Gereksiz repaint'leri engelle
      cacheExtent: 200.0,           // Önceden yüklenecek alan
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Infinite scroll için load more tetikle
        if (onLoadMore != null && index == items.length - 5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoadMore!();
          });
        }

        // RepaintBoundary ile widget'ı izole et
        return RepaintBoundary(
          child: itemBuilder(context, item, index),
        );
      },
    );

    // Pull-to-refresh ekle
    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: onRefresh!,
        color: const Color(0xFFEF5050),
        backgroundColor: const Color(0xfffafafa),
        strokeWidth: 2.0,
        displacement: 40.0,
        child: listView,
      );
    }

    return listView;
  }
}

/// Grid view için optimize edilmiş versiyon
class OptimizedGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadMore,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (!isLoading && items.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('Veri bulunamadı'),
          );
    }

    Widget gridView = GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 200.0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Infinite scroll
        if (onLoadMore != null && index == items.length - 5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoadMore!();
          });
        }

        return RepaintBoundary(
          child: itemBuilder(context, item, index),
        );
      },
    );

    if (onRefresh != null) {
      gridView = RefreshIndicator(
        onRefresh: onRefresh!,
        color: const Color(0xFFEF5050),
        backgroundColor: const Color(0xfffafafa),
        strokeWidth: 2.0,
        displacement: 40.0,
        child: gridView,
      );
    }

    return gridView;
  }
} 