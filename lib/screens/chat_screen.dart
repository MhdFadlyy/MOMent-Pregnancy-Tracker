import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Initial Welcome Message
  final List<Map<String, String>> _messages = [
    {
      "sender": "bot",
      "text": "Hello Mom! I'm MOMent. Ask me about your symptoms, diet, or baby's growth."
    }
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    String userText = _controller.text;

    // 1. Add User Message
    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // 2. Simulating a short delay so it feels like a real chat
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      String botResponse = _getLocalResponse(userText);

      setState(() {
        _isTyping = false;
        _messages.add({"sender": "bot", "text": botResponse});
      });
      _scrollToBottom();
    });
  }

  // Responses
  String _getLocalResponse(String input) {
    input = input.toLowerCase();

    if (input.contains("hello") || input.contains("hi")) {
      return "Hi there! How are you feeling today?";
    }
    if (input.contains("headache") || input.contains("head")) {
      return "Headaches are common due to hormonal changes. Drink plenty of water and rest. If it's severe, consult your doctor.";
    }
    if (input.contains("diet") || input.contains("eat") || input.contains("food") || input.contains("hungry")) {
      return "Focus on a balanced diet rich in folic acid, iron, and calcium. Leafy greens, nuts, and dairy are great for the baby!";
    }
    if (input.contains("pain") || input.contains("cramp") || input.contains("hurt")) {
      return "If you feel severe pain or cramping, please visit a hospital immediately. Better safe than sorry!";
    }
    if (input.contains("baby") || input.contains("size") || input.contains("growth")) {
      return "Your baby is growing every day! Check the Home Dashboard for this week's size updates.";
    }
    if (input.contains("kick") || input.contains("move")) {
      return "You should start feeling kicks around week 18-24. Use our 'Kick Counter' tool to track them!";
    }
    if (input.contains("sleep") || input.contains("tired")) {
      return "Fatigue is normal. Try to sleep on your side (SOS position) with a pillow between your legs for better comfort.";
    }

    // Fallback answer
    return "That's a great question. Since I'm an automated assistant, I recommend noting this down to ask your doctor at your next visit.";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask MOMent"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("MOMent is typing...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}