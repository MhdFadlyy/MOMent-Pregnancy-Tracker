import 'package:flutter/material.dart';
import 'package:moment/screens/contraction_timer_screen.dart';
import 'chat_screen.dart';
import 'kick_counter_screen.dart';
import 'profile_screen.dart';
import 'health_logging_screen.dart';
import 'appointment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../logic/pregnancy_calculator.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

// ---------------------------------------------------------------------------
// 1. HOME SCREEN
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardTab(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. DASHBOARD TAB
// ---------------------------------------------------------------------------
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  static const _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserProfileService(user?.uid ?? '').streamProfile(),
      builder: (context, snapshot) {
        // Defaults
        int currentWeek = 1;
        int daysLeft = PregnancyCalculator.totalPregnancyDays;
        String babySize = PregnancyCalculator.babySizeForWeek(1);
        double progress = 0.0;
        bool hasDate = false;

        // Calculation
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data()!;

          if (data['due_date'] != null) {
            hasDate = true;
            final dueDate = (data['due_date'] as Timestamp).toDate();
            final result = PregnancyCalculator.fromDueDate(dueDate);

            currentWeek = result.currentWeek;
            daysLeft = result.daysLeft;
            progress = result.progress;
            babySize = result.babySize;
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text("MOMent"),
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Good Morning!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  hasDate ? "Here is your daily summary." : "Please set your due date in Profile.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // --- BABY PROGRESS CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Week $currentWeek",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        hasDate ? "Baby is the size of a $babySize" : "Tap Profile to set date",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasDate ? "$daysLeft days to go!" : "Unknown days left",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "My Tools",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // --- TOOLS GRID ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildToolCard(
                      context,
                      title: "Kick Counter",
                      icon: Icons.touch_app_rounded,
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const KickCounterScreen()));
                      },
                    ),
                    _buildToolCard(
                      context,
                      title: "Contractions",
                      icon: Icons.timer_outlined,
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ContractionTimerScreen()));
                      },
                    ),
                    _buildToolCard(
                      context,
                      title: "Health",
                      icon: Icons.favorite_border,
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthLoggingScreen()));
                      },
                    ),
                    // --- CHANGED THIS ITEM ---
                    _buildToolCard(
                      context,
                      title: "Appointments",
                      icon: Icons.calendar_month,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}