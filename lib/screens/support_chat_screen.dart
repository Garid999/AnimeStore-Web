import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending     = false;

  String get _uid   => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _uName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email ??
      'Хэрэглэгч';

  // Store under users/{uid}/support_messages — same collection rules apply
  CollectionReference get _msgs => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('support_messages');

  DocumentReference get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

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
    if (_uid.isEmpty) return;
    await _userDoc.set({'chat_unreadByUser': 0}, SetOptions(merge: true));
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      final now = FieldValue.serverTimestamp();
      await _msgs.add({
        'text':      text,
        'isAdmin':   false,
        'senderName': _uName,
        'createdAt': now,
      });
      await _userDoc.set({
        'chat_userName':      _uName,
        'chat_lastMessage':   text,
        'chat_lastAt':        now,
        'chat_unreadByAdmin': FieldValue.increment(1),
        'chat_unreadByUser':  0,
      }, SetOptions(merge: true));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Илгээхэд алдаа гарлаа: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary,
              child: Text('AS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anime Store Support',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Онлайн',
                    style:
                        TextStyle(fontSize: 11, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_outlined,
                    color: AppTheme.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Асуулт, санал хүсэлтээ бичнэ үү. Admin ажлын цагт хариулна.',
                    style: TextStyle(
                        color: AppTheme.primary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _msgs.snapshots(),
              builder: (_, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Алдаа: ${snap.error}',
                          style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary));
                }
                final docs = snap.data?.docs ?? [];
                docs.sort((a, b) {
                  try {
                    final at = (a.data() as Map)['createdAt'] as Timestamp?;
                    final bt = (b.data() as Map)['createdAt'] as Timestamp?;
                    if (at == null) return -1;
                    if (bt == null) return 1;
                    return at.compareTo(bt);
                  } catch (_) {
                    return 0;
                  }
                });
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: AppTheme.textSecondary.withValues(alpha: 0.3),
                            size: 56),
                        const SizedBox(height: 12),
                        const Text('Мессеж байхгүй байна',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Асуултаа доор бичнэ үү',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  );
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d     = docs[i].data() as Map<String, dynamic>;
                    final isAdmin = d['isAdmin'] as bool? ?? false;
                    final text  = d['text'] as String? ?? '';
                    final ts    = d['createdAt'] as Timestamp?;
                    final time  = ts != null
                        ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                        : '';
                    return _bubble(text, isAdmin, time);
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Мессеж бичнэ үү...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: AppTheme.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                              color: AppTheme.primary, width: 1.5)),
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
                        shape: BoxShape.circle, color: AppTheme.primary),
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
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (isAdmin)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 3),
                child: Text('Anime Store',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin ? AppTheme.surface : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdmin ? 4 : 16),
                  bottomRight: Radius.circular(isAdmin ? 16 : 4),
                ),
                border: isAdmin
                    ? Border.all(color: AppTheme.border)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(text,
                  style: TextStyle(
                      color: isAdmin ? AppTheme.textPrimary : Colors.white,
                      fontSize: 14,
                      height: 1.4)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(time,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
