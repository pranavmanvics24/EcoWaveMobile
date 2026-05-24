import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final Product product;
  const ChatScreen({super.key, required this.product});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.init(user.email);
      // Room ID is a combination of product ID and buyer email (or seller if seller is viewing)
      // For simplicity, let's use product ID + buyer email
      final roomId = '${widget.product.id}_${user.email}';
      chatProvider.joinRoom(roomId);
    }
  }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final roomId = '${widget.product.id}_${user.email}';
      context.read<ChatProvider>().sendMessage(
        roomId,
        user.email,
        _msgCtrl.text.trim(),
      );
      _msgCtrl.clear();
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: ecoDark,
      appBar: AppBar(
        backgroundColor: ecoSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Seller: ${widget.product.sellerEmail}', style: TextStyle(fontSize: 12, color: ecoMuted)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                final isMe = msg.sender == user?.email;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? ecoGreen : ecoCard,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(msg.text, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          msg.createdAt.split('T').last.substring(0, 5),
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ecoSurface,
        border: Border(top: BorderSide(color: ecoBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: ecoMuted),
                filled: true,
                fillColor: ecoCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ecoGreen,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}
