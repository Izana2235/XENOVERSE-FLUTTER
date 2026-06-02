import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';

class SalesReportScreen extends StatefulWidget {
  final AppState appState;
  const SalesReportScreen({super.key, required this.appState});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  bool _isLoading = true;
  
  // 🌟 Live Data Variables
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  double _avgOrderValue = 0.0;
  int _activeProducts = 0;
  Map<String, double> _categoryRevenue = {};

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _timeRange = 'All day';
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);
  String get _selectedDateLabel {
    final startDate = _selectedRange.start;
    final endDate = _selectedRange.end;
    if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
      return '${_monthNames[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
    }
    return '${_monthNames[startDate.month - 1]} ${startDate.day} - ${_monthNames[endDate.month - 1]} ${endDate.day}';
  }

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  // 🌟 BULLETPROOF DATE PARSER (Same as Order History)
  DateTime? _parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is int) return DateTime.fromMillisecondsSinceEpoch(dateVal);
    if (dateVal is String) {
      final tryInt = int.tryParse(dateVal);
      if (tryInt != null && tryInt > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(tryInt);
      }
      return DateTime.tryParse(dateVal);
    }
    return null;
  }

  // 🌟 CHECK TIME FILTER
  bool _isOrderInTimeRange(DateTime orderDate) {
    if (_timeRange == 'All day') return true;
    
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final orderMinutes = orderDate.hour * 60 + orderDate.minute;
    
    return orderMinutes >= startMinutes && orderMinutes <= endMinutes;
  }

  static const _appBlue = Color(0xFF4B6BFB);

  Future<TimeOfDay?> _showTimeDialog(BuildContext context, TimeOfDay initial) async {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgCard      = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted   = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final inputBg     = isDark ? const Color(0xFF252840) : const Color(0xFFF3F4F6);

    int  hour   = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    int  minute = initial.minute;
    bool isAm   = initial.period == DayPeriod.am;
    bool isDialMode    = false;
    bool selectingHour = true;

    final hourCtrl   = TextEditingController(text: hour.toString().padLeft(2, '0'));
    final minuteCtrl = TextEditingController(text: minute.toString().padLeft(2, '0'));

    return showDialog<TimeOfDay>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          Widget amPmToggle = Column(
            children: ['AM', 'PM'].map((p) {
              final sel = (p == 'AM') == isAm;
              return GestureDetector(
                onTap: () => setDlg(() => isAm = p == 'AM'),
                child: Container(
                  width: 52, height: 36,
                  decoration: BoxDecoration(
                    color: sel ? _appBlue.withValues(alpha: 0.13) : inputBg,
                    borderRadius: p == 'AM'
                        ? const BorderRadius.vertical(top: Radius.circular(8))
                        : const BorderRadius.vertical(bottom: Radius.circular(8)),
                    border: Border.all(color: sel ? _appBlue : (isDark ? Colors.white12 : const Color(0xFFE5E7EB))),
                  ),
                  child: Center(child: Text(p, style: TextStyle(color: sel ? _appBlue : textMuted, fontWeight: FontWeight.w700, fontSize: 13))),
                ),
              );
            }).toList(),
          );

          Widget timeDisplay = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setDlg(() => selectingHour = true),
                child: Container(
                  width: 80, height: 64,
                  decoration: BoxDecoration(
                    color: (isDialMode && selectingHour) ? _appBlue.withValues(alpha: 0.13) : inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (isDialMode && selectingHour) ? _appBlue : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(hour.toString().padLeft(2, '0'),
                    style: TextStyle(color: (isDialMode && selectingHour) ? _appBlue : textPrimary, fontSize: 36, fontWeight: FontWeight.w300))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(':', style: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => setDlg(() => selectingHour = false),
                child: Container(
                  width: 80, height: 64,
                  decoration: BoxDecoration(
                    color: (isDialMode && !selectingHour) ? _appBlue.withValues(alpha: 0.13) : inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (isDialMode && !selectingHour) ? _appBlue : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(minute.toString().padLeft(2, '0'),
                    style: TextStyle(color: (isDialMode && !selectingHour) ? _appBlue : textPrimary, fontSize: 36, fontWeight: FontWeight.w300))),
                ),
              ),
              const SizedBox(width: 10),
              amPmToggle,
            ],
          );

          Widget clockDial = GestureDetector(
            onPanUpdate: (details) {
              const dialSize = 220.0;
              const center = Offset(dialSize / 2, dialSize / 2);
              final angle = (details.localPosition - center).direction;
              if (selectingHour) {
                var h = ((angle + math.pi / 2) / (2 * math.pi) * 12).round() % 12;
                if (h == 0) h = 12;
                setDlg(() { hour = h; hourCtrl.text = h.toString().padLeft(2, '0'); });
              } else {
                var m = ((angle + math.pi / 2) / (2 * math.pi) * 60).round() % 60;
                if (m < 0) m += 60;
                setDlg(() { minute = m; minuteCtrl.text = m.toString().padLeft(2, '0'); });
              }
            },
            onTapUp: (_) { if (selectingHour) setDlg(() => selectingHour = false); },
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _ClockDialPainter(
                hour: hour, minute: minute, selectingHour: selectingHour,
                accentColor: _appBlue, textColor: textPrimary, mutedColor: textMuted, bgColor: inputBg, isDark: isDark,
              ),
            ),
          );

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0,8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isDialMode ? 'SELECT TIME' : 'ENTER TIME',
                      style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 20),
                  if (isDialMode) ...[
                    timeDisplay,
                    const SizedBox(height: 20),
                    Center(child: clockDial),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Column(children: [
                          Container(
                            height: 72,
                            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _appBlue, width: 2)),
                            child: Center(child: TextField(
                              controller: hourCtrl, textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w300),
                              decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                              maxLength: 2,
                              onChanged: (v) { final n = int.tryParse(v) ?? 1; setDlg(() => hour = n.clamp(1, 12)); },
                            )),
                          ),
                          const SizedBox(height: 6),
                          Text('Hour', style: TextStyle(color: textMuted, fontSize: 12)),
                        ])),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 28, left: 6, right: 6),
                          child: Text(':', style: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Column(children: [
                          Container(
                            height: 72,
                            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: TextField(
                              controller: minuteCtrl, textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w300),
                              decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                              maxLength: 2,
                              onChanged: (v) { final n = int.tryParse(v) ?? 0; setDlg(() => minute = n.clamp(0, 59)); },
                            )),
                          ),
                          const SizedBox(height: 6),
                          Text('Minute', style: TextStyle(color: textMuted, fontSize: 12)),
                        ])),
                        const SizedBox(width: 10),
                        amPmToggle,
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Tooltip(
                        message: isDialMode ? 'Switch to keyboard' : 'Switch to clock',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setDlg(() => isDialMode = !isDialMode),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: isDialMode ? _appBlue.withValues(alpha: 0.12) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDialMode ? _appBlue : (isDark ? Colors.white24 : const Color(0xFFD1D5DB))),
                            ),
                            child: Icon(isDialMode ? Icons.keyboard_outlined : Icons.access_time_outlined, color: isDialMode ? _appBlue : textMuted, size: 20),
                          ),
                        ),
                      ),
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
          );
        },
      ),
    );
  }

  Future<void> _pickStartTime() async {
    final picked = await _showTimeDialog(context, _startTime);
    if (picked != null) { setState(() => _startTime = picked); _fetchSalesData(); }
  }

  Future<void> _pickEndTime() async {
    final picked = await _showTimeDialog(context, _endTime);
    if (picked != null) { setState(() => _endTime = picked); _fetchSalesData(); }
  }

  Widget _buildTimeButton(TimeOfDay time, String label, VoidCallback onTap, Color textPrimary, Color textMuted, Color bgCard, Color borderColor) {
    return Container(
      width: 160,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            Text(
              time.format(context),
              style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Icon(Icons.access_time, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }

  // 🌟 FETCH REAL DATA FROM FIREBASE
  Future<void> _fetchSalesData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final email = currentUser.email?.trim().toLowerCase() ?? '';

      // 1. Fetch Active Products Count
      final productsQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: email)
          .get();
      
      int pCount = productsQuery.docs.length;

      // 2. Fetch Orders for Revenue Calculation
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: email)
          .get();

      double tRev = 0.0;
      int tOrders = 0;
      Map<String, double> catRev = {};

      for (var doc in ordersQuery.docs) {
        final data = doc.data();
        
        final orderDate = _parseDate(data['createdAt'] ?? data['created_at'] ?? data['date']);
        
        if (orderDate != null) {
          // Check if order falls within the selected DateRange
          if (orderDate.isAfter(_selectedRange.start.subtract(const Duration(days: 1))) &&
              orderDate.isBefore(_selectedRange.end.add(const Duration(days: 1))) &&
              _isOrderInTimeRange(orderDate)) {
              
              final status = (data['status'] ?? '').toString().toLowerCase();
              if (status != 'cancelled' && status != 'refund' && status != 'refunded') {
                 tOrders++;
                 double amount = double.tryParse(data['totalAmount']?.toString() ?? data['total_amount']?.toString() ?? '0') ?? 0.0;
                 tRev += amount;

                 // Parse items to figure out Category Revenue
                 List<dynamic> items = [];
                 if (data['items'] != null && data['items'] is List) items = data['items'];
                 if (data['cart_items'] != null && data['cart_items'] is List) items = data['cart_items'];

                 for(var item in items) {
                     if(item is Map) {
                        String cat = item['category']?.toString() ?? 'Others';
                        double itemPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                        double qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                        double itemTotal = double.tryParse(item['subtotal']?.toString() ?? '${itemPrice * qty}') ?? (itemPrice * qty);
                        
                        catRev[cat] = (catRev[cat] ?? 0.0) + itemTotal;
                     }
                 }
              }
          }
        }
      }

      if (mounted) {
        setState(() {
          _activeProducts = pCount;
          _totalRevenue = tRev;
          _totalOrders = tOrders;
          _avgOrderValue = tOrders > 0 ? tRev / tOrders : 0.0;
          _categoryRevenue = catRev;
          _isLoading = false;
        });
      }

    } catch(e) {
       debugPrint("🔥 Firebase Sales Report Error: $e");
       if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4B6BFB),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (newRange != null) {
      setState(() {
        _selectedRange = newRange;
      });
      // 🌟 RE-FETCH DATA WHEN DATES CHANGE
      _fetchSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD1D5DB);

    Widget toolbarBox({required Widget child}) {
      return Container(
        width: 160,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: child,
      );
    }

    final sym = widget.appState.currencySymbol;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Analytics',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive business intelligence and insights',
                      style: TextStyle(color: textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // ── Date picker: < [date] [calendar] ──────────────────────
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
                        // Back arrow — go back one day (or one period)
                        InkWell(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          onTap: () {
                            final diff = _selectedRange.end
                                .difference(_selectedRange.start);
                            setState(() {
                              _selectedRange = DateTimeRange(
                                start: _selectedRange.start
                                    .subtract(diff + const Duration(days: 1)),
                                end: _selectedRange.end
                                    .subtract(diff + const Duration(days: 1)),
                              );
                            });
                            _fetchSalesData();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.chevron_left,
                                size: 20, color: textMuted),
                          ),
                        ),
                        // Divider
                        Container(width: 1, height: 24, color: borderColor),
                        // Date label — tap to open calendar
                        InkWell(
                          onTap: _pickDateRange,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _selectedDateLabel,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Calendar icon — also opens picker
                        InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          onTap: _pickDateRange,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.calendar_month,
                                size: 18, color: textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Time range dropdown ────────────────────────────────────
                  toolbarBox(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _timeRange,
                        dropdownColor: bgCard,
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        icon: const SizedBox.shrink(),
                        items: ['All day', 'Custom period']
                            .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p,
                                    overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _timeRange = v);
                            _fetchSalesData();
                          }
                        },
                      ),
                    ),
                  ),
                  if (_timeRange == 'Custom period') ...[
                    _buildTimeButton(_startTime, 'Start', _pickStartTime,
                        textPrimary, textMuted, bgCard, borderColor),
                    const SizedBox(width: 10),
                    _buildTimeButton(_endTime, 'End', _pickEndTime,
                        textPrimary, textMuted, bgCard, borderColor),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF4B6BFB))),
            )
          else ...[
            // ── Analytic cards ────────────────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth < 500 ? 2 : 4;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: constraints.maxWidth < 500 ? 1.2 : 1.4,
                children: [
                  _AnalyticCard(
                      label: 'Total Revenue',
                      value: '$sym${_totalRevenue.toStringAsFixed(2)}',
                      sub: 'Gross sales',
                      trend: 'Live Data',
                      isPositive: true),
                  _AnalyticCard(
                      label: 'Total Orders',
                      value: '$_totalOrders',
                      sub: 'Completed',
                      trend: 'Live Data',
                      isPositive: true),
                  _AnalyticCard(
                      label: 'Avg Order Value',
                      value: '$sym${_avgOrderValue.toStringAsFixed(2)}',
                      sub: 'Per transaction',
                      trend: 'Live Data',
                      isPositive: true),
                  _AnalyticCard(
                      label: 'Active Products',
                      value: '$_activeProducts',
                      sub: 'In catalog',
                      trend: 'Live Data',
                      isPositive: true),
                ],
              );
            }),
            const SizedBox(height: 20),

            // ── Charts ────────────────────────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final chartPanel = Container(
                height: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenue & Orders Trend',
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text('Daily performance over time',
                        style: TextStyle(color: textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    const Expanded(child: _RevenueChart()),
                  ],
                ),
              );
              
              final catPanel = Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      isDark ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Revenue by Category',
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text('Sales distribution',
                        style: TextStyle(color: textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: _PieChartWidget(
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        categoryData: _categoryRevenue, // 🌟 Pass real data!
                      ),
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(children: [
                  chartPanel,
                  const SizedBox(height: 14),
                  catPanel,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: chartPanel),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: catPanel),
                ],
              );
            }),
          ]
        ],
      ),
    );
  }
}

// ── Analytic Card ─────────────────────────────────────────────────────────────
class _AnalyticCard extends StatelessWidget {
  final String label, value, sub, trend;
  final bool isPositive;

  const _AnalyticCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final bgCard = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
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
                  style: TextStyle(color: textMuted, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          Text(sub,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? const Color(0xFF22C88A) : Colors.redAccent,
                size: 13),
            const SizedBox(width: 4),
            Flexible(
                child: Text(trend,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: isPositive
                            ? const Color(0xFF22C88A)
                            : Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600))),
          ]),
        ],
      ),
    );
  }
}

// ── Live Pie Chart ─────────────────────────────────────────────────────────────────
class _PieChartWidget extends StatelessWidget {
  final Color textPrimary;
  final Color textMuted;
  final Map<String, double> categoryData; // 🌟 NOW TAKES LIVE DATA

  const _PieChartWidget({
    required this.textPrimary, 
    required this.textMuted,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    // Generate segments from live data
    List<_PieSegment> segments = [];
    final colors = [
      const Color(0xFF4B6BFB), const Color(0xFF22C88A), 
      const Color(0xFFF59E0B), const Color(0xFFEC4899),
      const Color(0xFF9B59B6), const Color(0xFFE8561A),
    ];
    
    double totalValue = categoryData.values.fold(0, (previous, val) => previous + val);

    if (totalValue == 0) {
      segments.add(const _PieSegment('No Data', 1.0, Colors.grey));
    } else {
      int colorIndex = 0;
      categoryData.forEach((key, value) {
        segments.add(_PieSegment(key, value / totalValue, colors[colorIndex % colors.length]));
        colorIndex++;
      });
    }

    return Row(children: [
      Expanded(
        flex: 5,
        child: CustomPaint(
          painter: _PieChartPainter(segments: segments),
          child: Container(),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 5,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: segments
                .map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(s.label,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(color: textPrimary, fontSize: 11))),
                        Text('${(s.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ))
                .toList(),
          ),
        ),
      ),
    ]);
  }
}

class _PieSegment {
  final String label;
  final double value;
  final Color color;
  const _PieSegment(this.label, this.value, this.color);
}

// ── Clock Dial Painter ────────────────────────────────────────────────────────
class _ClockDialPainter extends CustomPainter {
  final int hour;
  final int minute;
  final bool selectingHour;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final Color bgColor;
  final bool isDark;

  const _ClockDialPainter({
    required this.hour, required this.minute, required this.selectingHour,
    required this.accentColor, required this.textColor, required this.mutedColor,
    required this.bgColor, required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    canvas.drawCircle(center, radius, Paint()..color = bgColor);
    canvas.drawCircle(center, 5, Paint()..color = accentColor);

    final labels = selectingHour
        ? List.generate(12, (i) => '${i + 1}')
        : List.generate(12, (i) => (i * 5).toString().padLeft(2, '0'));
    final selectedIndex = selectingHour
        ? (hour % 12) - 1
        : (minute ~/ 5) % 12;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i + 1) * (2 * math.pi / 12);
      final nx = center.dx + radius * 0.72 * math.cos(angle);
      final ny = center.dy + radius * 0.72 * math.sin(angle);
      final isSelected = i == selectedIndex;
      if (isSelected) {
        canvas.drawCircle(Offset(nx, ny), 20, Paint()..color = accentColor);
        canvas.drawLine(center, Offset(nx, ny),
          Paint()..color = accentColor..strokeWidth = 2..strokeCap = StrokeCap.round);
      }
      tp.text = TextSpan(text: labels[i],
        style: TextStyle(color: isSelected ? Colors.white : textColor, fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal));
      tp.layout();
      tp.paint(canvas, Offset(nx - tp.width / 2, ny - tp.height / 2));
    }
    if (!selectingHour) {
      for (int i = 0; i < 60; i++) {
        final angle = -math.pi / 2 + i * (2 * math.pi / 60);
        final isMajor = i % 5 == 0;
        final inner = radius * (isMajor ? 0.88 : 0.92);
        final outer = radius * 0.97;
        canvas.drawLine(
          Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle)),
          Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle)),
          Paint()..color = mutedColor.withValues(alpha: isMajor ? 0.5 : 0.2)..strokeWidth = isMajor ? 2 : 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ClockDialPainter old) =>
      old.hour != hour || old.minute != minute || old.selectingHour != selectingHour;
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;
  const _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const innerRadius = 0.52;
    double startAngle = -math.pi / 2;
    const gap = 0.03;

    if (segments.length == 1 && segments[0].label == 'No Data') {
      final paint = Paint()..color = segments[0].color.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = radius * (1 - innerRadius);
      canvas.drawCircle(center, radius - (radius * (1 - innerRadius)) / 2, paint);
      return;
    }

    for (final seg in segments) {
      final sweep = seg.value * 2 * math.pi - gap;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;
      final outerRect = Rect.fromCircle(center: center, radius: radius);
      final innerRect = Rect.fromCircle(center: center, radius: radius * innerRadius);
      final path = Path()
        ..moveTo(
          center.dx + radius * innerRadius * math.cos(startAngle + gap / 2),
          center.dy + radius * innerRadius * math.sin(startAngle + gap / 2),
        )
        ..lineTo(
          center.dx + radius * math.cos(startAngle + gap / 2),
          center.dy + radius * math.sin(startAngle + gap / 2),
        );
      path.arcTo(outerRect, startAngle + gap / 2, sweep, false);
      path.arcTo(innerRect, startAngle + sweep + gap / 2, -sweep, false);
      path.close();
      canvas.drawPath(path, paint);
      startAngle += seg.value * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Revenue Chart (Placeholder for now) ───────────────────────────────────────
class _RevenueChart extends StatefulWidget {
  const _RevenueChart();

  @override
  State<_RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<_RevenueChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final barData = List.generate(30, (i) => 200 + random.nextDouble() * 600);
    final lineData = List.generate(30, (i) => 10 + random.nextDouble() * 50);
    
    return LayoutBuilder(builder: (ctx, constraints) {
      final barSpacing = constraints.maxWidth / barData.length;
      final barWidth = constraints.maxWidth / barData.length * 0.6;
      final maxBar = barData.reduce(math.max);
      final chartH = constraints.maxHeight;
      
      return MouseRegion(
        onHover: (event) {
          int? hoveredIdx;
          
          // Check if cursor is DIRECTLY over a bar
          for (int i = 0; i < barData.length; i++) {
            final barH = (barData[i] / maxBar) * chartH * 0.85;
            final x = i * barSpacing + (barSpacing - barWidth) / 2;
            final barY = chartH - barH;
            
            // Strict detection: cursor must be within bar bounds
            if (event.localPosition.dx >= x &&
                event.localPosition.dx <= x + barWidth &&
                event.localPosition.dy >= barY &&
                event.localPosition.dy <= chartH) {
              hoveredIdx = i;
              break;
            }
          }
          
          setState(() => _hoveredIndex = hoveredIdx);
        },
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              painter: _ChartPainter(barData: barData, lineData: lineData, hoveredIndex: _hoveredIndex),
              child: Container(),
            ),
            if (_hoveredIndex != null)
              Positioned(
                left: (_hoveredIndex! * barSpacing + barSpacing / 2 - 60).clamp(0, constraints.maxWidth - 120),
                top: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF2A2D3E) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white12
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Day ${_hoveredIndex! + 1}',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1D2E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revenue: \$${barData[_hoveredIndex!].toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF22C88A),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Orders: ${lineData[_hoveredIndex!].toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF4B6BFB),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> barData;
  final List<double> lineData;
  final int? hoveredIndex;
  _ChartPainter({required this.barData, required this.lineData, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final maxBar = barData.reduce(math.max);
    final maxLine = lineData.reduce(math.max);
    final linePaint = Paint()
      ..color = const Color(0xFF4B6BFB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFF4B6BFB).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = size.width / barData.length * 0.6;
    final barSpacing = size.width / barData.length;
    for (int i = 0; i < barData.length; i++) {
      final x = i * barSpacing + barSpacing * 0.2;
      final barH = (barData[i] / maxBar) * size.height * 0.85;
      final isHovered = hoveredIndex == i;
      final color = isHovered 
          ? const Color(0xFF22C88A).withValues(alpha: 0.6) 
          : const Color(0xFF22C88A);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, size.height - barH, barWidth, barH),
              const Radius.circular(3)),
          Paint()..color = color);
    }

    final linePath = Path();
    final fillPath = Path();
    for (int i = 0; i < lineData.length; i++) {
      final x = i * barSpacing + barSpacing / 2;
      final y = size.height - (lineData[i] / maxLine) * size.height * 0.85;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    final lastX = (lineData.length - 1) * barSpacing + barSpacing / 2;
    fillPath.lineTo(lastX, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Draw hovering point on line chart
    if (hoveredIndex != null && hoveredIndex! < lineData.length) {
      final x = hoveredIndex! * barSpacing + barSpacing / 2;
      final y = size.height - (lineData[hoveredIndex!] / maxLine) * size.height * 0.85;
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = const Color(0xFF4B6BFB));
      canvas.drawCircle(Offset(x, y), 8, Paint()..color = const Color(0xFF4B6BFB).withValues(alpha: 0.2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _ChartPainter) {
      return oldDelegate.hoveredIndex != hoveredIndex;
    }
    return false;
  }
}