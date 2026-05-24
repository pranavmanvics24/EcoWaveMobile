import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/models.dart';

class ChatProvider extends ChangeNotifier {
  late IO.Socket _socket;
  List<ChatMessage> _messages = [];
  bool _isConnected = false;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;

  void init(String userEmail) {
    // Replace with your IP if testing on real device: http://10.0.2.2:5001
    _socket = IO.io('http://10.0.2.2:5001', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build()
    );

    _socket.connect();

    _socket.onConnect((_) {
      _isConnected = true;
      notifyListeners();
    });

    _socket.on('message', (data) {
      _messages.add(ChatMessage.fromJson(data, userEmail));
      notifyListeners();
    });

    _socket.on('history', (data) {
      _messages = (data as List).map((m) => ChatMessage.fromJson(m, userEmail)).toList();
      notifyListeners();
    });
  }

  void joinRoom(String roomId) {
    _messages.clear();
    _socket.emit('join', {'room': roomId});
  }

  void sendMessage(String roomId, String sender, String text) {
    _socket.emit('message', {
      'room': roomId,
      'sender': sender,
      'text': text,
    });
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
