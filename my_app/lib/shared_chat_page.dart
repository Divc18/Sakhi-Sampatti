import 'package:flutter/material.dart';
import 'data_user.dart';


class SharedChatPage extends StatefulWidget {
  final String sessionId;
  final String displayName;
  final bool isUser;

  const SharedChatPage({
    super.key,
    required this.sessionId,
    required this.displayName,
    required this.isUser,
  });

  @override
  State<SharedChatPage> createState() => _SharedChatPageState();
}

class _SharedChatPageState extends State<SharedChatPage> {
  final TextEditingController _ctrl = TextEditingController();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {


      SessionBridge.addMessage(
        widget.sessionId,
        "${widget.isUser ? "user" : "mentor"}|$text",
      );


    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = SessionBridge.getMessages(widget.sessionId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: msgs.length,


              itemBuilder: (_, i) {
                final parts = msgs[i].split('|');
                final sender = parts[0];
                final message = parts.length > 1 ? parts[1] : parts[0];

                final isUserMessage = sender == "user";


                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.grey.shade200
                          : Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message),
                  ),
                );
              },



            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
