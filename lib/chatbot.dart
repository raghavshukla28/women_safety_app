import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Femina Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFf6f6f6),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
      ),
      home: const ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final Map<String, List<String>> categories = {
    "Health": [
      "Nutrition",
      "Mental Health",
      "Physical Fitness",
      "Stress Management",
      "Diet Plans",
      "Sleep Hygiene",
      "Hydration",
      "Vitamins and Supplements",
      "Mental Well-being",
      "Healthy Habits"
    ],
    "Safety": [
      "Being Followed",
      "Being Chased",
      "Being Attacked",
      "Personal Security",
      "Safety Tips",
      "Emergency Contact",
      "Home Safety",
      "Online Safety",
      "Travel Safety",
      "Self-Protection"
    ],
    "Self-Defense": [
      "Basic Self-Defense",
      "Weapons for Self-Defense",
      "Self-Defense Tips",
      "Pepper Spray",
      "Stun Guns",
      "Martial Arts",
      "Escape Techniques",
      "Verbal Defense",
      "Body Language for Defense",
      "Situational Awareness"
    ],
    "Tools": [
      "Emergency Kit",
      "Self-Defense Tools",
      "First Aid Kit",
      "Safety Gadgets",
      "Survival Tools",
      "Personal Alarm",
      "Flashlights",
      "Tactical Gear",
      "GPS Locator",
      "Medical Supplies"
    ],
    "Emergency": [
      "How to Call 911",
      "CPR Instructions",
      "Burn Treatment",
      "Bleeding Control",
      "Fracture Care",
      "Shock Symptoms",
      "Heart Attack Symptoms",
      "Choking Assistance",
      "Poisoning Response",
      "Emergency Kits"
    ],
  };

  final Map<String, List<String>> subCategoryReplies = {
    "Nutrition": [
      "Eating a balanced diet rich in fruits, vegetables, lean protein, and whole grains is essential for good health.",
      "A healthy diet should include a variety of nutrients like vitamins, minerals, fiber, and healthy fats.",
      "It's important to monitor your calorie intake and make sure you're getting enough nutrients for your body.",
      "Drink plenty of water daily and try to limit sugary beverages.",
      "Incorporating more plant-based foods into your meals can provide numerous health benefits."
    ],
    "Mental Health": [
      "Mental health is just as important as physical health. Taking time for self-care can boost your well-being.",
      "Regular meditation and mindfulness practices are great ways to manage stress and anxiety.",
      "Talking to a counselor or therapist can provide support for managing mental health challenges.",
      "Exercise can help improve your mental health by releasing endorphins, which make you feel good.",
      "Building a support system and talking with loved ones can help you navigate difficult mental health situations."
    ],
    "Being Followed": [
      "If you think you're being followed, remain calm and try to get to a public place.",
      "Avoid isolated areas, and try to make eye contact with others to ensure you're noticed.",
      "Consider changing your route and taking an alternative path to see if the person is still following you.",
      "If you're feeling unsafe, consider calling a friend or family member and let them know where you are.",
      "Trust your instincts—if something feels off, don't hesitate to call authorities."
    ],
    "Basic Self-Defense": [
      "Always be aware of your surroundings and trust your instincts if something feels wrong.",
      "Learn and practice basic defensive stances and movements to protect yourself.",
      "Target vulnerable areas like eyes, throat, and groin if you need to defend yourself.",
      "Use your voice - yell 'Fire!' or 'Help!' to attract attention in dangerous situations.",
      "Remember that running away is often the best form of self-defense when possible."
    ],
    "Emergency Contact": [
      "Keep emergency contact numbers easily accessible on your phone and written down.",
      "Share your location with trusted friends or family members when traveling alone.",
      "Consider using safety apps that can quickly alert emergency contacts of your location.",
      "Program ICE (In Case of Emergency) contacts in your phone.",
      "Create a code word with trusted friends/family to signal when you're in trouble."
    ],
    "Personal Security": [
      "Always lock your doors and windows, both at home and in your car.",
      "Install good lighting around your home, especially near entrances.",
      "Avoid sharing your location on social media in real-time.",
      "Keep your phone charged and carry a portable charger when possible.",
      "Consider taking a self-defense class to build confidence and skills."
    ],
    "Safety Tips": [
      "Walk confidently and stay alert in public places.",
      "Avoid wearing headphones or being distracted by your phone while walking alone.",
      "Park in well-lit areas and have your keys ready before reaching your car.",
      "Vary your routine so it's not predictable to others.",
      "Trust your gut feeling - if something feels wrong, leave the situation."
    ],
    "First Aid Kit": [
      "Keep a well-stocked first aid kit in your home, car, and workplace.",
      "Include bandages, antiseptic wipes, gauze, scissors, and medical tape.",
      "Check expiration dates regularly and replace items as needed.",
      "Add any personal medications or specific items you might need.",
      "Know how to use everything in your first aid kit properly."
    ],
    "Physical Fitness": [
      "Regular exercise helps build strength and confidence for self-defense.",
      "Include both cardio and strength training in your fitness routine.",
      "Practice exercises that improve balance and coordination.",
      "Stay consistent with your workout schedule for best results.",
      "Consider joining group fitness classes for motivation and safety."
    ],
    "Stress Management": [
      "Practice deep breathing exercises when feeling overwhelmed.",
      "Maintain a regular sleep schedule to help manage stress levels.",
      "Try progressive muscle relaxation techniques for stress relief.",
      "Take regular breaks during work to prevent burnout.",
      "Find healthy ways to cope with stress, like exercise or hobbies."
    ],
    "Diet Plans": [
      "Start with a balanced meal plan including proteins, carbs, and healthy fats in each meal.",
      "Consider portion control - use smaller plates and measure servings when starting out.",
      "Plan your meals ahead of time and prep ingredients for the week on weekends.",
      "Include at least 5 servings of fruits and vegetables in your daily diet plan.",
      "Stay flexible with your diet plan - allow occasional treats to maintain sustainability."
    ],
    "Sleep Hygiene": [
      "Maintain a consistent sleep schedule, even on weekends.",
      "Create a relaxing bedtime routine - try reading, gentle stretching, or meditation.",
      "Keep your bedroom cool, dark, and quiet for optimal sleep.",
      "Avoid screens and bright lights at least 1 hour before bedtime.",
      "Limit caffeine and heavy meals close to bedtime for better sleep quality."
    ],
    "Hydration": [
      "Aim to drink 8-10 glasses of water daily, more if exercising.",
      "Set reminders to drink water throughout the day.",
      "Monitor your urine color - pale yellow indicates good hydration.",
      "Eat water-rich foods like cucumbers, watermelon, and citrus fruits.",
      "Carry a reusable water bottle to track your daily intake."
    ],
    "Vitamins and Supplements": [
      "Consult with a healthcare provider before starting any supplement routine.",
      "Consider vitamin D supplements if you get limited sun exposure.",
      "Iron supplements may be needed if you follow a vegetarian/vegan diet.",
      "Take calcium with vitamin D for better absorption.",
      "Store supplements properly and check expiration dates regularly."
    ],
    "Being Chased": [
      "Run towards populated areas or businesses that are open.",
      "Call emergency services while running if possible.",
      "Make noise to attract attention - scream, use a personal alarm, or yell 'Fire!'",
      "Look for police stations, fire stations, or other safe public buildings.",
      "If you can't outrun them, prepare to defend yourself and continue calling for help."
    ],
    "Being Attacked": [
      "Focus on getting away rather than winning a fight - your safety is priority.",
      "Use your voice - yell loudly to attract attention and disorient the attacker.",
      "Strike vulnerable areas: eyes, throat, groin, or knees to create an escape opportunity.",
      "If grabbed, remember the mantra 'SING': Solar plexus, Instep, Nose, Groin.",
      "Once you break free, run to a safe location and call emergency services immediately."
    ],
    "Online Safety": [
      "Use strong, unique passwords for all accounts and enable two-factor authentication.",
      "Be cautious about sharing personal information on social media.",
      "Don't accept friend requests or messages from unknown persons.",
      "Regularly update your privacy settings on social media platforms.",
      "Be careful when using public WiFi - avoid accessing sensitive information."
    ],
    "Travel Safety": [
      "Research your destination thoroughly before traveling.",
      "Share your itinerary with trusted friends or family members.",
      "Keep important documents and emergency contacts easily accessible.",
      "Stay aware of your surroundings and trust your instincts.",
      "Use reputable transportation services and avoid traveling alone at night."
    ],
    "Self-Protection": [
      "Stay aware of your surroundings and avoid distractions like headphones.",
      "Walk confidently and make eye contact with people around you.",
      "Keep your phone charged and easily accessible for emergencies.",
      "Consider carrying legal self-defense tools like personal alarms.",
      "Know the emergency numbers and safe locations in your area."
    ],
    "Martial Arts": [
      "Consider taking classes in practical self-defense styles like Krav Maga.",
      "Focus on techniques that work regardless of size or strength differences.",
      "Practice regularly to build muscle memory for emergency situations.",
      "Learn both defensive moves and escape techniques.",
      "Find a reputable instructor who emphasizes real-world application."
    ],
    "Escape Techniques": [
      "Practice breaking common holds and grabs.",
      "Learn to identify and move toward exits in any situation.",
      "Master basic moves like wrist breaks and bear hug escapes.",
      "Remember to use your whole body weight, not just arm strength.",
      "Practice quick directional changes to throw off pursuers."
    ],
    "How to Call 911": [
      "Stay calm and speak clearly when calling emergency services.",
      "Provide your exact location first - this is crucial if the call drops.",
      "Briefly describe the emergency and follow the dispatcher's instructions.",
      "Don't hang up until told to do so by the dispatcher.",
      "If possible, stay on the line while help arrives."
    ],
    "CPR Instructions": [
      "Check the scene for safety and the person for responsiveness.",
      "Call 911 or have someone else call immediately.",
      "Begin chest compressions - push hard and fast in the center of the chest.",
      "Allow complete chest recoil between compressions.",
      "Continue CPR until professional help arrives or the person shows signs of life."
    ],
    "Fracture Care": [
      "Immobilize the injured area to prevent further damage.",
      "Apply ice packs wrapped in cloth to reduce swelling.",
      "Seek immediate medical attention, especially for severe pain or visible deformity.",
      "Don't try to realign or push a bone back in place.",
      "Keep the injured area elevated above heart level if possible."
    ],
    "Emergency Kits": [
      "Include basic first aid supplies, flashlight, and emergency contact information.",
      "Pack necessary medications and copies of important documents.",
      "Add non-perishable food, water, and a battery-powered radio.",
      "Include a multi-tool, emergency blanket, and spare phone charger.",
      "Check and update your kit every six months."
    ],
    "Self-Defense Tools": [
      "Carry legal self-defense tools that you're trained to use properly.",
      "Consider a personal alarm or whistle for attracting attention.",
      "Keep tools easily accessible but secure.",
      "Research local laws regarding self-defense tools in your area.",
      "Practice drawing and using your tools quickly in various situations."
    ],
    "Safety Gadgets": [
      "Use personal safety apps that can track your location.",
      "Consider wearable devices with emergency alert features.",
      "Install security cameras or doorbell cameras at home.",
      "Use timer switches for lights when away from home.",
      "Keep a portable phone charger for emergency situations."
    ]
  };

  List<ChatMessage> messages = [];
  Map<String, bool> expandedCategories = {};

  @override
  void initState() {
    super.initState();
    messages.add(
      ChatMessage(
        text: "Hello! I'm here to help. Please select a topic to get started.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _getRandomResponse(String prompt) {
    if (subCategoryReplies.containsKey(prompt)) {
      final random = Random();
      List<String> responses = subCategoryReplies[prompt]!;
      return responses[random.nextInt(responses.length)];
    }
    return "I can provide information about $prompt. What specific aspect would you like to know more about?";
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

  void _handleUserSelection(String prompt) {
    setState(() {
      messages.add(
        ChatMessage(
          text: prompt,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          messages.add(
            ChatMessage(
              text: _getRandomResponse(prompt),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _scrollToBottom();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Femina Chatbot',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                String category = categories.keys.elementAt(index);
                return _buildCategoryChip(category);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isExpanded = expandedCategories[category] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionChip(
            label: Text(
              category,
              style: TextStyle(
                color: isExpanded ? Colors.white : Colors.black87,
              ),
            ),
            backgroundColor: isExpanded ? Colors.blue : Colors.grey[200],
            onPressed: () {
              setState(() {
                expandedCategories[category] = !isExpanded;
              });
              _showSubcategories(category);
            },
          ),
        ],
      ),
    );
  }

  void _showSubcategories(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories[category]?.length ?? 0,
                  itemBuilder: (context, index) {
                    String subcategory = categories[category]![index];
                    return ListTile(
                      title: Text(subcategory),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _handleUserSelection(subcategory);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}