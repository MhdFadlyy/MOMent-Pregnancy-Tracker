import 'package:flutter/material.dart';
import 'dart:math';

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

    // Function to pick random answers
    String pickRandom(List<String> options) {
      return options[Random().nextInt(options.length)];
    }

    // --- GREETINGS ---
    if (input.contains("hello") || input.contains("hi") || input.contains("hey")) {
      return pickRandom([
        "Hi there! How are you and the baby feeling today?",
        "Hello! I'm here to help. What's on your mind?",
        "Assalamualaikum! How can I assist you with your pregnancy journey today?"
      ]);
    }

    // --- SYMPTOMS: HEADACHE ---
    if (input.contains("headache") || input.contains("head") || input.contains("dizzy")) {
      return pickRandom([
        "Headaches are common due to hormonal changes. Drink plenty of water and rest.",
        "Try a cold pack on your neck and rest in a dark room. If it persists, check your blood pressure.",
        "Stay hydrated! If you also have blurred vision, please contact your doctor immediately."
      ]);
    }

    // --- SYMPTOMS: NAUSEA / MORNING SICKNESS ---
    if (input.contains("nausea") || input.contains("vomit") || input.contains("sick")) {
      return pickRandom([
        "Morning sickness is tough! Try eating small, frequent meals and avoid spicy foods.",
        "Ginger tea or crackers before getting out of bed might help settle your stomach.",
        "Stay hydrated with small sips of water. If you can't keep fluids down, call your doctor."
      ]);
    }

    // --- SYMPTOMS: PAIN / CRAMPS (General) ---
    if (input.contains("pain") || input.contains("cramp") || input.contains("hurt")) {
      return "If the pain is severe or accompanied by bleeding, please go to the hospital immediately. For mild cramps, rest and hydration often help.";
    }

    // --- CRITICAL / EMERGENCY ---
    if (input.contains("bleed") || input.contains("blood") || input.contains("water broke") || input.contains("fever")) {
      return "⚠️ This could be urgent. Please contact your doctor or visit the Emergency Room (ER) immediately.";
    }

    // --- DIET & FOOD ---
    if (input.contains("diet") || input.contains("eat") || input.contains("food") || input.contains("hungry")) {
      return pickRandom([
        "Focus on folic acid, iron, and calcium. Leafy greens, nuts, and dairy are great for the baby!",
        "Try to avoid raw meat, sushi, and unpasteurized dairy. Cooked, balanced meals are best.",
        "Eating for two doesn't mean double the calories—just double the nutrients! Snack on fruits and yogurt."
      ]);
    }

    // --- BABY MOVEMENT ---
    if (input.contains("kick") || input.contains("move") || input.contains("quiet")) {
      return pickRandom([
        "You should usually feel kicks starting weeks 18-24. Use our 'Kick Counter' tool to track them!",
        "If you notice a decrease in movement, try drinking cold water and lying on your left side to see if baby wakes up.",
        "Babies sleep too! But if you are worried about reduced movement, always call your healthcare provider."
      ]);
    }

    // --- SLEEP ---
    if (input.contains("sleep") || input.contains("tired") || input.contains("insomnia")) {
      return pickRandom([
        "Fatigue is normal. Try sleeping on your left side (SOS position) with a pillow between your knees.",
        "Avoid caffeine before bed and try a warm (not hot) shower to relax.",
        "Listen to your body. If you need a nap during the day, take one!"
      ]);
    }

    // --- EMOTIONS ---
    if (input.contains("sad") || input.contains("anxious") || input.contains("scared") || input.contains("cry")) {
      return pickRandom([
        "Pregnancy is an emotional rollercoaster. It's okay to feel this way. Talk to someone you trust.",
        "Hormones can affect your mood significantly. Be kind to yourself today.",
        "If you feel overwhelmed, please speak to your doctor. Maternal mental health is just as important as physical health."
      ]);
    }

    // --- GRATITUDE / ENDING ---
    if (input.contains("thank") || input.contains("bye") || input.contains("good")) {
      return "You're very welcome! Take care of yourself and the little one. 👋";
    }

    // --- FALLBACK ANSWER ---
    return "That's a great question. Since I'm an automated assistant, I recommend asking your doctor at your next appointment.";
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