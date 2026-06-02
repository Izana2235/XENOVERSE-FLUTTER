import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/settings_scroll_target.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Localization ──────────────────────────────────────────────────────────────
String _currencySymbol(String currency) {
  final match = RegExp(r'\((.+?)\)').firstMatch(currency);
  return match != null ? match.group(1)! : '₱';
}

class AppLocalizations {
  final String language;
  const AppLocalizations(this.language);

  static const _strings = <String, Map<String, String>>{
    'Settings': {'Filipino': 'Mga Setting', 'Japanese': '設定', 'Spanish': 'Configuración', 'French': 'Paramètres', 'Korean': '설정', 'Chinese': '设置'},
    'Customize your admin panel': {'Filipino': 'I-customize ang iyong admin panel', 'Japanese': '管理パネルをカスタマイズ', 'Spanish': 'Personaliza tu panel de administración', 'French': 'Personnalisez votre panneau d\'administration', 'Korean': '관리 패널 사용자 정의', 'Chinese': '自定义您的管理面板'},
    'Appearance': {'Filipino': 'Hitsura', 'Japanese': '外観', 'Spanish': 'Apariencia', 'French': 'Apparence', 'Korean': '화면', 'Chinese': '外观'},
    'Theme': {'Filipino': 'Tema', 'Japanese': 'テーマ', 'Spanish': 'Tema', 'French': 'Thème', 'Korean': '테마', 'Chinese': '主题'},
    'Choose your preferred appearance': {'Filipino': 'Piliin ang iyong gusto', 'Japanese': 'お好みの外観を選択', 'Spanish': 'Elige tu apariencia preferida', 'French': 'Choisissez votre apparence préférée', 'Korean': '원하는 외관 선택', 'Chinese': '选择您喜欢的外观'},
    'Light': {'Filipino': 'Maliwanag', 'Japanese': 'ライト', 'Spanish': 'Claro', 'French': 'Clair', 'Korean': '라이트', 'Chinese': '浅色'},
    'Dark': {'Filipino': 'Madilim', 'Japanese': 'ダーク', 'Spanish': 'Oscuro', 'French': 'Sombre', 'Korean': '다크', 'Chinese': '深色'},
    'System': {'Filipino': 'Sistema', 'Japanese': 'システム', 'Spanish': 'Sistema', 'French': 'Système', 'Korean': '시스템', 'Chinese': '系统'},
    'Store Information': {'Filipino': 'Impormasyon ng Tindahan', 'Japanese': '店舗情報', 'Spanish': 'Información de la tienda', 'French': 'Informations du magasin', 'Korean': '매장 정보', 'Chinese': '商店信息'},
    'Store Name': {'Filipino': 'Pangalan ng Tindahan', 'Japanese': '店舗名', 'Spanish': 'Nombre de la tienda', 'French': 'Nom du magasin', 'Korean': '매장 이름', 'Chinese': '店铺名称'},
    'Country': {'Filipino': 'Bansa', 'Japanese': '国', 'Spanish': 'País', 'French': 'Pays', 'Korean': '국가', 'Chinese': '国家'},
    'Currency': {'Filipino': 'Pera', 'Japanese': '通貨', 'Spanish': 'Moneda', 'French': 'Devise', 'Korean': '통화', 'Chinese': '货币'},
    'Language': {'Filipino': 'Wika', 'Japanese': '言語', 'Spanish': 'Idioma', 'French': 'Langue', 'Korean': '언어', 'Chinese': '语言'},
    'Low Stock Threshold': {'Filipino': 'Limitasyon ng Mababang Stock', 'Japanese': '在庫少量しきい値', 'Spanish': 'Umbral de stock bajo', 'French': 'Seuil de stock bas', 'Korean': '낮은 재고 임계값', 'Chinese': '低库存阈值'},
    'Account': {'Filipino': 'Account', 'Japanese': 'アカウント', 'Spanish': 'Cuenta', 'French': 'Compte', 'Korean': '계정', 'Chinese': '账户'},
    'Admin Name': {'Filipino': 'Pangalan ng Admin', 'Japanese': '管理者名', 'Spanish': 'Nombre del administrador', 'French': 'Nom de l\'administrateur', 'Korean': '관리자 이름', 'Chinese': '管理员名称'},
    'Notifications': {'Filipino': 'Mga Notification', 'Japanese': '通知', 'Spanish': 'Notificaciones', 'French': 'Notifications', 'Korean': '알림', 'Chinese': '通知'},
    'Configure alert preferences': {'Filipino': 'I-configure ang mga alerto', 'Japanese': 'アラート設定を構成', 'Spanish': 'Configurar preferencias de alerta', 'French': 'Configurer les préférences d\'alerte', 'Korean': '알림 설정 구성', 'Chinese': '配置提醒偏好'},
    'Log Out': {'Filipino': 'Mag-logout', 'Japanese': 'ログアウト', 'Spanish': 'Cerrar sesión', 'French': 'Déconnexion', 'Korean': '로그아웃', 'Chinese': '退出登录'},
    'Sign out of the admin panel': {'Filipino': 'Mag-sign out sa admin panel', 'Japanese': '管理パネルからサインアウト', 'Spanish': 'Cerrar sesión del panel de administración', 'French': 'Se déconnecter du panneau d\'administration', 'Korean': '관리 패널에서 로그아웃', 'Chinese': '退出管理面板'},
    'Are you sure you want to log out?': {'Filipino': 'Sigurado ka bang mag-logout?', 'Japanese': '本当にログアウトしますか？', 'Spanish': '¿Estás seguro de que deseas cerrar sesión?', 'French': 'Êtes-vous sûr de vouloir vous déconnecter ?', 'Korean': '정말 로그아웃하시겠습니까?', 'Chinese': '确定要退出登录吗？'},
    'Cancel': {'Filipino': 'Kanselahin', 'Japanese': 'キャンセル', 'Spanish': 'Cancelar', 'French': 'Annuler', 'Korean': '취소', 'Chinese': '取消'},
    'Save': {'Filipino': 'I-save', 'Japanese': '保存', 'Spanish': 'Guardar', 'French': 'Enregistrer', 'Korean': '저장', 'Chinese': '保存'},
    'Low Stock Items': {'Filipino': 'Mga Produktong Mababa ang Stock', 'Japanese': '在庫少量商品', 'Spanish': 'Artículos con bajo stock', 'French': 'Articles à faible stock', 'Korean': '재고 부족 상품', 'Chinese': '低库存商品'},
    'Products requiring restocking': {'Filipino': 'Mga produktong kailangang i-restock', 'Japanese': '補充が必要な商品', 'Spanish': 'Productos que requieren reabastecimiento', 'French': 'Produits nécessitant un réapprovisionnement', 'Korean': '재입고가 필요한 제품', 'Chinese': '需要补货的产品'},
    'All stock levels are healthy!': {'Filipino': 'Lahat ng stock ay sapat!', 'Japanese': 'すべての在庫は正常です！', 'Spanish': '¡Todos los niveles de stock están bien!', 'French': 'Tous les niveaux de stock sont sains !', 'Korean': '모든 재고 수준이 정상입니다!', 'Chinese': '所有库存水平均正常！'},
    'Product': {'Filipino': 'Produkto', 'Japanese': '商品', 'Spanish': 'Producto', 'French': 'Produit', 'Korean': '제품', 'Chinese': '产品'},
    'Category': {'Filipino': 'Kategorya', 'Japanese': 'カテゴリー', 'Spanish': 'Categoría', 'French': 'Catégorie', 'Korean': '카테고리', 'Chinese': '类别'},
    'Price': {'Filipino': 'Presyo', 'Japanese': '価格', 'Spanish': 'Precio', 'French': 'Prix', 'Korean': '가격', 'Chinese': '价格'},
    'Stock': {'Filipino': 'Stock', 'Japanese': '在庫', 'Spanish': 'Stock', 'French': 'Stock', 'Korean': '재고', 'Chinese': '库存'},
    'Order History': {'Filipino': 'Kasaysayan ng Order', 'Japanese': '注文履歴', 'Spanish': 'Historial de pedidos', 'French': 'Historique des commandes', 'Korean': '주문 내역', 'Chinese': '订单历史'},
    'View and manage all orders': {'Filipino': 'Tingnan at pamahalaan ang lahat ng order', 'Japanese': 'すべての注文を表示・管理', 'Spanish': 'Ver y gestionar todos los pedidos', 'French': 'Voir et gérer toutes les commandes', 'Korean': '모든 주문 보기 및 관리', 'Chinese': '查看和管理所有订单'},
    'Total Revenue': {'Filipino': 'Kabuuang Kita', 'Japanese': '総収益', 'Spanish': 'Ingresos totales', 'French': 'Revenu total', 'Korean': '총 수익', 'Chinese': '总收入'},
    'Total Orders': {'Filipino': 'Kabuuang Order', 'Japanese': '総注文数', 'Spanish': 'Pedidos totales', 'French': 'Total des commandes', 'Korean': '총 주문 수', 'Chinese': '总订单'},
    'Avg Order Value': {'Filipino': 'Avg na Halaga ng Order', 'Japanese': '平均注文金額', 'Spanish': 'Valor promedio del pedido', 'French': 'Valeur moyenne des commandes', 'Korean': '평균 주문 금액', 'Chinese': '平均订单金额'},
    'Search order ID...': {'Filipino': 'Hanapin ang order ID...', 'Japanese': '注文IDを検索...', 'Spanish': 'Buscar ID de pedido...', 'French': 'Rechercher l\'ID de commande...', 'Korean': '주문 ID 검색...', 'Chinese': '搜索订单ID...'},
    'All': {'Filipino': 'Lahat', 'Japanese': 'すべて', 'Spanish': 'Todo', 'French': 'Tout', 'Korean': '전체', 'Chinese': '全部'},
    'Today': {'Filipino': 'Ngayon', 'Japanese': '今日', 'Spanish': 'Hoy', 'French': 'Aujourd\'hui', 'Korean': '오늘', 'Chinese': '今天'},
    'Week': {'Filipino': 'Linggo', 'Japanese': '今週', 'Spanish': 'Semana', 'French': 'Semaine', 'Korean': '이번 주', 'Chinese': '本周'},
    'No orders found': {'Filipino': 'Walang nahanap na order', 'Japanese': '注文が見つかりません', 'Spanish': 'No se encontraron pedidos', 'French': 'Aucune commande trouvée', 'Korean': '주문을 찾을 수 없습니다', 'Chinese': '未找到订单'},
    'Sales Analytics': {'Filipino': 'Pagsusuri ng Benta', 'Japanese': '売上分析', 'Spanish': 'Análisis de ventas', 'French': 'Analyse des ventes', 'Korean': '판매 분석', 'Chinese': '销售分析'},
    'Business intelligence and insights': {'Filipino': 'Business intelligence at mga insight', 'Japanese': 'ビジネスインテリジェンスと洞察', 'Spanish': 'Inteligencia empresarial e información', 'French': 'Intelligence d\'affaires et perspectives', 'Korean': '비즈니스 인텔리전스 및 인사이트', 'Chinese': '商业智能与洞察'},
    'Export': {'Filipino': 'I-export', 'Japanese': 'エクスポート', 'Spanish': 'Exportar', 'French': 'Exporter', 'Korean': '내보내기', 'Chinese': '导出'},
    'Revenue & Orders Trend': {'Filipino': 'Trend ng Kita at Order', 'Japanese': '収益・注文トレンド', 'Spanish': 'Tendencia de ingresos y pedidos', 'French': 'Tendance des revenus et commandes', 'Korean': '수익 및 주문 트렌드', 'Chinese': '收入和订单趋势'},
    'Daily performance': {'Filipino': 'Pang-araw-araw na performance', 'Japanese': '日次パフォーマンス', 'Spanish': 'Rendimiento diario', 'French': 'Performance quotidienne', 'Korean': '일별 성과', 'Chinese': '每日业绩'},
    'Revenue by Category': {'Filipino': 'Kita ayon sa Kategorya', 'Japanese': 'カテゴリ別収益', 'Spanish': 'Ingresos por categoría', 'French': 'Revenus par catégorie', 'Korean': '카테고리별 수익', 'Chinese': '按类别收入'},
    'No data available': {'Filipino': 'Walang available na data', 'Japanese': 'データなし', 'Spanish': 'No hay datos disponibles', 'French': 'Aucune donnée disponible', 'Korean': '데이터 없음', 'Chinese': '暂无数据'},
    'Inventory Report': {'Filipino': 'Ulat ng Imbentaryo', 'Japanese': '在庫レポート', 'Spanish': 'Informe de inventario', 'French': 'Rapport d\'inventaire', 'Korean': '재고 보고서', 'Chinese': '库存报告'},
    'Overview of your inventory status': {'Filipino': 'Pangkalahatang-ideya ng iyong imbentaryo', 'Japanese': '在庫状況の概要', 'Spanish': 'Resumen del estado de tu inventario', 'French': 'Aperçu de votre état des stocks', 'Korean': '재고 현황 개요', 'Chinese': '库存状态概览'},
    'Total Units': {'Filipino': 'Kabuuang Yunit', 'Japanese': '総ユニット', 'Spanish': 'Unidades totales', 'French': 'Unités totales', 'Korean': '총 단위', 'Chinese': '总单位'},
    'Low Stock Items Count': {'Filipino': 'Mga Mababang Stock', 'Japanese': '在庫少量', 'Spanish': 'Artículos con bajo stock', 'French': 'Articles à faible stock', 'Korean': '저재고 상품', 'Chinese': '低库存商품'},
    'Inventory Value': {'Filipino': 'Halaga ng Imbentaryo', 'Japanese': '在庫価値', 'Spanish': 'Valor del inventario', 'French': 'Valeur de l\'inventaire', 'Korean': '재고 가치', 'Chinese': '库存价值'},
    'Product Breakdown': {'Filipino': 'Detalye ng Produkto', 'Japanese': '商品内訳', 'Spanish': 'Desglose de productos', 'French': 'Détail des produits', 'Korean': '제품 세부 내역', 'Chinese': '产品明细'},
    'Value': {'Filipino': 'Halaga', 'Japanese': '価値', 'Spanish': 'Valor', 'French': 'Valeur', 'Korean': '가치', 'Chinese': '价值'},
    'Status': {'Filipino': 'Status', 'Japanese': 'ステータス', 'Spanish': 'Estado', 'French': 'Statut', 'Korean': '상태', 'Chinese': '状态'},
    'Financial Report': {'Filipino': 'Ulat sa Pananalapi', 'Japanese': '財務レポート', 'Spanish': 'Informe financiero', 'French': 'Rapport financier', 'Korean': '재무 보고서', 'Chinese': '财务报告'},
    'Revenue, expenses and profit summary': {'Filipino': 'Buod ng kita, gastos at kita', 'Japanese': '収益・経費・利益のまとめ', 'Spanish': 'Resumen de ingresos, gastos y ganancias', 'French': 'Résumé des revenus, dépenses et bénéfices', 'Korean': '수익, 비용 및 이익 요약', 'Chinese': '收入、支出和利润摘要'},
    'Total Expenses': {'Filipino': 'Kabuuang Gastos', 'Japanese': '総経費', 'Spanish': 'Gastos totales', 'French': 'Dépenses totales', 'Korean': '총 비용', 'Chinese': '总支出'},
    'Net Profit': {'Filipino': 'Net na Kita', 'Japanese': '純利益', 'Spanish': 'Beneficio neto', 'French': 'Bénéfice net', 'Korean': '순이익', 'Chinese': '净利润'},
    'Tax Liability': {'Filipino': 'Pananagutang Buwis', 'Japanese': '税負担', 'Spanish': 'Pasivo fiscal', 'French': 'Passif fiscal', 'Korean': '세금 부채', 'Chinese': '税务负债'},
    'Monthly Summary': {'Filipino': 'Buwanang Buod', 'Japanese': '月次サマリー', 'Spanish': 'Resumen mensual', 'French': 'Résumé mensuel', 'Korean': '월별 요약', 'Chinese': '月度摘要'},
    'Select Country': {'Filipino': 'Pumili ng Bansa', 'Japanese': '国を選択', 'Spanish': 'Seleccionar país', 'French': 'Sélectionner un pays', 'Korean': '국가 선택', 'Chinese': '选择国家'},
    'Select Currency': {'Filipino': 'Pumili ng Pera', 'Japanese': '通貨を選択', 'Spanish': 'Seleccionar moneda', 'French': 'Sélectionner une devise', 'Korean': '통화 선택', 'Chinese': '选择货币'},
    'Select Language': {'Filipino': 'Pumili ng Wika', 'Japanese': '言語を選択', 'Spanish': 'Seleccionar idioma', 'French': 'Sélectionner une langue', 'Korean': '언어 선택', 'Chinese': '选择语言'},
    'Enter store name': {'Filipino': 'Ilagay ang pangalan ng tindahan', 'Japanese': '店舗名を入力', 'Spanish': 'Ingresa el nombre de la tienda', 'French': 'Entrez le nom du magasin', 'Korean': '매장 이름 입력', 'Chinese': '输入店铺名称'},
    'Enter admin name': {'Filipino': 'Ilagay ang pangalan ng admin', 'Japanese': '管理者名を入力', 'Spanish': 'Ingresa el nombre del administrador', 'French': 'Entrez le nom de l\'administrateur', 'Korean': '관리자 이름 입력', 'Chinese': '输入管理员名称'},
    'Enter units (e.g. 20)': {'Filipino': 'Ilagay ang mga yunit (hal. 20)', 'Japanese': '単位を入力（例：20）', 'Spanish': 'Ingresa las unidades (ej. 20)', 'French': 'Entrez les unités (ex. 20)', 'Korean': '단위 입력 (예: 20)', 'Chinese': '输入单位（例：20）'},
    'units': {'Filipino': 'yunit', 'Japanese': '個', 'Spanish': 'unidades', 'French': 'unités', 'Korean': '단위', 'Chinese': '单位'},
    'Administrator': {'Filipino': 'Administrador', 'Japanese': '管理者', 'Spanish': 'Administrador', 'French': 'Administrateur', 'Korean': '관리자', 'Chinese': '管理员'},
  };

  String tr(String key) {
    if (language == 'English') return key;
    return _strings[key]?[language] ?? key;
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────
DateTime? _parseDate(dynamic dateVal) {
  if (dateVal == null) return null;
  if (dateVal is Timestamp) return dateVal.toDate();
  if (dateVal is int) return DateTime.fromMillisecondsSinceEpoch(dateVal);
  if (dateVal is String) {
    final tryInt = int.tryParse(dateVal);
    if (tryInt != null && tryInt > 10000000000) return DateTime.fromMillisecondsSinceEpoch(tryInt);
    return DateTime.tryParse(dateVal);
  }
  return null;
}

// ─── Low Stock Screen ──────────────────────────────────────────────────────────
class LowStockScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const LowStockScreen({super.key, required this.appState, required this.onStateChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final headerMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final l = AppLocalizations(appState.language);

    final lowStock = appState.lowStockProducts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Low Stock Items'), overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.tr('Products requiring restocking'), overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textMuted, fontSize: 13)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;
          return Container(
            decoration: BoxDecoration(
              color: bgCard, borderRadius: BorderRadius.circular(14),
              border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: lowStock.isEmpty
                ? Padding(padding: const EdgeInsets.all(40),
                  child: Center(child: Column(children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF22C88A), size: 52),
                    const SizedBox(height: 12),
                    Text(l.tr('All stock levels are healthy!'), textAlign: TextAlign.center, style: TextStyle(color: textPrimary, fontSize: 15)),
                  ])))
                : Column(children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      child: Row(children: [
                        Expanded(flex: isNarrow ? 5 : 4,
                          child: Text(l.tr('Product'), overflow: TextOverflow.ellipsis, style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        if (!isNarrow) Expanded(flex: 2,
                          child: Text(l.tr('Category'), overflow: TextOverflow.ellipsis, style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 2,
                          child: Text(l.tr('Price'), overflow: TextOverflow.ellipsis, style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                        Expanded(flex: 2,
                          child: Text(l.tr('Stock'), overflow: TextOverflow.ellipsis, style: TextStyle(color: headerMuted, fontWeight: FontWeight.w600, fontSize: 12))),
                      ]),
                    ),
                    Divider(color: divider, height: 1),
                    ...lowStock.map((p) => Column(children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            child: Row(children: [
                              Expanded(flex: isNarrow ? 5 : 4,
                                child: Row(children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(7),
                                    child: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 40, height: 40, color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                                        child: Icon(Icons.image, color: isDark ? Colors.white38 : Colors.black26, size: 18)))),
                                  const SizedBox(width: 10),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(p.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
                                    Text('ID: ${p.id}', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textMuted, fontSize: 11)),
                                  ])),
                                ]),
                              ),
                              if (!isNarrow) Expanded(flex: 2, child: Text(p.category, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textMuted, fontSize: 13))),
                              Expanded(flex: 2, child: Text('${appState.currencySymbol}${p.price.toStringAsFixed(2)}', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textPrimary, fontSize: 13))),
                              Expanded(flex: 2, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF5C518).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                                  child: Text('${p.stock} units', style: const TextStyle(color: Color(0xFFF5C518), fontWeight: FontWeight.w600, fontSize: 12))))),
                            ]),
                          ),
                          Divider(color: divider, height: 1),
                        ])),
                  ]),
          );
        }),
      ]),
    );
  }
}

// ─── Order History ─────────────────────────────────────────────────────────────
class OrderHistoryScreen extends StatefulWidget {
  final AppState? appState;
  const OrderHistoryScreen({super.key, this.appState});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filterKey = 'All'; 
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final l = AppLocalizations(widget.appState?.language ?? 'English');
    final sym = widget.appState?.currencySymbol ?? '₱';

    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: currentUser?.email) 
          .snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.hasError) print("🔥 Firebase Orders Error: ${snapshot.error}");
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB)));

        List<Map<String, dynamic>> allOrders = [];
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = data['order_id'] ?? data['_id'] ?? doc.id;
            allOrders.add(data);
          }
        }

        var filtered = allOrders.where((o) {
          final id = o['id'].toString().toLowerCase();
          return id.contains(_searchQuery.toLowerCase());
        }).toList();

        if (_filterKey != 'All') {
          filtered = filtered.where((o) {
            final status = (o['status'] ?? '').toString().toLowerCase();
            final type = (o['type'] ?? o['orderType'] ?? o['order_type'] ?? '').toString().toLowerCase();
            final target = _filterKey.toLowerCase();
            
            if (target == 'completed') return status == 'completed';
            if (target == 'cancelled') return status == 'cancelled' || status == 'canceled';
            if (target == 'refund') return status == 'refund' || status == 'refunded';
            if (target == 'dine in') return type == 'dine in' || type == 'dine_in';
            if (target == 'take out') return type == 'take out' || type == 'take_out';
            
            return true; 
          }).toList();
        }

        filtered.sort((a, b) {
          final dateA = _parseDate(a['createdAt'] ?? a['created_at'] ?? a['date']) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = _parseDate(b['createdAt'] ?? b['created_at'] ?? b['date']) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA); 
        });

        double totalRev = 0.0;
        for (var o in filtered) {
          final status = (o['status'] ?? '').toString().toLowerCase();
          if (status != 'cancelled' && status != 'refund') {
             totalRev += double.tryParse(o['totalAmount']?.toString() ?? o['total_amount']?.toString() ?? '0') ?? 0.0;
          }
        }
        final double avgVal = filtered.isEmpty ? 0 : totalRev / filtered.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.tr('Order History'), style: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(l.tr('View and manage all transactions'), style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 28),

            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 500 ? 1 : 3;
              return GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.8,
                children: [
                  _metricCard(Icons.account_balance_wallet, const Color(0xFF4B6BFB), l.tr('Total Revenue'), '$sym${totalRev.toStringAsFixed(2)}', isDark),
                  _metricCard(Icons.shopping_bag_outlined, const Color(0xFF22C88A), l.tr('Total Orders'), '${filtered.length}', isDark),
                  _metricCard(Icons.insights, const Color(0xFF9B59B6), l.tr('Avg Order Value'), '$sym${avgVal.toStringAsFixed(2)}', isDark),
                ],
              );
            }),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: bgCard, 
                borderRadius: BorderRadius.circular(16), 
                border: isDark ? Border.all(color: Colors.white12) : null,
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l.tr('Search order ID...'),
                    hintStyle: TextStyle(color: textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                    filled: true, fillColor: bgInput,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Completed', 'Cancelled', 'Refund', 'Dine In', 'Take Out'].map((f) {
                      final sel = _filterKey == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filterKey = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10), 
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF4B6BFB) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.03)), 
                            borderRadius: BorderRadius.circular(10), 
                            border: sel ? null : Border.all(color: isDark ? Colors.transparent : Colors.black12)
                          ),
                          child: Text(l.tr(f), style: TextStyle(color: sel ? Colors.white : textPrimary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            if (filtered.isEmpty)
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: Colors.white12) : Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(children: [
                  Icon(Icons.receipt_long_outlined, color: isDark ? Colors.white24 : Colors.black12, size: 64),
                  const SizedBox(height: 16),
                  Text(l.tr('No orders found'), style: TextStyle(color: textMuted, fontSize: 16, fontWeight: FontWeight.w500)),
                ]),
              )
            else
              LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, 
                    crossAxisSpacing: 20, 
                    mainAxisSpacing: 20, 
                    mainAxisExtent: 220 
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final o = filtered[index];
                    final orderId = o['id'].toString();
                    final status = (o['status'] ?? 'Completed').toString().toUpperCase();
                    final type = (o['order_type'] ?? o['orderType'] ?? o['type'] ?? '').toString().toUpperCase();
                    final totalAmount = double.tryParse(o['total_amount']?.toString() ?? o['totalAmount']?.toString() ?? '0') ?? 0.0;
                    
                    Color statusColor = const Color(0xFF22C88A); 
                    if (status.contains('CANCEL')) statusColor = Colors.redAccent;
                    if (status.contains('REFUND')) statusColor = Colors.orange;

                    String dateStr = 'Unknown Date';
                    final dateObj = _parseDate(o['created_at'] ?? o['createdAt'] ?? o['date']);
                    if (dateObj != null) dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(dateObj);

                    List<dynamic> itemsList = [];
                    final cartItemsRaw = o['cart_items'] ?? o['items'] ?? o['cartItems'];
                    
                    if (cartItemsRaw != null) {
                      if (cartItemsRaw is String) {
                        try {
                          itemsList = jsonDecode(cartItemsRaw);
                        } catch (e) {
                          print('Error decoding items: $e');
                        }
                      } else if (cartItemsRaw is List) {
                        itemsList = cartItemsRaw;
                      }
                    }

                    String itemsDetails = 'No items listed';
                    if (itemsList.isNotEmpty) {
                      List<String> itemStrings = [];
                      for (var item in itemsList) {
                        if (item is Map) {
                          final qty = item['quantity'] ?? item['qty'] ?? 1;
                          final name = item['product_name'] ?? item['name'] ?? 'Unknown Item';
                          itemStrings.add('${qty}x $name');
                        }
                      }
                      if (itemStrings.isNotEmpty) {
                        itemsDetails = itemStrings.join('\n'); 
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: bgCard, 
                        borderRadius: BorderRadius.circular(14), 
                        border: isDark ? Border.all(color: Colors.white12) : null,
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: statusColor, width: 4))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            
                            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Icon(Icons.receipt_long, size: 14, color: textMuted), 
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Order #${orderId.length > 15 ? '${orderId.substring(0, 15)}...' : orderId}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.3), overflow: TextOverflow.ellipsis)),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Text(dateStr, style: TextStyle(color: textMuted, fontSize: 11)),
                                  if (type.isNotEmpty) ...[
                                    Text(' • ', style: TextStyle(color: textMuted, fontSize: 11)),
                                    Text(type, style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 10, fontWeight: FontWeight.w700)),
                                  ]
                                ]),
                              ])),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.2))),
                                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                            ])),
                            
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: divider)),
                            
                            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Icon(Icons.shopping_bag_outlined, size: 14, color: textMuted), 
                                const SizedBox(width: 6), 
                                Text(itemsList.isEmpty ? 'POS Order' : '${itemsList.length} items', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600))
                              ]),
                              const SizedBox(height: 6),
                              Expanded(child: Text(itemsDetails, style: TextStyle(color: textMuted, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            ]))),

                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: divider)),
                            
                            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Total Amount', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                              Text('$sym${totalAmount.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                            ])),

                          ]),
                        ),
                      ),
                    );
                  },
                );
              }),
          ]),
        );
      }
    );
  }

  Widget _metricCard(IconData icon, Color color, String label, String value, bool isDark) {
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: Colors.white12) : null, boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ])),
      ]),
    );
  }
}

// ─── Sales Report ──────────────────────────────────────────────────────────────
class SalesReportScreen extends StatefulWidget {
  final AppState? appState;
  const SalesReportScreen({super.key, this.appState});
  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String _timeRange = 'All day';
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);

  static const _appBlue = Color(0xFF4B6BFB);

  String get _selectedDateLabel {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  bool _isOrderInTimeRange(DateTime orderDate) {
    if (_timeRange == 'All day') return true;
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins   = _endTime.hour   * 60 + _endTime.minute;
    final oMins     = orderDate.hour   * 60 + orderDate.minute;
    return oMins >= startMins && oMins <= endMins;
  }

  Future<void> _showCalendarDialog(BuildContext context, bool isDark) async {
    final bgCard      = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted   = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFE5E7EB);

    DateTime tempDate  = _selectedDate;
    DateTime viewMonth = DateTime(_selectedDate.year, _selectedDate.month);

    const presets = ['Today', 'Yesterday', 'Last week', 'Last month', 'Last quarter'];

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final daysInMonth = DateUtils.getDaysInMonth(viewMonth.year, viewMonth.month);
          final firstWeekday = DateTime(viewMonth.year, viewMonth.month, 1).weekday;
          final totalCells   = firstWeekday - 1 + daysInMonth;
          final rows         = (totalCells / 7).ceil();
          const months = ['January','February','March','April','May','June',
                          'July','August','September','October','November','December'];
          const days   = ['Mo','Tu','We','Th','Fr','Sa','Su'];

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 560,
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0,8))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: borderColor)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...presets.map((p) {
                          return InkWell(
                            onTap: () {
                              final now = DateTime.now();
                              DateTime d;
                              switch (p) {
                                case 'Today':      d = now; break;
                                case 'Yesterday':  d = now.subtract(const Duration(days: 1)); break;
                                case 'Last week':  d = now.subtract(const Duration(days: 7)); break;
                                case 'Last month': d = DateTime(now.year, now.month - 1, now.day); break;
                                default:           d = DateTime(now.year, now.month - 3, now.day); break;
                              }
                              setDlg(() { tempDate = d; viewMonth = DateTime(d.year, d.month); });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              child: Text(p, style: TextStyle(color: textPrimary, fontSize: 14)),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            final now = DateTime.now();
                            setDlg(() { tempDate = now; viewMonth = DateTime(now.year, now.month); });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                            child: const Text('Reset', style: TextStyle(color: _appBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${months[viewMonth.month - 1]} ${viewMonth.year}',
                                  style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              Row(children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left, color: textPrimary, size: 20),
                                  onPressed: () => setDlg(() => viewMonth = DateTime(viewMonth.year, viewMonth.month - 1)),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 14),
                                IconButton(
                                  icon: Icon(Icons.chevron_right, color: textPrimary, size: 20),
                                  onPressed: () => setDlg(() => viewMonth = DateTime(viewMonth.year, viewMonth.month + 1)),
                                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                ),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: days.map((d) => Expanded(
                              child: Center(child: Text(d,
                                  style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500))),
                            )).toList(),
                          ),
                          const SizedBox(height: 6),
                          ...List.generate(rows, (r) => Row(
                            children: List.generate(7, (c) {
                              final cellIndex = r * 7 + c;
                              final dayNum    = cellIndex - (firstWeekday - 1) + 1;
                              if (dayNum < 1 || dayNum > daysInMonth) {
                                return const Expanded(child: SizedBox(height: 36));
                              }
                              final cellDate  = DateTime(viewMonth.year, viewMonth.month, dayNum);
                              final isSelected = DateUtils.isSameDay(tempDate, cellDate);
                              final isToday    = DateUtils.isSameDay(DateTime.now(), cellDate);
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setDlg(() => tempDate = cellDate),
                                  child: Container(
                                    height: 36, margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? _appBlue : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: isToday && !isSelected ? Border.all(color: _appBlue, width: 1.5) : null,
                                    ),
                                    child: Center(
                                      child: Text('$dayNum',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : isToday ? _appBlue : textPrimary,
                                          fontSize: 13,
                                          fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          )),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('CANCEL', style: TextStyle(color: textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, tempDate),
                                child: const Text('DONE', style: TextStyle(color: _appBlue, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
          );
        },
      ),
    );

    if (result != null && mounted) setState(() => _selectedDate = result);
  }

  Future<TimeOfDay?> _showTimeDialog(BuildContext context, TimeOfDay initial, bool isDark) async {
    final bgCard      = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted   = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final inputBg     = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);

    int  hour   = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    int  minute = initial.minute;
    bool isAm   = initial.period == DayPeriod.am;

    final hourCtrl   = TextEditingController(text: hour.toString().padLeft(2, '0'));
    final minuteCtrl = TextEditingController(text: minute.toString().padLeft(2, '0'));

    return showDialog<TimeOfDay>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0,8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ENTER TIME',
                    style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(children: [
                        Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _appBlue, width: 2),
                          ),
                          child: Center(
                            child: TextField(
                              controller: hourCtrl,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w300),
                              decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                              maxLength: 2,
                              onChanged: (v) {
                                final n = int.tryParse(v) ?? 1;
                                setDlg(() => hour = n.clamp(1, 12));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Hour', style: TextStyle(color: textMuted, fontSize: 12)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28, left: 6, right: 6),
                      child: Text(':', style: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Column(children: [
                        Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: TextField(
                              controller: minuteCtrl,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w300),
                              decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                              maxLength: 2,
                              onChanged: (v) {
                                final n = int.tryParse(v) ?? 0;
                                setDlg(() => minute = n.clamp(0, 59));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Minute', style: TextStyle(color: textMuted, fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: ['AM', 'PM'].map((p) {
                        final sel = (p == 'AM') == isAm;
                        return GestureDetector(
                          onTap: () => setDlg(() => isAm = p == 'AM'),
                          child: Container(
                            width: 52, height: 36,
                            decoration: BoxDecoration(
                              color: sel ? _appBlue.withOpacity(0.13) : inputBg,
                              borderRadius: p == 'AM'
                                  ? const BorderRadius.vertical(top: Radius.circular(8))
                                  : const BorderRadius.vertical(bottom: Radius.circular(8)),
                              border: Border.all(color: sel ? _appBlue : (isDark ? Colors.white12 : const Color(0xFFE5E7EB))),
                            ),
                            child: Center(
                              child: Text(p,
                                style: TextStyle(
                                  color: sel ? _appBlue : textMuted,
                                  fontWeight: FontWeight.w700, fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, color: textMuted, size: 22),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('CANCEL', style: TextStyle(color: textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        final h24 = isAm ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12);
                        Navigator.pop(ctx, TimeOfDay(hour: h24, minute: minute));
                      },
                      child: const Text('OK', style: TextStyle(color: _appBlue, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD1D5DB);
    final l = AppLocalizations(widget.appState?.language ?? 'English');
    final sym = widget.appState?.currencySymbol ?? '₱';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.email).snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB)));
        }

        double totalRev = 0.0;
        int totalOrdersCount = 0;
        Map<String, double> categoryRevenue = {};
        Map<String, int> productSalesCount = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final o = doc.data() as Map<String, dynamic>;
            final status = (o['status'] ?? '').toString().toLowerCase();
            
            if (status == 'cancelled' || status == 'refund' || status == 'refunded') continue;

            final orderDate = _parseDate(o['createdAt'] ?? o['created_at'] ?? o['timestamp'] ?? o['date']);
            if (orderDate != null) {
              final sameDay = orderDate.year == _selectedDate.year &&
                  orderDate.month == _selectedDate.month &&
                  orderDate.day == _selectedDate.day;
              if (!sameDay || !_isOrderInTimeRange(orderDate)) continue;
            } else {
              continue;
            }

            totalOrdersCount++;
            final orderTotal = double.tryParse(o['totalAmount']?.toString() ?? o['total_amount']?.toString() ?? '0') ?? 0.0;
            totalRev += orderTotal;

            List<dynamic> itemsList = [];
            final cartItemsRaw = o['cart_items'] ?? o['items'] ?? o['cartItems'];
            if (cartItemsRaw != null) {
              if (cartItemsRaw is String) {
                try { itemsList = jsonDecode(cartItemsRaw); } catch (e) {}
              } else if (cartItemsRaw is List) {
                itemsList = cartItemsRaw;
              }
            }

            for (var item in itemsList) {
              if (item is Map) {
                final qty = (item['quantity'] ?? item['qty'] ?? 1) as int;
                final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                final category = (item['category'] ?? 'Uncategorized').toString();
                final name = (item['product_name'] ?? item['name'] ?? 'Unknown Item').toString();

                categoryRevenue[category] = (categoryRevenue[category] ?? 0.0) + (qty * price);
                productSalesCount[name] = (productSalesCount[name] ?? 0) + qty;
              }
            }
          }
        }

        double avgVal = totalOrdersCount > 0 ? totalRev / totalOrdersCount : 0.0;

        String bestProduct = "No Sales Yet";
        int bestProductQty = 0;
        productSalesCount.forEach((name, qty) {
          if (qty > bestProductQty) {
            bestProductQty = qty;
            bestProduct = name;
          }
        });

        double totalPieRev = categoryRevenue.values.fold(0.0, (a, b) => a + b);
        List<_PieCategorySegment> pieSegments = [];
        List<Color> chartColors = [
          const Color(0xFF4B6BFB), const Color(0xFF22C88A), const Color(0xFFF59E0B), 
          const Color(0xFFEC4899), const Color(0xFF9B59B6), const Color(0xFF1ABC9C)
        ];
        
        int colorIdx = 0;
        categoryRevenue.forEach((cat, rev) {
           if (rev > 0 && totalPieRev > 0) {
             pieSegments.add(_PieCategorySegment(cat, rev / totalPieRev, chartColors[colorIdx % chartColors.length]));
             colorIdx++;
           }
        });
        
        if (pieSegments.isEmpty) {
           pieSegments.add(const _PieCategorySegment('No Data', 1.0, Colors.grey));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.tr('Sales Analytics'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l.tr('Business intelligence and insights'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: textMuted, fontSize: 13)),
                      ]),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            onTap: () => setState(() =>
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.chevron_left, size: 20, color: textMuted),
                            ),
                          ),
                          Container(width: 1, height: 24, color: borderColor),
                          InkWell(
                            onTap: () => _showCalendarDialog(context, isDark),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                _selectedDateLabel,
                                style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            onTap: () => _showCalendarDialog(context, isDark),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.calendar_month, size: 18, color: textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timeRange,
                          dropdownColor: bgCard,
                          style: TextStyle(color: textPrimary, fontSize: 13),
                          icon: const SizedBox.shrink(),
                          items: ['All day', 'Custom period']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (v) { if (v != null) setState(() => _timeRange = v); },
                        ),
                      ),
                    ),
                    if (_timeRange == 'Custom period') ...[
                      _timePickerButton(
                        label: 'Start',
                        time: _startTime,
                        isDark: isDark,
                        bgCard: bgCard,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () async {
                          final t = await _showTimeDialog(context, _startTime, isDark);
                          if (t != null) setState(() => _startTime = t);
                        },
                      ),
                      _timePickerButton(
                        label: 'End',
                        time: _endTime,
                        isDark: isDark,
                        bgCard: bgCard,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () async {
                          final t = await _showTimeDialog(context, _endTime, isDark);
                          if (t != null) setState(() => _endTime = t);
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            LayoutBuilder(builder: (context, c) {
              final isMobile = c.maxWidth < 500;
              final cols = isMobile ? 2 : 4;
              return GridView.custom(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: isMobile ? 130 : (c.maxWidth / 4 / 1.4),
                ),
                childrenDelegate: SliverChildListDelegate([
                  _anaCard(
                      Icons.attach_money, const Color(0xFF2A4A8A), l.tr('Total Revenue'),
                      '$sym${totalRev.toStringAsFixed(2)}', 'Gross sales', 'Live Data', true, isDark),
                  _anaCard(
                      Icons.shopping_cart_outlined, const Color(0xFF1A5A3A), l.tr('Total Orders'),
                      '$totalOrdersCount', 'Completed', 'Live Data', true, isDark),
                  _anaCard(
                      Icons.trending_up, const Color(0xFF5A3A1A), l.tr('Avg Order Value'),
                      '$sym${avgVal.toStringAsFixed(2)}', 'Per transaction', 'Live Data', true, isDark),
                  _anaCard(
                      Icons.star_outline, const Color(0xFF3A1A5A), 'Top Selling Item',
                      bestProduct, '$bestProductQty units sold', 'Most Popular', true, isDark),
                ]),
              );
            }),
            const SizedBox(height: 20),

            LayoutBuilder(builder: (ctx, c) {
              final isNarrow = c.maxWidth < 600;

              final Map<String, double> dailyRevenue = {};
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final o = doc.data() as Map<String, dynamic>;
                  final status = (o['status'] ?? '').toString().toLowerCase();
                  if (status == 'cancelled' || status == 'refund' || status == 'refunded') continue;
                  final ts = o['timestamp'] ?? o['createdAt'] ?? o['date'];
                  String dayKey;
                  if (ts is Timestamp) {
                    dayKey = DateFormat('MM/dd').format(ts.toDate());
                  } else {
                    dayKey = DateFormat('MM/dd').format(DateTime.now());
                  }
                  final amt = double.tryParse(o['totalAmount']?.toString() ?? o['total_amount']?.toString() ?? '0') ?? 0.0;
                  dailyRevenue[dayKey] = (dailyRevenue[dayKey] ?? 0.0) + amt;
                }
              }

              final chart = SizedBox(
                height: isNarrow ? 240 : 300,
                child: _DynamicRevenueChart(
                  dailyRevenue: dailyRevenue,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  bgCard: bgCard,
                  isNarrow: isNarrow,
                  sym: sym,
                ),
              );
              final pie = Container(
                height: isNarrow ? 300 : 260,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.tr('Revenue by Category'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _RevenueByCategoryChart(
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      segments: pieSegments,
                    ),
                  ),
                ]),
              );
              return isNarrow
                  ? Column(children: [chart, const SizedBox(height: 14), pie])
                  : Row(children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: pie),
                    ]);
            }),
          ]),
        );
      }
    );
  }

  Widget _anaCard(IconData icon, Color bg, String label, String value,
      String sub, String trend, bool pos, bool isDark) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(sub,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(pos ? Icons.trending_up : Icons.trending_down,
                  color: pos ? const Color(0xFF22C88A) : Colors.redAccent,
                  size: 13),
              const SizedBox(width: 3),
              Flexible(
                child: Text(trend,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: pos ? const Color(0xFF22C88A) : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
    );
  }

  Widget _timePickerButton({
    required String label,
    required TimeOfDay time,
    required bool isDark,
    required Color bgCard,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
            Text('$h:$m $period', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DynamicRevenueChart extends StatefulWidget {
  final Map<String, double> dailyRevenue;
  final bool isDark, isNarrow;
  final Color textPrimary, textMuted, bgCard;
  final String sym;

  const _DynamicRevenueChart({
    required this.dailyRevenue,
    required this.isDark,
    required this.isNarrow,
    required this.textPrimary,
    required this.textMuted,
    required this.bgCard,
    required this.sym,
  });

  @override
  State<_DynamicRevenueChart> createState() => _DynamicRevenueChartState();
}

class _DynamicRevenueChartState extends State<_DynamicRevenueChart> {
  bool _isBarChart = true;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final entries = widget.dailyRevenue.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final List<String> labels;
    final List<double> values;
    if (entries.isEmpty) {
      final now = DateTime.now();
      labels = List.generate(7, (i) =>
          DateFormat('MM/dd').format(now.subtract(Duration(days: 6 - i))));
      values = [0, 0, 0, 0, 0, 0, 0];
    } else {
      labels = entries.map((e) => e.key).toList();
      values = entries.map((e) => e.value).toList();
    }

    final maxVal = values.isEmpty ? 1.0 : (values.reduce(math.max) == 0 ? 1.0 : values.reduce(math.max));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: widget.isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Revenue & Orders Trend',
                  style: TextStyle(color: widget.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('Daily performance',
                  style: TextStyle(color: widget.textMuted, fontSize: 11)),
            ]),
            Container(
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _ChartToggleBtn(
                  label: 'Bar',
                  icon: Icons.bar_chart_rounded,
                  active: _isBarChart,
                  isDark: widget.isDark,
                  onTap: () => setState(() => _isBarChart = true),
                ),
                _ChartToggleBtn(
                  label: 'Line',
                  icon: Icons.show_chart_rounded,
                  active: !_isBarChart,
                  isDark: widget.isDark,
                  onTap: () => setState(() => _isBarChart = false),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),

          Expanded(
            child: values.every((v) => v == 0)
              ? Center(child: Text('No sales data yet', style: TextStyle(color: widget.textMuted, fontSize: 13)))
              : LayoutBuilder(builder: (ctx, constraints) {
                  final chartW = constraints.maxWidth;
                  final chartH = constraints.maxHeight - 24; 
                  final count = labels.length;
                  final spacing = chartW / count;
                  final barW = (spacing * 0.55).clamp(6.0, 32.0);

                  return MouseRegion(
                    onHover: (event) {
                      int? hoveredIdx;
                      
                      if (_isBarChart) {
                        for (int i = 0; i < values.length; i++) {
                          final barH = (values[i] / maxVal) * chartH * 0.88;
                          final x = i * spacing + (spacing - barW) / 2;
                          final barY = chartH - barH;
                          
                          if (event.localPosition.dx >= x &&
                              event.localPosition.dx <= x + barW &&
                              event.localPosition.dy >= barY &&
                              event.localPosition.dy <= chartH) {
                            hoveredIdx = i;
                            break;
                          }
                        }
                      } else {
                        final pts = <Offset>[];
                        for (int i = 0; i < values.length; i++) {
                          pts.add(Offset(i * spacing + spacing / 2, chartH - (values[i] / maxVal) * chartH * 0.88));
                        }
                        
                        for (int i = 0; i < pts.length; i++) {
                          final point = pts[i];
                          final dx = event.localPosition.dx - point.dx;
                          final dy = event.localPosition.dy - point.dy;
                          final distance = math.sqrt(dx * dx + dy * dy);
                          
                          if (distance <= 4.0) {
                            hoveredIdx = i;
                            break;
                          }
                        }
                      }
                      
                      setState(() => _hoveredIndex = hoveredIdx);
                    },
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: Size(chartW, chartH),
                          painter: _GridPainter(isDark: widget.isDark),
                        ),
                        if (_isBarChart)
                          CustomPaint(
                            size: Size(chartW, chartH),
                            painter: _BarChartPainter(
                              values: values,
                              maxVal: maxVal,
                              spacing: spacing,
                              barW: barW,
                              hoveredIndex: _hoveredIndex,
                            ),
                          )
                        else
                          CustomPaint(
                            size: Size(chartW, chartH),
                            painter: _LineChartPainter(
                              values: values,
                              maxVal: maxVal,
                              spacing: spacing,
                              hoveredIndex: _hoveredIndex,
                              isDark: widget.isDark,
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: 20,
                            child: Row(
                              children: List.generate(count, (i) {
                                final step = count <= 7 ? 1 : (count / 7).ceil();
                                final show = i % step == 0;
                                return SizedBox(
                                  width: spacing,
                                  child: show
                                    ? Text(labels[i],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: widget.textMuted,
                                            fontSize: 9.5))
                                    : const SizedBox(),
                                );
                              }),
                            ),
                          ),
                        ),
                        if (_hoveredIndex != null && _hoveredIndex! < count) ...[
                          Positioned(
                            left: (_hoveredIndex! * spacing + spacing / 2 - 70).clamp(0, chartW - 140),
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: widget.isDark ? const Color(0xFF2A2D3E) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4))],
                                border: Border.all(color: widget.isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(labels[_hoveredIndex!],
                                      style: TextStyle(color: widget.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('revenue : ${widget.sym}${values[_hoveredIndex!].toStringAsFixed(2)}',
                                      style: const TextStyle(color: Color(0xFF4B6BFB), fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _ChartToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active, isDark;
  final VoidCallback onTap;

  const _ChartToggleBtn({required this.label, required this.icon, required this.active, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4B6BFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF6B7280))),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF6B7280)))),
        ]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final double maxVal, spacing, barW;
  final int? hoveredIndex;

  const _BarChartPainter({required this.values, required this.maxVal, required this.spacing, required this.barW, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 24; 
    for (int i = 0; i < values.length; i++) {
      final barH = (values[i] / maxVal) * h * 0.88;
      final x = i * spacing + (spacing - barW) / 2;
      final isHovered = hoveredIndex == i;
      final color = isHovered ? const Color(0xFF22C88A).withOpacity(0.5) : const Color(0xFF22C88A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, h - barH, barW, barH), const Radius.circular(4)),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.hoveredIndex != hoveredIndex || old.values != values;
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxVal, spacing;
  final int? hoveredIndex;
  final bool isDark;

  const _LineChartPainter({required this.values, required this.maxVal, required this.spacing, this.hoveredIndex, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 24;
    if (values.isEmpty) return;

    final pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      pts.add(Offset(i * spacing + spacing / 2, h - (values[i] / maxVal) * h * 0.88));
    }

    final fp = Path()..moveTo(pts.first.dx, h);
    for (final p in pts) {
      fp.lineTo(p.dx, p.dy);
    }
    fp.lineTo(pts.last.dx, h);
    fp.close();
    canvas.drawPath(fp, Paint()..color = const Color(0xFF4B6BFB).withOpacity(0.12));

    final lp = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      lp.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(lp, Paint()..color = const Color(0xFF4B6BFB)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    for (int i = 0; i < pts.length; i++) {
      final isHovered = hoveredIndex == i;
      canvas.drawCircle(pts[i], isHovered ? 5 : 3, Paint()..color = const Color(0xFF4B6BFB));
      if (isHovered) {
        canvas.drawCircle(pts[i], 7, Paint()..color = const Color(0xFF4B6BFB).withOpacity(0.2));
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.hoveredIndex != hoveredIndex || old.values != values;
}

class _RevenueByCategoryChart extends StatelessWidget {
  final Color textPrimary;
  final Color textMuted;
  final List<_PieCategorySegment> segments;

  const _RevenueByCategoryChart({
      required this.textPrimary, 
      required this.textMuted,
      required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 5,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _PieCategoryPainter(segments: segments),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        flex: 5,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: segments.map((segment) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(segment.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textPrimary, fontSize: 12)),
                  ),
                  Text('${(segment.value * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList(),
          ),
        ),
      ),
    ]);
  }
}

class _PieCategorySegment {
  final String label;
  final double value;
  final Color color;
  const _PieCategorySegment(this.label, this.value, this.color);
}

class _PieCategoryPainter extends CustomPainter {
  final List<_PieCategorySegment> segments;
  const _PieCategoryPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = segment.value * 2 * math.pi;
      final paint = Paint()..color = segment.color;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.56, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Inventory Report ──────────────────────────────────────────────────────────
class InventoryReportScreen extends StatelessWidget {
  final AppState appState;
  const InventoryReportScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final l = AppLocalizations(appState.language);

    return StreamBuilder<QuerySnapshot>(
      // 🌟 THE FIX: Filtered by the current logged-in user!
      stream: FirebaseFirestore.instance.collection('products').where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int total = 0;
        int lowCount = 0;
        double value = 0.0;
        List<QueryDocumentSnapshot> products = [];

        if (snapshot.hasData) {
          products = snapshot.data!.docs;
          for (var doc in products) {
            final data = doc.data() as Map<String, dynamic>;
            final stock = data['stock'] as int? ?? 0;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            
            total += stock;
            value += (stock * price);
            if (stock <= appState.lowStockThresholdSetting) {
              lowCount++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.tr('Inventory Report'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l.tr('Overview of your inventory status'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 500 ? 1 : 3;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.5,
                children: [
                  _card(l.tr('Total Units'), '$total', Icons.inventory_outlined,
                      const Color(0xFF4B6BFB), isDark),
                  _card(
                      l.tr('Low Stock Items Count'),
                      '$lowCount',
                      Icons.warning_amber_outlined,
                      const Color(0xFFE53935),
                      isDark),
                  _card(
                      l.tr('Inventory Value'),
                      '${_currencySymbol(appState.currency)}${value.toStringAsFixed(2)}',
                      Icons.attach_money,
                      const Color(0xFF22C88A),
                      isDark),
                ],
              );
            }),
            const SizedBox(height: 20),
            Text(l.tr('Product Breakdown'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              return Container(
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? null : Border.all(color: divider),
                ),
                child: Column(children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(children: [
                      Expanded(
                          flex: isNarrow ? 4 : 3,
                          child: Text(l.tr('Product'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12))),
                      if (!isNarrow)
                        Expanded(
                            flex: 2,
                            child: Text(l.tr('Category'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12))),
                      Expanded(
                          flex: 1,
                          child: Text(l.tr('Stock'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text(l.tr('Value'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text(l.tr('Status'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12))),
                    ]),
                  ),
                  Divider(color: divider, height: 1),
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No products found in database.'),
                    ),
                  ...products.map((doc) {
                    final p = doc.data() as Map<String, dynamic>;
                    final name = p['name'] ?? 'Unknown';
                    final category = p['category'] ?? 'Uncategorized';
                    final stock = p['stock'] as int? ?? 0;
                    final price = (p['price'] as num?)?.toDouble() ?? 0.0;
                    final isLow = stock <= appState.lowStockThresholdSetting;

                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        child: Row(children: [
                          Expanded(
                              flex: isNarrow ? 4 : 3,
                              child: Text(name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: textPrimary, fontSize: 13))),
                          if (!isNarrow)
                            Expanded(
                                flex: 2,
                                child: Text(category,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        TextStyle(color: textMuted, fontSize: 12))),
                          Expanded(
                              flex: 1,
                              child: Text('$stock',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: textPrimary, fontSize: 13))),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  '${_currencySymbol(appState.currency)}${(price * stock).toStringAsFixed(2)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: textPrimary, fontSize: 13))),
                          Expanded(
                              flex: 2,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: (isLow
                                              ? const Color(0xFFF5C518)
                                              : const Color(0xFF22C88A))
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(isLow ? 'Low' : 'OK',
                                      style: TextStyle(
                                          color: isLow
                                              ? const Color(0xFFF5C518)
                                              : const Color(0xFF22C88A),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              )),
                        ]),
                      ),
                      Divider(color: divider, height: 1),
                    ]);
                  }),
                ]),
              );
            }),
          ]),
        );
      }
    );
  }

  Widget _card(
      String label, String value, IconData icon, Color color, bool isDark) {
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: textMuted, fontSize: 12)),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ]),
        ),
      ]),
    );
  }
}


// ─── Financial Report ──────────────────────────────────────────────────────────
class FinancialReportScreen extends StatelessWidget {
  final AppState? appState;
  const FinancialReportScreen({super.key, this.appState});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final l = AppLocalizations(appState?.language ?? 'English');
    final sym = appState?.currencySymbol ?? '₱';

    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('user_id', isEqualTo: currentUser?.email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        double totalRevenue = 0.0;
        double totalExpenses = 0.0;
        double totalTax = 0.0;
        
        Map<String, Map<String, double>> monthlyData = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
             final data = doc.data() as Map<String, dynamic>;
             final status = (data['status'] ?? '').toString().toLowerCase();
             
             if (status != 'cancelled' && status != 'refund' && status != 'refunded') {
                // 1. Calculate Revenue
                double orderRev = double.tryParse(data['totalAmount']?.toString() ?? data['total_amount']?.toString() ?? '0') ?? 0.0;
                totalRevenue += orderRev;
                
                // 2. Calculate Tax
                totalTax += double.tryParse(data['totalTax']?.toString() ?? data['total_tax']?.toString() ?? '0') ?? 0.0;

                // 3. Calculate Expenses (Cost of Goods Sold)
                List<dynamic> itemsList = [];
                final cartItemsRaw = data['cart_items'] ?? data['items'] ?? data['cartItems'];
                if (cartItemsRaw != null) {
                  if (cartItemsRaw is String) {
                    try { itemsList = jsonDecode(cartItemsRaw); } catch (e) {}
                  } else if (cartItemsRaw is List) {
                    itemsList = cartItemsRaw;
                  }
                }

                double orderCost = 0.0;
                for (var item in itemsList) {
                  if (item is Map) {
                    int qty = (item['quantity'] ?? item['qty'] ?? 1) as int;
                    double unitCost = double.tryParse(item['cost']?.toString() ?? '0') ?? 0.0; 
                    orderCost += (unitCost * qty);
                  }
                }
                totalExpenses += orderCost;

                // 4. Calculate Monthly Data for the bottom table
                final orderDate = _parseDate(data['createdAt'] ?? data['created_at'] ?? data['timestamp'] ?? data['date']);
                if (orderDate != null) {
                  String monthKey = DateFormat('MMM yyyy').format(orderDate); // e.g., "Apr 2026"
                  if (!monthlyData.containsKey(monthKey)) {
                    monthlyData[monthKey] = {'rev': 0.0, 'exp': 0.0, 'net': 0.0};
                  }
                  monthlyData[monthKey]!['rev'] = monthlyData[monthKey]!['rev']! + orderRev;
                  monthlyData[monthKey]!['exp'] = monthlyData[monthKey]!['exp']! + orderCost;
                  monthlyData[monthKey]!['net'] = monthlyData[monthKey]!['rev']! - monthlyData[monthKey]!['exp']!;
                }
             }
          }
        }
        
        double netProfit = totalRevenue - totalExpenses;
        bool isProfit = netProfit >= 0;

        List<List<String>> sortedMonthlyRows = [];
        monthlyData.forEach((month, metrics) {
          sortedMonthlyRows.add([
            month, 
            '$sym${metrics['rev']!.toStringAsFixed(2)}', 
            '$sym${metrics['exp']!.toStringAsFixed(2)}', 
            '${metrics['net']! >= 0 ? '' : '-'}$sym${metrics['net']!.abs().toStringAsFixed(2)}'
          ]);
        });

        if (sortedMonthlyRows.isEmpty) {
          String currentMonth = DateFormat('MMM yyyy').format(DateTime.now());
          sortedMonthlyRows.add([currentMonth, '${sym}0.00', '${sym}0.00', '${sym}0.00']);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.tr('Financial Report'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l.tr('Revenue, expenses and profit summary'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth < 500 ? 1 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.8,
                children: [
                  _finCard(l.tr('Total Revenue'), '$sym${totalRevenue.toStringAsFixed(2)}', Icons.trending_up,
                      const Color(0xFF22C88A), '+Live', isDark),
                  _finCard(l.tr('Total Expenses'), '$sym${totalExpenses.toStringAsFixed(2)}',
                      Icons.trending_down, Colors.redAccent, '-COGS', isDark),
                  _finCard(
                      l.tr('Net Profit'),
                      '${isProfit ? '' : '-'}$sym${netProfit.abs().toStringAsFixed(2)}',
                      Icons.account_balance_outlined,
                      isProfit ? const Color(0xFF22C88A) : Colors.redAccent,
                      '—',
                      isDark),
                  _finCard(
                      l.tr('Tax Liability'),
                      '$sym${totalTax.toStringAsFixed(2)}',
                      Icons.receipt_outlined,
                      const Color(0xFFF5C518),
                      'Collected',
                      isDark),
                ],
              );
            }),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.tr('Monthly Summary'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                ...sortedMonthlyRows.map((row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Expanded(
                            child: Text(row[0],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: textMuted, fontSize: 13))),
                        Expanded(
                            child: Text(row[1],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Color(0xFF22C88A), fontSize: 13))),
                        Expanded(
                            child: Text(row[2],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 13))),
                        Expanded(
                            child: Text(row[3],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: textMuted, fontSize: 13))),
                      ]),
                    )),
              ]),
            ),
          ]),
        );
      }
    );
  }

  Widget _finCard(String label, String value, IconData icon, Color color,
      String change, bool isDark) {
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: textMuted, fontSize: 11)),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(change,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: color, fontSize: 11)),
              ]),
        ),
      ]),
    );
  }
}

// ─── Settings Screen ───────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  final VoidCallback? onLogout;

  final String? scrollTo;
  const SettingsScreen(
      {super.key,
      required this.appState,
      required this.onStateChanged,
      this.onLogout,
      this.scrollTo});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollController = ScrollController();
  final _appearanceKey = GlobalKey();
  final _storeKey = GlobalKey();
  final _accountKey = GlobalKey();

  static const _countries = ['Philippines', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Japan', 'Singapore', 'Malaysia', 'Indonesia', 'Thailand', 'South Korea', 'India', 'Germany', 'France', 'Italy'];
  static const _currencies = ['PHP (₱)', 'USD (\$)', 'GBP (£)', 'EUR (€)', 'JPY (¥)', 'CAD (CA\$)', 'AUD (A\$)', 'SGD (S\$)', 'MYR (RM)', 'IDR (Rp)', 'THB (฿)', 'KRW (₩)', 'INR (₹)', 'CNY (¥)', 'HKD (HK\$)'];
  static const _languages = ['English', 'Filipino', 'Japanese', 'Spanish', 'French', 'Korean', 'Chinese'];

  @override
  void initState() {
    super.initState();
    final target = widget.scrollTo ?? SettingsScrollTarget.section;
    if (target != null && target.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToSection(target));
    }
  }

  @override
  void didUpdateWidget(SettingsScreen old) {
    super.didUpdateWidget(old);
    final newTarget = widget.scrollTo ?? SettingsScrollTarget.section;
    final oldTarget = old.scrollTo ?? SettingsScrollTarget.section;
    if (newTarget != null && newTarget.isNotEmpty && newTarget != oldTarget) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToSection(newTarget));
    }
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    if (section == 'appearance') key = _appearanceKey;
    if (section == 'store') key = _storeKey;
    if (section == 'account') key = _accountKey;
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.0);
  }

  void _save() {
    setState(() {});
    widget.onStateChanged();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showStoreNameDialog(BuildContext context, Color textPrimary,
      Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(text: widget.appState.storeName);
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Store Name'),
            style: TextStyle(
                color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: l.tr('Enter store name'),
            hintStyle: TextStyle(color: textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6BFB),
                foregroundColor: Colors.white),
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                widget.appState.storeName = v;
                _save();
              }
              Navigator.pop(context);
            },
            child: Text(l.tr('Save')),
          ),
        ],
      ),
    );
  }

  void _showAdminNameDialog(BuildContext context, Color textPrimary,
      Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(text: widget.appState.adminName);
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Admin Name'),
            style: TextStyle(
                color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: l.tr('Enter admin name'),
            hintStyle: TextStyle(color: textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6BFB),
                foregroundColor: Colors.white),
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                widget.appState.adminName = v;
                _save();
              }
              Navigator.pop(context);
            },
            child: Text(l.tr('Save')),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, Color textPrimary,
      Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(
        text: '${widget.appState.lowStockThresholdSetting}');
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Low Stock Threshold'),
            style: TextStyle(
                color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: l.tr('Enter units (e.g. 20)'),
            hintStyle: TextStyle(color: textMuted),
            suffixText: l.tr('units'),
            suffixStyle: TextStyle(color: textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6BFB),
                foregroundColor: Colors.white),
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v > 0) {
                widget.appState.lowStockThresholdSetting = v;
                _save();
              }
              Navigator.pop(context);
            },
            child: Text(l.tr('Save')),
          ),
        ],
      ),
    );
  }

  void _showPickerDialog({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
    required Color divider,
    required ValueChanged<String> onSelect,
  }) {
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(title,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              Divider(color: divider, height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: divider, height: 1),
                  itemBuilder: (_, i) {
                    final isSel = items[i] == selected;
                    return InkWell(
                      onTap: () {
                        onSelect(items[i]);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(children: [
                          Expanded(
                              child: Text(items[i],
                                  style: TextStyle(
                                    color: isSel
                                        ? const Color(0xFF4B6BFB)
                                        : textPrimary,
                                    fontSize: 14,
                                    fontWeight: isSel
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ))),
                          if (isSel)
                            const Icon(Icons.check,
                                color: Color(0xFF4B6BFB), size: 18),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgSection = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final l = AppLocalizations(appState.language);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Settings'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.tr('Customize your admin panel'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textMuted, fontSize: 13)),
        const SizedBox(height: 24),

        // ── Appearance
        SizedBox(key: _appearanceKey, height: 0),
        _section(l.tr('Appearance'), bgSection, divider, textMuted, [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.tr('Theme'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(l.tr('Choose your preferred appearance'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              Row(children: [
                _themeOption(
                    context: context,
                    label: l.tr('Light'),
                    icon: Icons.wb_sunny_outlined,
                    pref: ThemePreference.light,
                    appState: appState,
                    onStateChanged: _save,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted),
                const SizedBox(width: 10),
                _themeOption(
                    context: context,
                    label: l.tr('Dark'),
                    icon: Icons.nightlight_round,
                    pref: ThemePreference.dark,
                    appState: appState,
                    onStateChanged: _save,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted),
                const SizedBox(width: 10),
                _themeOption(
                    context: context,
                    label: l.tr('System'),
                    icon: Icons.settings_suggest_outlined,
                    pref: ThemePreference.system,
                    appState: appState,
                    onStateChanged: _save,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Store Information
        SizedBox(key: _storeKey, height: 0),
        _section(l.tr('Store Information'), bgSection, divider, textMuted, [
          _settingsTile(l.tr('Store Name'), appState.storeName,
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showStoreNameDialog(
                  context, textPrimary, textMuted, isDark, l)),
          _settingsTile(l.tr('Country'), appState.country,
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing:
                  Icon(Icons.keyboard_arrow_right, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                    context: context,
                    title: l.tr('Select Country'),
                    items: _countries,
                    selected: appState.country,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    divider: divider,
                    onSelect: (v) {
                      appState.country = v;
                      _save();
                    },
                  )),
          _settingsTile(l.tr('Currency'), appState.currency,
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing:
                  Icon(Icons.keyboard_arrow_right, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                    context: context,
                    title: l.tr('Select Currency'),
                    items: _currencies,
                    selected: appState.currency,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    divider: divider,
                    onSelect: (v) {
                      appState.currency = v;
                      _save();
                    },
                  )),
          _settingsTile(l.tr('Language'), appState.language,
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing: Icon(Icons.language, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                    context: context,
                    title: l.tr('Select Language'),
                    items: _languages,
                    selected: appState.language,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    divider: divider,
                    onSelect: (v) {
                      appState.language = v;
                      _save();
                    },
                  )),
          _settingsTile(l.tr('Low Stock Threshold'),
              '${appState.lowStockThresholdSetting} ${l.tr('units')}',
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showLowStockDialog(
                  context, textPrimary, textMuted, isDark, l)),
        ]),
        const SizedBox(height: 20),

        // ── Account
        SizedBox(key: _accountKey, height: 0),
        _section(l.tr('Account'), bgSection, divider, textMuted, [
          _settingsTile(l.tr('Admin Name'), appState.adminName,
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showAdminNameDialog(
                  context, textPrimary, textMuted, isDark, l)),
          _settingsTile(
              l.tr('Notifications'), l.tr('Configure alert preferences'),
              textPrimary: textPrimary,
              textMuted: textMuted,
              divider: divider,
              trailing: Icon(Icons.notifications_outlined,
                  color: textMuted, size: 18)),
        ]),
        const SizedBox(height: 20),

        // ── Log Out
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(l.tr('Log Out'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text(l.tr('Sign out of the admin panel'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textMuted, fontSize: 11)),
                ])),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor:
                      isDark ? const Color(0xFF1A1D2E) : Colors.white,
                  title: Text(l.tr('Log Out'),
                      style: TextStyle(color: textPrimary)),
                  content: Text(l.tr('Are you sure you want to log out?'),
                      style: TextStyle(color: textMuted)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.tr('Cancel'))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        Navigator.pop(context); 
                        
                        widget.appState.products.clear();
                        widget.appState.categories.clear();
                        
                        await FirebaseAuth.instance.signOut();
                        
                        widget.onLogout?.call(); 
                      },
                      child: Text(l.tr('Log Out')),
                    ),
                  ],
                ),
              ),
              child: Text(l.tr('Log Out'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _section(String title, Color bg, Color divider, Color textMuted,
      List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Text(title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
        ),
        Divider(color: divider, height: 1),
        ...children,
      ]),
    );
  }

  Widget _settingsTile(
    String label,
    String value, {
    required Color textPrimary,
    required Color textMuted,
    required Color divider,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textMuted, fontSize: 12)),
                  ]),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ]),
        ),
      ),
      Divider(color: divider, height: 1),
    ]);
  }

  Widget _themeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemePreference pref,
    required AppState appState,
    required VoidCallback onStateChanged,
    required bool isDark,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final selected = appState.themePreference == pref;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          appState.themePreference = pref;
          onStateChanged();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4B6BFB).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4B6BFB)
                  : (isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: selected ? const Color(0xFF4B6BFB) : textMuted,
                size: 20),
            const SizedBox(height: 4),
            Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: selected ? const Color(0xFF4B6BFB) : textMuted,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }
} // end _SettingsScreenState

// ─── Hamburger Menu / App Drawer ───────────────────────────────────────────────
class AppDrawerHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;
  final bool isCollapsed;

  const AppDrawerHeader({
    super.key,
    required this.title,
    required this.onMenuTap,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: Icon(
              isCollapsed ? Icons.menu : Icons.menu_open,
              color: textPrimary,
              size: 22,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}