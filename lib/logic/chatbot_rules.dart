import 'dart:math';

/// One matchable rule: if the user's message contains any of [keywords],
/// reply with one of [responses] (picked at random for variety).
class ChatRule {
  const ChatRule({required this.keywords, required this.responses});

  final List<String> keywords;
  final List<String> responses;

  bool matches(String lowerCaseInput) =>
      keywords.any(lowerCaseInput.contains);
}

/// Offline rule-based chatbot engine: keyword -> canned advice.
/// Pure Dart, no Flutter/Firebase dependency, so it's directly unit testable
/// and new intents are added by appending to [rules] instead of editing UI code.
class ChatbotRules {
  const ChatbotRules._();

  static const String fallbackResponse =
      "That's a great question. Since I'm an automated assistant, I recommend asking your doctor at your next appointment.";

  static final List<ChatRule> rules = [
    const ChatRule(
      keywords: ["hello", "hi", "hey"],
      responses: [
        "Hi there! How are you and the baby feeling today?",
        "Hello! I'm here to help. What's on your mind?",
        "Assalamualaikum! How can I assist you with your pregnancy journey today?",
      ],
    ),
    const ChatRule(
      keywords: ["headache", "head", "dizzy"],
      responses: [
        "Headaches are common due to hormonal changes. Drink plenty of water and rest.",
        "Try a cold pack on your neck and rest in a dark room. If it persists, check your blood pressure.",
        "Stay hydrated! If you also have blurred vision, please contact your doctor immediately.",
      ],
    ),
    const ChatRule(
      keywords: ["nausea", "vomit", "sick"],
      responses: [
        "Morning sickness is tough! Try eating small, frequent meals and avoid spicy foods.",
        "Ginger tea or crackers before getting out of bed might help settle your stomach.",
        "Stay hydrated with small sips of water. If you can't keep fluids down, call your doctor.",
      ],
    ),
    const ChatRule(
      keywords: ["pain", "cramp", "hurt"],
      responses: [
        "If the pain is severe or accompanied by bleeding, please go to the hospital immediately. For mild cramps, rest and hydration often help.",
      ],
    ),
    const ChatRule(
      keywords: ["bleed", "blood", "water broke", "fever"],
      responses: [
        "⚠️ This could be urgent. Please contact your doctor or visit the Emergency Room (ER) immediately.",
      ],
    ),
    const ChatRule(
      keywords: ["diet", "eat", "food", "hungry"],
      responses: [
        "Focus on folic acid, iron, and calcium. Leafy greens, nuts, and dairy are great for the baby!",
        "Try to avoid raw meat, sushi, and unpasteurized dairy. Cooked, balanced meals are best.",
        "Eating for two doesn't mean double the calories—just double the nutrients! Snack on fruits and yogurt.",
      ],
    ),
    const ChatRule(
      keywords: ["kick", "move", "quiet"],
      responses: [
        "You should usually feel kicks starting weeks 18-24. Use our 'Kick Counter' tool to track them!",
        "If you notice a decrease in movement, try drinking cold water and lying on your left side to see if baby wakes up.",
        "Babies sleep too! But if you are worried about reduced movement, always call your healthcare provider.",
      ],
    ),
    const ChatRule(
      keywords: ["sleep", "tired", "insomnia"],
      responses: [
        "Fatigue is normal. Try sleeping on your left side (SOS position) with a pillow between your knees.",
        "Avoid caffeine before bed and try a warm (not hot) shower to relax.",
        "Listen to your body. If you need a nap during the day, take one!",
      ],
    ),
    const ChatRule(
      keywords: ["sad", "anxious", "scared", "cry"],
      responses: [
        "Pregnancy is an emotional rollercoaster. It's okay to feel this way. Talk to someone you trust.",
        "Hormones can affect your mood significantly. Be kind to yourself today.",
        "If you feel overwhelmed, please speak to your doctor. Maternal mental health is just as important as physical health.",
      ],
    ),
    const ChatRule(
      keywords: ["thank", "bye", "good"],
      responses: ["You're very welcome! Take care of yourself and the little one. 👋"],
    ),
  ];

  /// Picks a reply for [input]. Random selection is injectable via [random]
  /// so tests can make it deterministic.
  static String respond(String input, {Random? random}) {
    final lowerCaseInput = input.toLowerCase();
    for (final rule in rules) {
      if (rule.matches(lowerCaseInput)) {
        final options = rule.responses;
        return options[(random ?? Random()).nextInt(options.length)];
      }
    }
    return fallbackResponse;
  }
}
