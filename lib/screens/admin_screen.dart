import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Orders tab state
  String _filter = 'all';
  late String _revenueMonth;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _revenueMonth = _monthKey(DateTime.now());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _monthLabel(String key) {
    const names = {
      '01': '1-р сар', '02': '2-р сар', '03': '3-р сар',
      '04': '4-р сар', '05': '5-р сар', '06': '6-р сар',
      '07': '7-р сар', '08': '8-р сар', '09': '9-р сар',
      '10': '10-р сар', '11': '11-р сар', '12': '12-р сар',
    };
    final p = key.split('-');
    return p.length == 2 ? '${p[0]} оны ${names[p[1]] ?? p[1]}' : key;
  }

  void _shiftMonth(int delta) {
    final p = _revenueMonth.split('-');
    var y = int.parse(p[0]);
    var m = int.parse(p[1]) + delta;
    if (m > 12) { m = 1; y++; }
    if (m < 1)  { m = 12; y--; }
    setState(() => _revenueMonth = '$y-${m.toString().padLeft(2, '0')}');
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _p(int n) => n.toString().padLeft(2, '0');
  String _fmtDT(DateTime dt) =>
      '${dt.month}/${dt.day} ${_p(dt.hour)}:${_p(dt.minute)}';
  String _fmtDate(DateTime d) =>
      '${d.month}/${d.day}';

  DateTime _deadline(DateTime from) {
    var d = from;
    var added = 0;
    while (added < 3) {
      d = d.add(const Duration(days: 1));
      if (d.weekday != DateTime.saturday &&
          d.weekday != DateTime.sunday) added++;
    }
    return DateTime(d.year, d.month, d.day);
  }

  int _urgency(DateTime? createdAt, String status) {
    if (status == 'removed' || status == 'delivered') return 0;
    if (createdAt == null) return 0;
    final dl = _deadline(createdAt);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final diff = dl.difference(todayDate).inDays;
    if (diff < 0) return 3;
    if (diff == 0) return 2;
    if (diff <= 2) return 1;
    return 0;
  }

  String _deadlineLabel(DateTime createdAt) {
    final dl = _deadline(createdAt);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final diff = dl.difference(todayDate).inDays;
    final dlStr = _fmtDate(dl);
    if (diff < 0)  return 'Deadline: $dlStr  ⚠ ${-diff} хоног хэтэрсэн!';
    if (diff == 0) return 'Deadline: $dlStr  ⚠ Өнөөдөр хүргэх!';
    if (diff == 1) return 'Deadline: $dlStr  · Маргааш';
    return 'Deadline: $dlStr  · $diff хоног үлдсэн';
  }

  Color _urgencyColor(int u) => switch (u) {
        3 => Colors.red,
        2 => Colors.deepOrange,
        1 => Colors.orange,
        _ => Colors.transparent,
      };

  Color _statusColor(String s) => switch (s) {
        'accepted'  => Colors.green,
        'delivered' => Colors.teal,
        'removed'   => Colors.redAccent,
        _           => Colors.orange,
      };

  String _statusLabel(String s) => switch (s) {
        'accepted'  => 'Баталгаажсан',
        'delivered' => 'Хүргэгдсэн',
        'removed'   => 'Цуцлагдсан',
        _           => 'Хүлээгдэж буй',
      };

  // ─── Firestore actions ─────────────────────────────────────────────────────

  Future<void> _setStatus(String id, String status) =>
      FirebaseFirestore.instance
          .collection('orders')
          .doc(id)
          .update({'status': status});

  Future<void> _hide(String id) =>
      FirebaseFirestore.instance
          .collection('orders')
          .doc(id)
          .update({'hidden': true});

  void _confirm({
    required String title,
    required String body,
    required VoidCallback onOk,
    Color okColor = const Color(0xFFE53935),
    String okLabel = 'Тийм',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(body,
            style: const TextStyle(color: Colors.grey, height: 1.4)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Болих',
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: okColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () { Navigator.pop(ctx); onOk(); },
            child: Text(okLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded,
                color: Color(0xFFE53935), size: 22),
            SizedBox(width: 8),
            Text('Admin Panel',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Гарах',
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),
            onPressed: _signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFE53935),
          labelColor: const Color(0xFFE53935),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Захиалга'),
            Tab(icon: Icon(Icons.local_shipping_rounded, size: 18), text: 'Хүргэлт'),
            Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Хэрэглэгчид'),
            Tab(icon: Icon(Icons.chat_rounded, size: 18), text: 'Чат'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildOrdersTab(),
          _buildDeliveryTab(),
          _buildUsersTab(),
          _buildChatTab(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0 — Orders
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)));
        }
        if (snap.hasError) {
          return Center(
              child: Text('Алдаа: ${snap.error}',
                  style: const TextStyle(color: Colors.red)));
        }

        final allDocs = snap.data?.docs ?? [];
        final visible = allDocs
            .where((d) => (d.data() as Map)['hidden'] != true)
            .toList();

        // Revenue for selected month (accepted, including hidden)
        int revenue = 0;
        int revenueCount = 0;
        for (final d in allDocs) {
          final data = d.data() as Map<String, dynamic>;
          if (data['status'] == 'accepted' &&
              data['month'] == _revenueMonth) {
            revenue += (data['totalAmount'] as num?)?.toInt() ?? 0;
            revenueCount++;
          }
        }

        final filtered = _filter == 'all'
            ? visible
            : visible
                .where((d) =>
                    (d.data() as Map)['status'] == _filter)
                .toList();

        filtered.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final tsa = da['createdAt'] as Timestamp?;
          final tsb = db['createdAt'] as Timestamp?;
          final ua = _urgency(tsa?.toDate(), da['status'] ?? '');
          final ub = _urgency(tsb?.toDate(), db['status'] ?? '');
          if (ua != ub) return ub.compareTo(ua);
          if (tsa != null && tsb != null) return tsb.compareTo(tsa);
          return 0;
        });

        return Column(
          children: [
            _buildRevenueCard(revenue, revenueCount),
            _buildFilterBar(visible),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              color: Colors.grey, size: 56),
                          SizedBox(height: 12),
                          Text('Захиалга байхгүй',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _buildOrderCard(filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 — Delivery
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDeliveryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)));
        }

        final allDocs = snap.data?.docs ?? [];
        // Show accepted orders (not yet delivered, not hidden)
        final accepted = allDocs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['status'] == 'accepted' &&
              data['hidden'] != true;
        }).toList();

        if (accepted.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined,
                    color: Colors.grey, size: 64),
                SizedBox(height: 16),
                Text('Хүргэх захиалга байхгүй',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                SizedBox(height: 8),
                Text('Баталгаажсан захиалгууд энд харагдана',
                    style:
                        TextStyle(color: Color(0xFF555555), fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: accepted.length,
          itemBuilder: (_, i) => _buildDeliveryCard(accepted[i]),
        );
      },
    );
  }

  Widget _buildDeliveryCard(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final orderNum  = d['orderNumber'] as String? ?? '—';
    final phone     = d['phone'] as String? ?? '';
    final address   = d['address'] as String? ?? '';
    final total     = (d['totalAmount'] as num?)?.toInt() ?? 0;
    final items     = (d['items'] as List<dynamic>?) ?? [];
    final ts        = d['createdAt'] as Timestamp?;
    final createdAt = ts?.toDate();
    final dl        = createdAt != null ? _deadline(createdAt) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.teal.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A2A2A),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: Colors.teal, size: 18),
                const SizedBox(width: 8),
                Text(orderNum,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const Spacer(),
                if (createdAt != null)
                  Text(_fmtDT(createdAt),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deadline
                if (dl != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.teal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            color: Colors.teal, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Хүргэх огноо: ${dl.year}.${_p(dl.month)}.${_p(dl.day)}',
                          style: const TextStyle(
                              color: Colors.teal, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),

                // Contact
                _infoRow(Icons.phone_outlined, 'Утас', phone),
                const SizedBox(height: 4),
                _infoRow(Icons.location_on_outlined, 'Хаяг', address),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF2A2A2A)),
                const SizedBox(height: 6),

                // Items
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.checkroom_outlined,
                              color: Colors.grey, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis)),
                          Text(
                              '${_fmt((item['priceMNT'] as num?)?.toInt() ?? 0)}₮',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    )),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Нийт дүн',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    Text('${_fmt(total)}₮',
                        style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 14),

                // Хүргэсэн button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirm(
                      title: 'Хүргэлт баталгаажуулах',
                      body: '$orderNum захиалгыг хүргэсэн гэж тэмдэглэх үү?',
                      okColor: Colors.teal,
                      okLabel: 'Хүргэсэн',
                      onOk: () => _setStatus(doc.id, 'delivered'),
                    ),
                    icon: const Icon(Icons.done_all_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Хүргэсэн',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2 — Users
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildUsersTab() {
    // Derive all customer data directly from orders — no separate
    // `users` collection needed, so Firestore rules don't block it.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)));
        }

        final allOrders = snap.data?.docs ?? [];

        // Group by userId
        final Map<String, _CustomerInfo> customers = {};
        for (final doc in allOrders) {
          final d  = doc.data() as Map<String, dynamic>;
          final uid = d['userId'] as String? ?? '';
          if (uid.isEmpty) continue;

          final status = d['status'] as String? ?? '';
          final amount = (d['totalAmount'] as num?)?.toInt() ?? 0;
          final phone  = d['phone']   as String? ?? '';
          final addr   = d['address'] as String? ?? '';
          final ts     = (d['createdAt'] as Timestamp?)?.toDate();

          if (!customers.containsKey(uid)) {
            customers[uid] = _CustomerInfo(
              uid: uid,
              phone: phone,
              address: addr,
              lastOrderAt: ts,
            );
          }
          customers[uid]!.totalOrders++;
          if (status == 'accepted' || status == 'delivered') {
            customers[uid]!.totalSpent += amount;
          }
        }

        final list = customers.values.toList()
          ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

        if (list.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded,
                    color: Colors.grey, size: 64),
                SizedBox(height: 16),
                Text('Захиалга хийсэн хэрэглэгч байхгүй',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: Color(0xFFE53935), size: 20),
                  const SizedBox(width: 10),
                  Text('${list.length} хэрэглэгч',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildUserCard(list[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(_CustomerInfo c) {
    final displayId = 'U-${c.uid.substring(0, 6).toUpperCase()}';
    final initial   = c.phone.isNotEmpty ? c.phone[0] : '#';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial,
                  style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.phone,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(displayId,
                          style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (c.address.isNotEmpty)
                  Text(c.address,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: Colors.grey[600], size: 12),
                    const SizedBox(width: 4),
                    Text('${c.totalOrders} захиалга',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                    if (c.lastOrderAt != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded,
                          color: Colors.grey[700], size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${c.lastOrderAt!.month}/${c.lastOrderAt!.day}',
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Spending
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Нийт зарцуулсан',
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 3),
              Text('${_fmt(c.totalSpent)}₮',
                  style: TextStyle(
                      color: c.totalSpent > 0
                          ? const Color(0xFFE53935)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3 — Chat
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildChatTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('chat_lastAt', isNull: false)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.grey, size: 56),
                SizedBox(height: 12),
                Text('Чат байхгүй байна',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d           = docs[i].data() as Map<String, dynamic>;
            final userId      = docs[i].id;
            final userName    = d['chat_userName']    as String? ?? d['displayName'] as String? ?? 'Хэрэглэгч';
            final lastMsg     = d['chat_lastMessage'] as String? ?? '';
            final unread      = (d['chat_unreadByAdmin'] as num?)?.toInt() ?? 0;
            final ts          = d['chat_lastAt'] as Timestamp?;
            final time = ts != null
                ? '${ts.toDate().month}/${ts.toDate().day} ${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                : '';
            final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _AdminChatDetailScreen(
                      userId: userId, userName: userName),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unread > 0
                        ? const Color(0xFFE53935).withValues(alpha: 0.5)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              const Color(0xFFE53935).withValues(alpha: 0.15),
                          child: Text(initial,
                              style: const TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE53935)),
                              child: Center(
                                child: Text('$unread',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 3),
                          Text(lastMsg,
                              style: TextStyle(
                                  color: unread > 0
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(time,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildRevenueCard(int revenue, int count) {
    final isCurrentMonth = _revenueMonth == _monthKey(DateTime.now());
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0000), Color(0xFF2A0808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white70),
                onPressed: () => _shiftMonth(-1),
                visualDensity: VisualDensity.compact,
              ),
              Text(_monthLabel(_revenueMonth),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: isCurrentMonth
                        ? Colors.grey[700]
                        : Colors.white70),
                onPressed:
                    isCurrentMonth ? null : () => _shiftMonth(1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFFE53935), size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_fmt(revenue)}₮',
                        style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const Text('Зөвхөн баталгаажсан захиалга',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Захиалга',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<DocumentSnapshot> visible) {
    final pendingCount =
        visible.where((d) => (d.data() as Map)['status'] == 'pending').length;
    final acceptedCount =
        visible.where((d) => (d.data() as Map)['status'] == 'accepted').length;
    final removedCount =
        visible.where((d) => (d.data() as Map)['status'] == 'removed').length;

    final filters = [
      ('all',      'Бүгд',           Colors.white,      visible.length),
      ('pending',  'Хүлээгдэж буй',  Colors.orange,     pendingCount),
      ('accepted', 'Баталгаажсан',   Colors.green,      acceptedCount),
      ('removed',  'Цуцлагдсан',     Colors.redAccent,  removedCount),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final selected = _filter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _filter = f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? f.$3.withValues(alpha: 0.15)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? f.$3 : const Color(0xFF2A2A2A),
                    width: selected ? 1.5 : 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.$2,
                      style: TextStyle(
                          color: selected ? f.$3 : Colors.grey,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  if (f.$4 > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: f.$3.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${f.$4}',
                          style: TextStyle(
                              color: f.$3,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final status    = d['status'] as String? ?? 'pending';
    final orderNum  = d['orderNumber'] as String? ?? '—';
    final total     = (d['totalAmount'] as num?)?.toInt() ?? 0;
    final subtotal  = (d['subtotal'] as num?)?.toInt() ?? 0;
    final delivery  = (d['deliveryFee'] as num?)?.toInt() ?? 0;
    final items     = (d['items'] as List<dynamic>?) ?? [];
    final phone     = d['phone'] as String? ?? '';
    final address   = d['address'] as String? ?? '';
    final ts        = d['createdAt'] as Timestamp?;
    final createdAt = ts?.toDate();

    final urgency  = _urgency(createdAt, status);
    final uColor   = _urgencyColor(urgency);
    final sColor   = _statusColor(status);
    final sLabel   = _statusLabel(status);

    final borderColor = urgency > 0 && status != 'removed'
        ? uColor.withValues(alpha: 0.6)
        : sColor.withValues(alpha: 0.3);

    final cardBg = urgency == 3 && status == 'pending'
        ? const Color(0xFF1A0500)
        : urgency == 2 && status == 'pending'
            ? const Color(0xFF1A0D00)
            : const Color(0xFF1E1E1E);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Text(orderNum,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(sLabel,
                      style: TextStyle(
                          color: sColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          if (createdAt != null)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text('Ирсэн цаг: ${_fmtDT(createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ),

          if (createdAt != null && status != 'removed') ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    urgency >= 2
                        ? Icons.warning_amber_rounded
                        : Icons.local_shipping_outlined,
                    color: urgency > 0 ? uColor : Colors.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(_deadlineLabel(createdAt),
                      style: TextStyle(
                          color: urgency > 0 ? uColor : Colors.grey,
                          fontSize: 11,
                          fontWeight: urgency >= 2
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2A2A2A), height: 1),

          if (phone.isNotEmpty || address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: [
                    if (phone.isNotEmpty)
                      _infoRow(Icons.phone_outlined, 'Утас', phone),
                    if (phone.isNotEmpty && address.isNotEmpty)
                      const SizedBox(height: 6),
                    if (address.isNotEmpty)
                      _infoRow(
                          Icons.location_on_outlined, 'Хаяг', address),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Захиалсан бараа:',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                ...items.map((item) {
                  final name  = item['name'] ?? '';
                  final cat   = item['category'] ?? '';
                  final price =
                      (item['priceMNT'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.checkroom_outlined,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              cat.isNotEmpty ? '$name · $cat' : name,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text('${_fmt(price)}₮',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _priceRow('Бараа нийт', '${_fmt(subtotal)}₮',
                      Colors.white70),
                  const SizedBox(height: 4),
                  _priceRow('Хүргэлт', '+${_fmt(delivery)}₮',
                      Colors.greenAccent),
                  const Divider(color: Color(0xFF2A2A2A), height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Нийт дүн',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text('${_fmt(total)}₮',
                          style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: status == 'pending'
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          onPressed: () => _confirm(
                            title: 'Захиалга баталгаажуулах',
                            body: '$orderNum захиалгыг баталгаажуулах уу?',
                            okColor: Colors.green,
                            okLabel: 'Баталгаажуулах',
                            onOk: () => _setStatus(doc.id, 'accepted'),
                          ),
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 18),
                          label: const Text('Accept',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE53935)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          onPressed: () => _confirm(
                            title: 'Захиалга цуцлах',
                            body: '$orderNum захиалгыг цуцлах уу?',
                            onOk: () =>
                                _setStatus(doc.id, 'removed'),
                          ),
                          icon: const Icon(Icons.cancel_outlined,
                              color: Color(0xFFE53935), size: 18),
                          label: const Text('Remove',
                              style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[700]!),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _confirm(
                        title: 'Захиалга нуух',
                        body:
                            '$orderNum захиалгыг жагсаалтаас нуух уу?\n(Орлого тооцоолол хэвээр үлдэнэ)',
                        okColor: Colors.grey[700]!,
                        okLabel: 'Нуух',
                        onOk: () => _hide(doc.id),
                      ),
                      icon: Icon(Icons.visibility_off_outlined,
                          color: Colors.grey[600], size: 18),
                      label: Text('Устгах',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 14),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12))),
        ],
      );

  Widget _priceRow(String label, String value, Color vColor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(color: vColor, fontSize: 12)),
        ],
      );
}

class _CustomerInfo {
  final String uid;
  String phone;
  String address;
  DateTime? lastOrderAt;
  int totalOrders = 0;
  int totalSpent  = 0;

  _CustomerInfo({
    required this.uid,
    required this.phone,
    required this.address,
    this.lastOrderAt,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Chat Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class _AdminChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const _AdminChatDetailScreen({
    required this.userId,
    required this.userName,
  });

  @override
  State<_AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<_AdminChatDetailScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending     = false;

  CollectionReference get _msgs => FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .collection('support_messages');

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _markRead() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({'chat_unreadByAdmin': 0}, SetOptions(merge: true));
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      final now = FieldValue.serverTimestamp();
      await _msgs.add({
        'text':       text,
        'isAdmin':    true,
        'senderName': 'Anime Store',
        'createdAt':  now,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'chat_lastMessage':  text,
        'chat_lastAt':       now,
        'chat_unreadByUser': FieldValue.increment(1),
      }, SetOptions(merge: true));
      _scrollToBottom();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE53935).withValues(alpha: 0.15),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.userName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _msgs.snapshots(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFE53935)));
                }
                final docs = snap.data?.docs ?? [];
                docs.sort((a, b) {
                  final at = (a.data() as Map)['createdAt'] as Timestamp?;
                  final bt = (b.data() as Map)['createdAt'] as Timestamp?;
                  if (at == null) return -1;
                  if (bt == null) return 1;
                  return at.compareTo(bt);
                });
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Мессеж байхгүй',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d       = docs[i].data() as Map<String, dynamic>;
                    final isAdmin = d['isAdmin'] as bool? ?? false;
                    final text    = d['text'] as String? ?? '';
                    final ts      = d['createdAt'] as Timestamp?;
                    final time = ts != null
                        ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                        : '';
                    return _bubble(text, isAdmin, time);
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Хариулт бичнэ үү...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE53935)),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String text, bool isAdmin, String time) {
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin
                    ? const Color(0xFFE53935)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                  bottomRight: Radius.circular(isAdmin ? 4 : 16),
                ),
              ),
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(time,
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
