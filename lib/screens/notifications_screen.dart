import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderNotif  = true;
  bool _promoNotif  = false;
  bool _newsNotif   = false;
  bool _isLoading   = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orderNotif = prefs.getBool('notif_order') ?? true;
      _promoNotif = prefs.getBool('notif_promo') ?? false;
      _newsNotif  = prefs.getBool('notif_news')  ?? false;
      _isLoading  = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_order', _orderNotif);
    await prefs.setBool('notif_promo', _promoNotif);
    await prefs.setBool('notif_news',  _newsNotif);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Тохиргоо хадгалагдлаа'),
          backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Мэдэгдлийн тохиргоо')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.notifications_outlined,
                            color: AppTheme.primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Мэдэгдлүүдийг хянаж удирдаарай',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _toggleCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Захиалгын мэдэгдэл',
                    subtitle: 'Захиалга батлагдах, хүргэгдэх үед мэдэгдэл авах',
                    value: _orderNotif,
                    onChanged: (v) {
                      setState(() => _orderNotif = v);
                      _save();
                    },
                  ),

                  _toggleCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Урамшуулал & Хямдрал',
                    subtitle: 'Тусгай санал, хямдралын мэдэгдэл авах',
                    value: _promoNotif,
                    onChanged: (v) {
                      setState(() => _promoNotif = v);
                      _save();
                    },
                  ),

                  _toggleCard(
                    icon: Icons.newspaper_outlined,
                    title: 'Шинэ бараа',
                    subtitle: 'Шинэ аниме бараа нэмэгдэх үед мэдэгдэл авах',
                    value: _newsNotif,
                    onChanged: (v) {
                      setState(() => _newsNotif = v);
                      _save();
                    },
                  ),

                  const SizedBox(height: 16),

                  // All off button
                  if (_orderNotif || _promoNotif || _newsNotif)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _orderNotif = false;
                          _promoNotif = false;
                          _newsNotif  = false;
                        });
                        _save();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Center(
                          child: Text('Бүх мэдэгдэл унтраах',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _toggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: value ? AppTheme.primary : AppTheme.textSecondary,
                size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: value
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
