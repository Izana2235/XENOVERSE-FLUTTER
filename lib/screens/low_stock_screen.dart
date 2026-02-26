import 'package:flutter/material.dart';
import '../models/app_state.dart';

class LowStockScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;

  const LowStockScreen({
    super.key,
    required this.appState,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final headerMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);

    final lowStock = appState.lowStockProducts;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Low Stock Items',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Products requiring restocking',
              style: TextStyle(color: textMuted, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use compact layout on narrow screens
                final isNarrow = constraints.maxWidth < 480;
                return Container(
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: isDark
                        ? null
                        : Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: lowStock.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF22C88A), size: 52),
                              const SizedBox(height: 12),
                              Text(
                                'All stock levels are healthy!',
                                style:
                                    TextStyle(color: textPrimary, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                          ),
                        )
                      : Column(
                          children: [
                            // ── Table header ──────────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 13),
                              child: Row(children: [
                                Expanded(
                                  flex: isNarrow ? 5 : 4,
                                  child: Text(
                                    'Product',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: headerMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                                if (!isNarrow)
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Category',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: headerMuted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Price',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: headerMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Stock',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: headerMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                              ]),
                            ),
                            Divider(color: divider, height: 1),

                            // ── Table rows ─────────────────────────────────
                            ...lowStock.map(
                              (p) => Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 11),
                                  child: Row(children: [
                                    // Product column
                                    Expanded(
                                      flex: isNarrow ? 5 : 4,
                                      child: Row(children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: Image.network(
                                            p.imageUrl,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 40,
                                              height: 40,
                                              color: isDark
                                                  ? Colors.white12
                                                  : const Color(0xFFF3F4F6),
                                              child: Icon(Icons.image,
                                                  color: isDark
                                                      ? Colors.white38
                                                      : Colors.black26,
                                                  size: 18),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: textPrimary,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13),
                                              ),
                                              Text(
                                                'ID: ${p.id}',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: textMuted,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                    // Category (hidden on narrow)
                                    if (!isNarrow)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          p.category,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: textMuted, fontSize: 13),
                                        ),
                                      ),
                                    // Price — PHP
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₱${p.price.toStringAsFixed(2)}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: textPrimary, fontSize: 13),
                                      ),
                                    ),
                                    // Stock badge
                                    Expanded(
                                      flex: 2,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5C518)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${p.stock} units',
                                            style: const TextStyle(
                                                color: Color(0xFFF5C518),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                Divider(color: divider, height: 1),
                              ]),
                            ),
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
