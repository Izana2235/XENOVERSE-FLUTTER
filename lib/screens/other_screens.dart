import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/app_state.dart';
import '../models/settings_scroll_target.dart';

// ─── Localization ──────────────────────────────────────────────────────────────
/// Add `String language = 'English';` to your AppState model.
/// Supported language codes (display names used as keys):
///   English | Filipino | Japanese | Spanish | French | Korean | Chinese
class AppLocalizations {
  final String language;
  const AppLocalizations(this.language);

  static const _strings = <String, Map<String, String>>{
    // ── Common ─────────────────────────────────────────────────────────────
    'Settings':           {'Filipino':'Mga Setting','Japanese':'設定','Spanish':'Configuración','French':'Paramètres','Korean':'설정','Chinese':'设置'},
    'Customize your admin panel': {'Filipino':'I-customize ang iyong admin panel','Japanese':'管理パネルをカスタマイズ','Spanish':'Personaliza tu panel de administración','French':'Personnalisez votre panneau d\'administration','Korean':'관리 패널 사용자 정의','Chinese':'自定义您的管理面板'},
    'Appearance':         {'Filipino':'Hitsura','Japanese':'外観','Spanish':'Apariencia','French':'Apparence','Korean':'화면','Chinese':'外观'},
    'Theme':              {'Filipino':'Tema','Japanese':'テーマ','Spanish':'Tema','French':'Thème','Korean':'테마','Chinese':'主题'},
    'Choose your preferred appearance': {'Filipino':'Piliin ang iyong gusto','Japanese':'お好みの外観を選択','Spanish':'Elige tu apariencia preferida','French':'Choisissez votre apparence préférée','Korean':'원하는 외관 선택','Chinese':'选择您喜欢的外观'},
    'Light':              {'Filipino':'Maliwanag','Japanese':'ライト','Spanish':'Claro','French':'Clair','Korean':'라이트','Chinese':'浅色'},
    'Dark':               {'Filipino':'Madilim','Japanese':'ダーク','Spanish':'Oscuro','French':'Sombre','Korean':'다크','Chinese':'深色'},
    'System':             {'Filipino':'Sistema','Japanese':'システム','Spanish':'Sistema','French':'Système','Korean':'시스템','Chinese':'系统'},
    'Store Information':  {'Filipino':'Impormasyon ng Tindahan','Japanese':'店舗情報','Spanish':'Información de la tienda','French':'Informations du magasin','Korean':'매장 정보','Chinese':'商店信息'},
    'Store Name':         {'Filipino':'Pangalan ng Tindahan','Japanese':'店舗名','Spanish':'Nombre de la tienda','French':'Nom du magasin','Korean':'매장 이름','Chinese':'店铺名称'},
    'Country':            {'Filipino':'Bansa','Japanese':'国','Spanish':'País','French':'Pays','Korean':'국가','Chinese':'国家'},
    'Currency':           {'Filipino':'Pera','Japanese':'通貨','Spanish':'Moneda','French':'Devise','Korean':'통화','Chinese':'货币'},
    'Language':           {'Filipino':'Wika','Japanese':'言語','Spanish':'Idioma','French':'Langue','Korean':'언어','Chinese':'语言'},
    'Low Stock Threshold':{'Filipino':'Limitasyon ng Mababang Stock','Japanese':'在庫少量しきい値','Spanish':'Umbral de stock bajo','French':'Seuil de stock bas','Korean':'낮은 재고 임계값','Chinese':'低库存阈值'},
    'Account':            {'Filipino':'Account','Japanese':'アカウント','Spanish':'Cuenta','French':'Compte','Korean':'계정','Chinese':'账户'},
    'Admin Name':         {'Filipino':'Pangalan ng Admin','Japanese':'管理者名','Spanish':'Nombre del administrador','French':'Nom de l\'administrateur','Korean':'관리자 이름','Chinese':'管理员名称'},
    'Notifications':      {'Filipino':'Mga Notification','Japanese':'通知','Spanish':'Notificaciones','French':'Notifications','Korean':'알림','Chinese':'通知'},
    'Configure alert preferences': {'Filipino':'I-configure ang mga alerto','Japanese':'アラート設定を構成','Spanish':'Configurar preferencias de alerta','French':'Configurer les préférences d\'alerte','Korean':'알림 설정 구성','Chinese':'配置提醒偏好'},
    'Log Out':            {'Filipino':'Mag-logout','Japanese':'ログアウト','Spanish':'Cerrar sesión','French':'Déconnexion','Korean':'로그아웃','Chinese':'退出登录'},
    'Sign out of the admin panel': {'Filipino':'Mag-sign out sa admin panel','Japanese':'管理パネルからサインアウト','Spanish':'Cerrar sesión del panel de administración','French':'Se déconnecter du panneau d\'administration','Korean':'관리 패널에서 로그아웃','Chinese':'退出管理面板'},
    'Are you sure you want to log out?': {'Filipino':'Sigurado ka bang mag-logout?','Japanese':'本当にログアウトしますか？','Spanish':'¿Estás seguro de que deseas cerrar sesión?','French':'Êtes-vous sûr de vouloir vous déconnecter ?','Korean':'정말 로그아웃하시겠습니까?','Chinese':'确定要退出登录吗？'},
    'Cancel':             {'Filipino':'Kanselahin','Japanese':'キャンセル','Spanish':'Cancelar','French':'Annuler','Korean':'취소','Chinese':'取消'},
    'Save':               {'Filipino':'I-save','Japanese':'保存','Spanish':'Guardar','French':'Enregistrer','Korean':'저장','Chinese':'保存'},
    // ── Low Stock Screen ───────────────────────────────────────────────────
    'Low Stock Items':    {'Filipino':'Mga Produktong Mababa ang Stock','Japanese':'在庫少量商品','Spanish':'Artículos con bajo stock','French':'Articles à faible stock','Korean':'재고 부족 상품','Chinese':'低库存商品'},
    'Products requiring restocking': {'Filipino':'Mga produktong kailangang i-restock','Japanese':'補充が必要な商品','Spanish':'Productos que requieren reabastecimiento','French':'Produits nécessitant un réapprovisionnement','Korean':'재입고가 필요한 제품','Chinese':'需要补货的产品'},
    'All stock levels are healthy!': {'Filipino':'Lahat ng stock ay sapat!','Japanese':'すべての在庫は正常です！','Spanish':'¡Todos los niveles de stock están bien!','French':'Tous les niveaux de stock sont sains !','Korean':'모든 재고 수준이 정상입니다!','Chinese':'所有库存水平均正常！'},
    'Product':            {'Filipino':'Produkto','Japanese':'商品','Spanish':'Producto','French':'Produit','Korean':'제품','Chinese':'产品'},
    'Category':           {'Filipino':'Kategorya','Japanese':'カテゴリー','Spanish':'Categoría','French':'Catégorie','Korean':'카테고리','Chinese':'类别'},
    'Price':              {'Filipino':'Presyo','Japanese':'価格','Spanish':'Precio','French':'Prix','Korean':'가격','Chinese':'价格'},
    'Stock':              {'Filipino':'Stock','Japanese':'在庫','Spanish':'Stock','French':'Stock','Korean':'재고','Chinese':'库存'},
    // ── Order History ──────────────────────────────────────────────────────
    'Order History':      {'Filipino':'Kasaysayan ng Order','Japanese':'注文履歴','Spanish':'Historial de pedidos','French':'Historique des commandes','Korean':'주문 내역','Chinese':'订单历史'},
    'View and manage all orders': {'Filipino':'Tingnan at pamahalaan ang lahat ng order','Japanese':'すべての注文を表示・管理','Spanish':'Ver y gestionar todos los pedidos','French':'Voir et gérer toutes les commandes','Korean':'모든 주문 보기 및 관리','Chinese':'查看和管理所有订单'},
    'Total Revenue':      {'Filipino':'Kabuuang Kita','Japanese':'総収益','Spanish':'Ingresos totales','French':'Revenu total','Korean':'총 수익','Chinese':'总收入'},
    'Total Orders':       {'Filipino':'Kabuuang Order','Japanese':'総注文数','Spanish':'Pedidos totales','French':'Total des commandes','Korean':'총 주문 수','Chinese':'总订单'},
    'Avg Order Value':    {'Filipino':'Avg na Halaga ng Order','Japanese':'平均注文金額','Spanish':'Valor promedio del pedido','French':'Valeur moyenne des commandes','Korean':'평균 주문 금액','Chinese':'平均订单金额'},
    'Search order ID...': {'Filipino':'Hanapin ang order ID...','Japanese':'注文IDを検索...','Spanish':'Buscar ID de pedido...','French':'Rechercher l\'ID de commande...','Korean':'주문 ID 검색...','Chinese':'搜索订单ID...'},
    'All':                {'Filipino':'Lahat','Japanese':'すべて','Spanish':'Todo','French':'Tout','Korean':'전체','Chinese':'全部'},
    'Today':              {'Filipino':'Ngayon','Japanese':'今日','Spanish':'Hoy','French':'Aujourd\'hui','Korean':'오늘','Chinese':'今天'},
    'Week':               {'Filipino':'Linggo','Japanese':'今週','Spanish':'Semana','French':'Semaine','Korean':'이번 주','Chinese':'本周'},
    'No orders found':    {'Filipino':'Walang nahanap na order','Japanese':'注文が見つかりません','Spanish':'No se encontraron pedidos','French':'Aucune commande trouvée','Korean':'주문을 찾을 수 없습니다','Chinese':'未找到订单'},
    // ── Sales Report ───────────────────────────────────────────────────────
    'Sales Analytics':    {'Filipino':'Pagsusuri ng Benta','Japanese':'売上分析','Spanish':'Análisis de ventas','French':'Analyse des ventes','Korean':'판매 분석','Chinese':'销售分析'},
    'Business intelligence and insights': {'Filipino':'Business intelligence at mga insight','Japanese':'ビジネスインテリジェンスと洞察','Spanish':'Inteligencia empresarial e información','French':'Intelligence d\'affaires et perspectives','Korean':'비즈니스 인텔리전스 및 인사이트','Chinese':'商业智能与洞察'},
    'Export':             {'Filipino':'I-export','Japanese':'エクスポート','Spanish':'Exportar','French':'Exporter','Korean':'내보내기','Chinese':'导出'},
    'Revenue & Orders Trend': {'Filipino':'Trend ng Kita at Order','Japanese':'収益・注文トレンド','Spanish':'Tendencia de ingresos y pedidos','French':'Tendance des revenus et commandes','Korean':'수익 및 주문 트렌드','Chinese':'收入和订单趋势'},
    'Daily performance':  {'Filipino':'Pang-araw-araw na performance','Japanese':'日次パフォーマンス','Spanish':'Rendimiento diario','French':'Performance quotidienne','Korean':'일별 성과','Chinese':'每日业绩'},
    'Revenue by Category':{'Filipino':'Kita ayon sa Kategorya','Japanese':'カテゴリ別収益','Spanish':'Ingresos por categoría','French':'Revenus par catégorie','Korean':'카테고리별 수익','Chinese':'按类别收入'},
    'No data available':  {'Filipino':'Walang available na data','Japanese':'データなし','Spanish':'No hay datos disponibles','French':'Aucune donnée disponible','Korean':'데이터 없음','Chinese':'暂无数据'},
    // ── Inventory Report ───────────────────────────────────────────────────
    'Inventory Report':   {'Filipino':'Ulat ng Imbentaryo','Japanese':'在庫レポート','Spanish':'Informe de inventario','French':'Rapport d\'inventaire','Korean':'재고 보고서','Chinese':'库存报告'},
    'Overview of your inventory status': {'Filipino':'Pangkalahatang-ideya ng iyong imbentaryo','Japanese':'在庫状況の概要','Spanish':'Resumen del estado de tu inventario','French':'Aperçu de votre état des stocks','Korean':'재고 현황 개요','Chinese':'库存状态概览'},
    'Total Units':        {'Filipino':'Kabuuang Yunit','Japanese':'総ユニット','Spanish':'Unidades totales','French':'Unités totales','Korean':'총 단위','Chinese':'总单位'},
    'Low Stock Items Count': {'Filipino':'Mga Mababang Stock','Japanese':'在庫少量','Spanish':'Artículos con bajo stock','French':'Articles à faible stock','Korean':'저재고 상품','Chinese':'低库存商품'},
    'Inventory Value':    {'Filipino':'Halaga ng Imbentaryo','Japanese':'在庫価値','Spanish':'Valor del inventario','French':'Valeur de l\'inventaire','Korean':'재고 가치','Chinese':'库存价值'},
    'Product Breakdown':  {'Filipino':'Detalye ng Produkto','Japanese':'商品内訳','Spanish':'Desglose de productos','French':'Détail des produits','Korean':'제품 세부 내역','Chinese':'产品明细'},
    'Value':              {'Filipino':'Halaga','Japanese':'価値','Spanish':'Valor','French':'Valeur','Korean':'가치','Chinese':'价值'},
    'Status':             {'Filipino':'Status','Japanese':'ステータス','Spanish':'Estado','French':'Statut','Korean':'상태','Chinese':'状态'},
    // ── Customer Report ────────────────────────────────────────────────────
    'Customer Report':    {'Filipino':'Ulat ng Customer','Japanese':'顧客レポート','Spanish':'Informe de clientes','French':'Rapport clients','Korean':'고객 보고서','Chinese':'客户报告'},
    'Customer activity and spending overview': {'Filipino':'Aktibidad at gastos ng customer','Japanese':'顧客活動と支出の概要','Spanish':'Actividad y gasto de los clientes','French':'Activité et dépenses des clients','Korean':'고객 활동 및 지출 개요','Chinese':'客户活动及消费概览'},
    'Total Customers':    {'Filipino':'Kabuuang Customer','Japanese':'総顧客数','Spanish':'Total de clientes','French':'Total des clients','Korean':'총 고객 수','Chinese':'总客户数'},
    'Active This Month':  {'Filipino':'Aktibo Ngayong Buwan','Japanese':'今月アクティブ','Spanish':'Activos este mes','French':'Actifs ce mois','Korean':'이번 달 활성','Chinese':'本月活跃'},
    'Avg Spend':          {'Filipino':'Avg na Gastos','Japanese':'平均支出','Spanish':'Gasto promedio','French':'Dépense moyenne','Korean':'평균 지출','Chinese':'平均消费'},
    'Customer':           {'Filipino':'Customer','Japanese':'顧客','Spanish':'Cliente','French':'Client','Korean':'고객','Chinese':'客户'},
    'Orders':             {'Filipino':'Mga Order','Japanese':'注文','Spanish':'Pedidos','French':'Commandes','Korean':'주문','Chinese':'订单'},
    'Total Spent':        {'Filipino':'Kabuuang Gastos','Japanese':'合計支出','Spanish':'Total gastado','French':'Total dépensé','Korean':'총 지출','Chinese':'总花费'},
    // ── Financial Report ───────────────────────────────────────────────────
    'Financial Report':   {'Filipino':'Ulat sa Pananalapi','Japanese':'財務レポート','Spanish':'Informe financiero','French':'Rapport financier','Korean':'재무 보고서','Chinese':'财务报告'},
    'Revenue, expenses and profit summary': {'Filipino':'Buod ng kita, gastos at kita','Japanese':'収益・経費・利益のまとめ','Spanish':'Resumen de ingresos, gastos y ganancias','French':'Résumé des revenus, dépenses et bénéfices','Korean':'수익, 비용 및 이익 요약','Chinese':'收入、支出和利润摘要'},
    'Total Expenses':     {'Filipino':'Kabuuang Gastos','Japanese':'総経費','Spanish':'Gastos totales','French':'Dépenses totales','Korean':'총 비용','Chinese':'总支出'},
    'Net Profit':         {'Filipino':'Net na Kita','Japanese':'純利益','Spanish':'Beneficio neto','French':'Bénéfice net','Korean':'순이익','Chinese':'净利润'},
    'Tax Liability':      {'Filipino':'Pananagutang Buwis','Japanese':'税負担','Spanish':'Pasivo fiscal','French':'Passif fiscal','Korean':'세금 부채','Chinese':'税务负债'},
    'Monthly Summary':    {'Filipino':'Buwanang Buod','Japanese':'月次サマリー','Spanish':'Resumen mensual','French':'Résumé mensuel','Korean':'월별 요약','Chinese':'月度摘要'},
    // ── Select dialogs ─────────────────────────────────────────────────────
    'Select Country':     {'Filipino':'Pumili ng Bansa','Japanese':'国を選択','Spanish':'Seleccionar país','French':'Sélectionner un pays','Korean':'국가 선택','Chinese':'选择国家'},
    'Select Currency':    {'Filipino':'Pumili ng Pera','Japanese':'通貨を選択','Spanish':'Seleccionar moneda','French':'Sélectionner une devise','Korean':'통화 선택','Chinese':'选择货币'},
    'Select Language':    {'Filipino':'Pumili ng Wika','Japanese':'言語を選択','Spanish':'Seleccionar idioma','French':'Sélectionner une langue','Korean':'언어 선택','Chinese':'选择语言'},
    'Enter store name':   {'Filipino':'Ilagay ang pangalan ng tindahan','Japanese':'店舗名を入力','Spanish':'Ingresa el nombre de la tienda','French':'Entrez le nom du magasin','Korean':'매장 이름 입력','Chinese':'输入店铺名称'},
    'Enter admin name':   {'Filipino':'Ilagay ang pangalan ng admin','Japanese':'管理者名を入力','Spanish':'Ingresa el nombre del administrador','French':'Entrez le nom de l\'administrateur','Korean':'관리자 이름 입력','Chinese':'输入管理员名称'},
    'Enter units (e.g. 20)': {'Filipino':'Ilagay ang mga yunit (hal. 20)','Japanese':'単位を入力（例：20）','Spanish':'Ingresa las unidades (ej. 20)','French':'Entrez les unités (ex. 20)','Korean':'단위 입력 (예: 20)','Chinese':'输入单位（例：20）'},
    'units':              {'Filipino':'yunit','Japanese':'個','Spanish':'unidades','French':'unités','Korean':'단위','Chinese':'单位'},
    'Administrator':      {'Filipino':'Administrador','Japanese':'管理者','Spanish':'Administrador','French':'Administrateur','Korean':'관리자','Chinese':'管理员'},
  };

  String tr(String key) {
    if (language == 'English') return key;
    return _strings[key]?[language] ?? key;
  }
}


// ─── Low Stock Screen ──────────────────────────────────────────────────────────
class LowStockScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStateChanged;
  const LowStockScreen(
      {super.key, required this.appState, required this.onStateChanged});

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
        Text(
          l.tr('Low Stock Items'),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l.tr('Products requiring restocking'),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;
          return Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(14),
              border:
                  isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
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
                          l.tr('All stock levels are healthy!'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textPrimary, fontSize: 15),
                        ),
                      ]),
                    ))
                : Column(children: [
                    // ── Table header ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 13),
                      child: Row(children: [
                        Expanded(
                          flex: isNarrow ? 5 : 4,
                          child: Text(l.tr('Product'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: headerMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                        if (!isNarrow)
                          Expanded(
                            flex: 2,
                            child: Text(l.tr('Category'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: headerMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        Expanded(
                          flex: 2,
                          child: Text(l.tr('Price'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: headerMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(l.tr('Stock'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: headerMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                      ]),
                    ),
                    Divider(color: divider, height: 1),
                    // ── Table rows ──────────────────────────────────────
                    ...lowStock.map((p) => Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 11),
                            child: Row(children: [
                              Expanded(
                                flex: isNarrow ? 5 : 4,
                                child: Row(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.network(p.imageUrl,
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
                                                    size: 18))),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13)),
                                          Text('ID: ${p.id}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: textMuted,
                                                  fontSize: 11)),
                                        ]),
                                  ),
                                ]),
                              ),
                              if (!isNarrow)
                                Expanded(
                                  flex: 2,
                                  child: Text(p.category,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: textMuted, fontSize: 13)),
                                ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    '₱${p.price.toStringAsFixed(2)}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: textPrimary, fontSize: 13)),
                              ),
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
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text('${p.stock} units',
                                        style: const TextStyle(
                                            color: Color(0xFFF5C518),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ),
                                ),
                              ),
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
  String _filterKey = 'All'; // store key, display via l.tr()

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final bgInput = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);
    final l = AppLocalizations(widget.appState?.language ?? 'English');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Order History'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.tr('View and manage all orders'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textMuted, fontSize: 13)),
        const SizedBox(height: 20),

        // Metric cards
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth < 500 ? 1 : 3;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 3.0,
            children: [
              _metricCard(Icons.attach_money, const Color(0xFF4B6BFB),
                  l.tr('Total Revenue'), '₱0.00', isDark),
              _metricCard(Icons.calendar_today_outlined,
                  const Color(0xFF22C88A), l.tr('Total Orders'), '0', isDark),
              _metricCard(Icons.attach_money, const Color(0xFF9B59B6),
                  l.tr('Avg Order Value'), '₱0.00', isDark),
            ],
          );
        }),
        const SizedBox(height: 16),

        // Search + filter
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(children: [
            TextField(
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l.tr('Search order ID...'),
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                filled: true,
                fillColor: bgInput,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Today', 'Week'].map((f) {
                  final sel = _filterKey == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filterKey = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF4B6BFB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: sel
                            ? null
                            : Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFD1D5DB)),
                      ),
                      child: Text(l.tr(f),
                          style: TextStyle(
                              color: sel ? Colors.white : textMuted,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Orders table
        Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: Column(children: [
              Icon(Icons.receipt_long_outlined,
                  color: isDark ? Colors.white24 : Colors.black12, size: 52),
              const SizedBox(height: 12),
              Text(l.tr('No orders found'),
                  style: TextStyle(color: textMuted, fontSize: 15)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _metricCard(IconData icon, Color color, String label, String value,
      bool isDark) {
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
          padding: const EdgeInsets.all(9),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ]),
        ),
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
  String _period = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD1D5DB);
    final l = AppLocalizations(widget.appState?.language ?? 'English');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
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
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: borderColor)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _period,
                    dropdownColor: bgCard,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: textMuted, size: 16),
                    items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                        .map((p) =>
                            DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _period = v!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                ),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: Text(l.tr('Export'), style: const TextStyle(fontSize: 13)),
                onPressed: () {},
              ),
            ]),
          ],
        ),
        const SizedBox(height: 20),

        // Analytic cards
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth < 500 ? 2 : 4;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: c.maxWidth < 500 ? 1.1 : 1.4,
            children: [
              _anaCard(Icons.attach_money, const Color(0xFF2A4A8A),
                  l.tr('Total Revenue'), '₱0.00', 'Gross sales', '12.5% increase',
                  true, isDark),
              _anaCard(Icons.shopping_cart_outlined, const Color(0xFF1A5A3A),
                  l.tr('Total Orders'), '0', 'Completed', '8.3% increase', true,
                  isDark),
              _anaCard(Icons.trending_up, const Color(0xFF5A3A1A),
                  l.tr('Avg Order Value'), '₱0.00', 'Per transaction',
                  '2.1% decrease', false, isDark),
              _anaCard(Icons.people_outline, const Color(0xFF3A1A5A),
                  'Active Products', '9', 'In catalog', '5.7% increase', true,
                  isDark),
            ],
          );
        }),
        const SizedBox(height: 20),

        // Charts
        LayoutBuilder(builder: (ctx, c) {
          final isNarrow = c.maxWidth < 600;
          final chart = Container(
            height: isNarrow ? 200 : 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(12),
              border: isDark
                  ? null
                  : Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tr('Revenue & Orders Trend'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(l.tr('Daily performance'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textMuted, fontSize: 11)),
                  const SizedBox(height: 12),
                  const Expanded(child: _RevenueChart()),
                ]),
          );
          final pie = Container(
            height: isNarrow ? 160 : 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(12),
              border: isDark
                  ? null
                  : Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tr('Revenue by Category'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Center(
                      child: Text(l.tr('No data available'),
                          style: TextStyle(color: textMuted)),
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

  Widget _anaCard(IconData icon, Color bg, String label, String value,
      String sub, String trend, bool pos, bool isDark) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: textMuted, fontSize: 11)),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(7)),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
            ]),
            const SizedBox(height: 6),
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
                style: TextStyle(color: textMuted, fontSize: 10)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(pos ? Icons.trending_up : Icons.trending_down,
                  color:
                      pos ? const Color(0xFF22C88A) : Colors.redAccent,
                  size: 12),
              const SizedBox(width: 3),
              Flexible(
                child: Text(trend,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: pos
                            ? const Color(0xFF22C88A)
                            : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();
  @override
  Widget build(BuildContext context) {
    final r = math.Random(42);
    return CustomPaint(
      painter: _ChartPainter(
        bars: List.generate(30, (_) => 200 + r.nextDouble() * 600),
        line: List.generate(30, (_) => 10 + r.nextDouble() * 50),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> bars, line;
  const _ChartPainter({required this.bars, required this.line});
  @override
  void paint(Canvas canvas, Size size) {
    final maxB = bars.reduce(math.max), maxL = line.reduce(math.max);
    final sp = size.width / bars.length;
    final bw = sp * 0.6;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0),
        Paint()
          ..color = Colors.white12
          ..strokeWidth = 0.5);
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        Paint()
          ..color = Colors.white12
          ..strokeWidth = 0.5);
    for (int i = 0; i < bars.length; i++) {
      final x = i * sp + sp * 0.2;
      final bh = (bars[i] / maxB) * size.height * 0.85;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - bh, bw, bh),
            const Radius.circular(3)),
        Paint()..color = const Color(0xFF22C88A),
      );
    }
    final lp = Path(), fp = Path();
    for (int i = 0; i < line.length; i++) {
      final x = i * sp + sp / 2;
      final y = size.height - (line[i] / maxL) * size.height * 0.85;
      if (i == 0) {
        lp.moveTo(x, y);
        fp.moveTo(x, size.height);
        fp.lineTo(x, y);
      } else {
        lp.lineTo(x, y);
        fp.lineTo(x, y);
      }
    }
    fp.lineTo((line.length - 1) * sp + sp / 2, size.height);
    fp.close();
    canvas.drawPath(fp,
        Paint()..color = const Color(0xFF4B6BFB).withValues(alpha: 0.15));
    canvas.drawPath(
        lp,
        Paint()
          ..color = const Color(0xFF4B6BFB)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_) => false;
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

    final total = appState.products.fold<int>(0, (s, p) => s + p.stock);
    final lowCount = appState.lowStockProducts.length;
    final value =
        appState.products.fold<double>(0, (s, p) => s + p.price * p.stock);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Inventory Report'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
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
              _card(l.tr('Low Stock Items Count'), '$lowCount',
                  Icons.warning_amber_outlined,
                  const Color(0xFFE53935), isDark),
              _card(l.tr('Inventory Value'), '₱${value.toStringAsFixed(2)}',
                  Icons.attach_money, const Color(0xFF22C88A), isDark),
            ],
          );
        }),
        const SizedBox(height: 20),
        Text(l.tr('Product Breakdown'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
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
              ...appState.products.map((p) {
                final isLow = p.isLowStock;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Row(children: [
                      Expanded(
                          flex: isNarrow ? 4 : 3,
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: textPrimary, fontSize: 13))),
                      if (!isNarrow)
                        Expanded(
                            flex: 2,
                            child: Text(p.category,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style:
                                    TextStyle(color: textMuted, fontSize: 12))),
                      Expanded(
                          flex: 1,
                          child: Text('${p.stock}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: textPrimary, fontSize: 13))),
                      Expanded(
                          flex: 2,
                          child: Text(
                              '₱${(p.price * p.stock).toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: textPrimary, fontSize: 13))),
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

  Widget _card(String label, String value, IconData icon, Color color,
      bool isDark) {
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

// ─── Customer Report ───────────────────────────────────────────────────────────
class CustomerReportScreen extends StatelessWidget {
  final AppState? appState;
  const CustomerReportScreen({super.key, this.appState});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE5E7EB);
    final l = AppLocalizations(appState?.language ?? 'English');

    final customers = [
      {'name': 'Alice Johnson', 'email': 'alice@email.com', 'orders': '12', 'spent': '₱142.50', 'status': 'VIP'},
      {'name': 'Bob Martinez',  'email': 'bob@email.com',   'orders': '8',  'spent': '₱89.00',  'status': 'Regular'},
      {'name': 'Carol White',   'email': 'carol@email.com', 'orders': '3',  'spent': '₱34.75',  'status': 'New'},
      {'name': 'David Kim',     'email': 'david@email.com', 'orders': '20', 'spent': '₱278.00', 'status': 'VIP'},
      {'name': 'Eve Davis',     'email': 'eve@email.com',   'orders': '5',  'spent': '₱67.25',  'status': 'Regular'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Customer Report'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.tr('Customer activity and spending overview'),
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
              _metricCard(l.tr('Total Customers'), '1,500', Icons.people_outline,
                  const Color(0xFF4B6BFB), isDark),
              _metricCard(l.tr('Active This Month'), '342', Icons.person_outline,
                  const Color(0xFF22C88A), isDark),
              _metricCard(l.tr('Avg Spend'), '₱52.80', Icons.attach_money,
                  const Color(0xFF9B59B6), isDark),
            ],
          );
        }),
        const SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                child: Row(children: [
                  Expanded(
                      flex: isNarrow ? 4 : 3,
                      child: Text(l.tr('Customer'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12))),
                  Expanded(
                      flex: 1,
                      child: Text(l.tr('Orders'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12))),
                  Expanded(
                      flex: 2,
                      child: Text(l.tr('Total Spent'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12))),
                  Expanded(
                      flex: 1,
                      child: Text(l.tr('Status'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12))),
                ]),
              ),
              Divider(color: divider, height: 1),
              ...customers.map((c) {
                final statusColor = c['status'] == 'VIP'
                    ? const Color(0xFFF5C518)
                    : c['status'] == 'Regular'
                        ? const Color(0xFF4B6BFB)
                        : const Color(0xFF22C88A);
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Row(children: [
                      Expanded(
                          flex: isNarrow ? 4 : 3,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['name']!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                                Text(c['email']!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: textMuted, fontSize: 11)),
                              ])),
                      Expanded(
                          flex: 1,
                          child: Text(c['orders']!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: textPrimary, fontSize: 13))),
                      Expanded(
                          flex: 2,
                          child: Text(c['spent']!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13))),
                      Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(c['status']!,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
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

  Widget _metricCard(String label, String value, IconData icon, Color color,
      bool isDark) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.tr('Financial Report'),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
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
              _finCard(l.tr('Total Revenue'), '₱0.00', Icons.trending_up,
                  const Color(0xFF22C88A), '+0.0%', isDark),
              _finCard(l.tr('Total Expenses'), '₱2,340.00', Icons.trending_down,
                  Colors.redAccent, '-3.2%', isDark),
              _finCard(l.tr('Net Profit'), '-₱2,340.00',
                  Icons.account_balance_outlined,
                  const Color(0xFF4B6BFB), '—', isDark),
              _finCard(l.tr('Tax Liability'), '₱0.00', Icons.receipt_outlined,
                  const Color(0xFFF5C518), '0%', isDark),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.tr('Monthly Summary'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            ...[
              ['Jan', '₱0.00', '₱540.00', '-₱540.00'],
              ['Feb', '₱0.00', '₱620.00', '-₱620.00'],
              ['Mar', '₱0.00', '₱580.00', '-₱580.00'],
            ].map((row) => Padding(
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
  /// Optional section to scroll to on load: 'appearance' | 'store' | 'account'
  final String? scrollTo;
  const SettingsScreen(
      {super.key,
      required this.appState,
      required this.onStateChanged,
      this.scrollTo});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollController = ScrollController();
  final _appearanceKey = GlobalKey();
  final _storeKey = GlobalKey();
  final _accountKey = GlobalKey();

  static const _countries = [
    'Philippines', 'United States', 'United Kingdom', 'Canada', 'Australia',
    'Japan', 'Singapore', 'Malaysia', 'Indonesia', 'Thailand',
    'South Korea', 'India', 'Germany', 'France', 'Italy',
  ];

  static const _currencies = [
    'PHP (₱)', 'USD (\$)', 'GBP (£)', 'EUR (€)', 'JPY (¥)',
    'CAD (CA\$)', 'AUD (A\$)', 'SGD (S\$)', 'MYR (RM)', 'IDR (Rp)',
    'THB (฿)', 'KRW (₩)', 'INR (₹)', 'CNY (¥)', 'HKD (HK\$)',
  ];

  static const _languages = [
    'English', 'Filipino', 'Japanese', 'Spanish', 'French', 'Korean', 'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    final target = widget.scrollTo ?? SettingsScrollTarget.section;
    if (target != null && target.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(target));
    }
  }

  @override
  void didUpdateWidget(SettingsScreen old) {
    super.didUpdateWidget(old);
    final newTarget = widget.scrollTo ?? SettingsScrollTarget.section;
    final oldTarget = old.scrollTo ?? SettingsScrollTarget.section;
    if (newTarget != null && newTarget.isNotEmpty && newTarget != oldTarget) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(newTarget));
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

  void _showStoreNameDialog(BuildContext context, Color textPrimary, Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(text: widget.appState.storeName);
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Store Name'), style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: l.tr('Enter store name'),
            hintStyle: TextStyle(color: textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white),
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) { widget.appState.storeName = v; _save(); }
              Navigator.pop(context);
            },
            child: Text(l.tr('Save')),
          ),
        ],
      ),
    );
  }

  void _showAdminNameDialog(BuildContext context, Color textPrimary, Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(text: widget.appState.adminName);
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Admin Name'), style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: l.tr('Enter admin name'),
            hintStyle: TextStyle(color: textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white),
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) { widget.appState.adminName = v; _save(); }
              Navigator.pop(context);
            },
            child: Text(l.tr('Save')),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, Color textPrimary, Color textMuted, bool isDark, AppLocalizations l) {
    final controller = TextEditingController(text: '${widget.appState.lowStockThresholdSetting}');
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l.tr('Low Stock Threshold'), style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
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
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMuted.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B6BFB))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.tr('Cancel'), style: TextStyle(color: textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B6BFB), foregroundColor: Colors.white),
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v > 0) { widget.appState.lowStockThresholdSetting = v; _save(); }
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
                child: Text(title, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Divider(color: divider, height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(color: divider, height: 1),
                  itemBuilder: (_, i) {
                    final isSel = items[i] == selected;
                    return InkWell(
                      onTap: () { onSelect(items[i]); Navigator.pop(context); },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(children: [
                          Expanded(child: Text(items[i], style: TextStyle(
                            color: isSel ? const Color(0xFF4B6BFB) : textPrimary,
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                          ))),
                          if (isSel) const Icon(Icons.check, color: Color(0xFF4B6BFB), size: 18),
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
        Text(l.tr('Settings'), overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.tr('Customize your admin panel'), overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textMuted, fontSize: 13)),
        const SizedBox(height: 24),

        // ── Appearance
        SizedBox(key: _appearanceKey, height: 0),
        _section(l.tr('Appearance'), bgSection, divider, textMuted, [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.tr('Theme'), overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(l.tr('Choose your preferred appearance'), overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              Row(children: [
                _themeOption(context: context, label: l.tr('Light'), icon: Icons.wb_sunny_outlined,
                    pref: ThemePreference.light, appState: appState, onStateChanged: _save,
                    isDark: isDark, textPrimary: textPrimary, textMuted: textMuted),
                const SizedBox(width: 10),
                _themeOption(context: context, label: l.tr('Dark'), icon: Icons.nightlight_round,
                    pref: ThemePreference.dark, appState: appState, onStateChanged: _save,
                    isDark: isDark, textPrimary: textPrimary, textMuted: textMuted),
                const SizedBox(width: 10),
                _themeOption(context: context, label: l.tr('System'), icon: Icons.settings_suggest_outlined,
                    pref: ThemePreference.system, appState: appState, onStateChanged: _save,
                    isDark: isDark, textPrimary: textPrimary, textMuted: textMuted),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Store Information
        SizedBox(key: _storeKey, height: 0),
        _section(l.tr('Store Information'), bgSection, divider, textMuted, [
          _settingsTile(l.tr('Store Name'), appState.storeName,
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showStoreNameDialog(context, textPrimary, textMuted, isDark, l)),
          _settingsTile(l.tr('Country'), appState.country,
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.keyboard_arrow_right, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                context: context, title: l.tr('Select Country'),
                items: _countries, selected: appState.country,
                isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, divider: divider,
                onSelect: (v) { appState.country = v; _save(); },
              )),
          _settingsTile(l.tr('Currency'), appState.currency,
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.keyboard_arrow_right, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                context: context, title: l.tr('Select Currency'),
                items: _currencies, selected: appState.currency,
                isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, divider: divider,
                onSelect: (v) { appState.currency = v; _save(); },
              )),
          _settingsTile(l.tr('Language'), appState.language,
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.language, color: textMuted, size: 18),
              onTap: () => _showPickerDialog(
                context: context, title: l.tr('Select Language'),
                items: _languages, selected: appState.language,
                isDark: isDark, textPrimary: textPrimary, textMuted: textMuted, divider: divider,
                onSelect: (v) { appState.language = v; _save(); },
              )),
          _settingsTile(l.tr('Low Stock Threshold'), '${appState.lowStockThresholdSetting} ${l.tr('units')}',
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showLowStockDialog(context, textPrimary, textMuted, isDark, l)),
        ]),
        const SizedBox(height: 20),

        // ── Account
        SizedBox(key: _accountKey, height: 0),
        _section(l.tr('Account'), bgSection, divider, textMuted, [
          _settingsTile(l.tr('Admin Name'), appState.adminName,
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.edit_outlined, color: textMuted, size: 18),
              onTap: () => _showAdminNameDialog(context, textPrimary, textMuted, isDark, l)),
          _settingsTile(l.tr('Notifications'), l.tr('Configure alert preferences'),
              textPrimary: textPrimary, textMuted: textMuted, divider: divider,
              trailing: Icon(Icons.notifications_outlined, color: textMuted, size: 18)),
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.tr('Log Out'), overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(l.tr('Sign out of the admin panel'), overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textMuted, fontSize: 11)),
            ])),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
                  title: Text(l.tr('Log Out'), style: TextStyle(color: textPrimary)),
                  content: Text(l.tr('Are you sure you want to log out?'), style: TextStyle(color: textMuted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(l.tr('Cancel'))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.tr('Log Out')),
                    ),
                  ],
                ),
              ),
              child: Text(l.tr('Log Out'), style: const TextStyle(fontWeight: FontWeight.w600)),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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


// ─── Custom Toggle ─────────────────────────────────────────────────────────────
class _CustomToggle extends StatelessWidget {
  final bool value;
  const _CustomToggle({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 52,
      height: 30,
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF4B6BFB)
            : (isDark
                ? const Color(0xFF252840)
                : const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value
              ? const Color(0xFF4B6BFB)
              : (isDark ? Colors.white12 : const Color(0xFFD1D5DB)),
        ),
        boxShadow: value
            ? [
                BoxShadow(
                    color: const Color(0xFF4B6BFB).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [],
      ),
      child: Stack(children: [
        AnimatedPositioned(
          left: value ? 24 : 2,
          top: 2,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Hamburger Menu / App Drawer ───────────────────────────────────────────────
/// Drop this widget in wherever you build a sidebar/drawer.
/// The title row uses [CrossAxisAlignment.center] so the label sits
/// vertically centred next to the hamburger icon at every text scale.
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
        // ← key fix: centre icon and title on the same baseline
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
                  // Prevent font scaling from pushing the title out of alignment
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
