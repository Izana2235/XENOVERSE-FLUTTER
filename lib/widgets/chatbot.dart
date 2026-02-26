import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/app_state.dart';

class ChatbotWidget extends StatefulWidget {
  final AppState appState;

  const ChatbotWidget({super.key, required this.appState});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hi! I'm your Store Assistant 🛍️\nAsk me about products, stock levels, order history, or anything about your store!", isUser: false, time: DateTime.now()),
  ];

  void _toggleChat() => setState(() => _isOpen = !_isOpen);

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      final reply = _generateReply(text.toLowerCase());
      setState(() => _messages.add(ChatMessage(text: reply, isUser: false, time: DateTime.now())));
      Future.delayed(const Duration(milliseconds: 100), () {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  String _generateReply(String input) {
    final state = widget.appState;
    if (input.contains('product') && input.contains('how many') || input.contains('total product')) {
      return "You have ${state.products.length} products in your catalog across ${state.categories.length} categories.";
    }
    if (input.contains('low stock') || input.contains('running out')) {
      final lsp = state.lowStockProducts;
      if (lsp.isEmpty) return "Great news! No products are currently low on stock! ✅";
      return "⚠️ Low stock alert! ${lsp.length} product(s) need attention:\n${lsp.map((p) => '• ${p.name}: ${p.stock} units').join('\n')}";
    }
    if (input.contains('categor')) {
      return "You have ${state.categories.length} categories:\n${state.categories.map((c) => '${c.icon} ${c.name}').join('\n')}";
    }
    if (input.contains('most expensive') || input.contains('highest price')) {
      final sorted = [...state.products]..sort((a, b) => b.price.compareTo(a.price));
      return "The most expensive product is ${sorted.first.name} at \$${sorted.first.price.toStringAsFixed(2)}.";
    }
    if (input.contains('cheapest') || input.contains('lowest price')) {
      final sorted = [...state.products]..sort((a, b) => a.price.compareTo(b.price));
      return "The cheapest product is ${sorted.first.name} at \$${sorted.first.price.toStringAsFixed(2)}.";
    }
    if (input.contains('revenue') || input.contains('sales') || input.contains('income')) {
      return "Total revenue tracking is available in the Sales Report section. Currently showing \$0.00 as no orders have been placed yet.";
    }
    if (input.contains('order')) {
      return "No orders have been placed yet. Head to the Orders section to manage incoming orders!";
    }
    if (input.contains('help') || input.contains('what can you')) {
      return "I can help you with:\n• 📦 Product information & stock levels\n• 🏷️ Category overview\n• 📊 Quick sales insights\n• ⚠️ Low stock alerts\n• 💰 Pricing queries\n\nJust ask me anything!";
    }
    if (input.contains('stock') && !input.contains('low')) {
      final total = state.products.fold<int>(0, (sum, p) => sum + p.stock);
      return "Total stock across all products: $total units.\nYou have ${state.lowStockProducts.length} product(s) with low stock.";
    }
    if (input.contains('hello') || input.contains('hi') || input.contains('hey')) {
      return "Hello! 👋 How can I help you manage your store today?";
    }
    if (input.contains('thank')) {
      return "You're welcome! Is there anything else I can help you with? 😊";
    }
    // Search for product by name
    for (final p in state.products) {
      if (input.contains(p.name.toLowerCase())) {
        return "📦 ${p.name}\nCategory: ${p.category}\nPrice: \$${p.price.toStringAsFixed(2)}\nStock: ${p.stock} units${p.isLowStock ? '\n⚠️ Low stock!' : ''}";
      }
    }
    return "I'm not sure about that. You can ask me about products, stock levels, categories, pricing, or orders. Type 'help' to see what I can do!";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // FAB button
        Positioned(
          bottom: 24,
          right: 24,
          child: GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4B6BFB), Color(0xFF9B59B6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF4B6BFB).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(_isOpen ? Icons.close : Icons.chat_bubble_outline, color: Colors.white, size: 24),
            ),
          ),
        ),
        // Chat panel
        if (_isOpen)
          Positioned(
            bottom: 90,
            right: 24,
            child: _buildChatPanel(),
          ),
      ],
    );
  }

  Widget _buildChatPanel() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final inputHintColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    return Container(
      width: isMobile ? MediaQuery.of(context).size.width - 48 : 340,
      height: 460,
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4B6BFB), Color(0xFF9B59B6)], begin: Alignment.centerLeft, end: Alignment.centerRight),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Always here to help', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF22C88A), shape: BoxShape.circle),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: TextStyle(color: inputTextColor, fontSize: 13),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask about your store...',
                      hintStyle: TextStyle(color: inputHintColor, fontSize: 12),
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF4B6BFB), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBg = msg.isUser
        ? const Color(0xFF4B6BFB)
        : (isDark ? const Color(0xFF252840) : const Color(0xFFE5E7EB));
    final textColor = msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A1D2E));

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(msg.isUser ? 12 : 2),
            bottomRight: Radius.circular(msg.isUser ? 2 : 12),
          ),
        ),
        child: Text(msg.text, style: TextStyle(color: textColor, fontSize: 12.5, height: 1.4)),
      ),
    );
  }
}
