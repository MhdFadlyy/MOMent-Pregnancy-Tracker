import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() => _ContractionTimerScreenState();
}

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  // Logic Variables
  bool _isActive = false;
  DateTime? _startTime;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // Display String (00:00)
  String _formattedTime = "00:00";

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- TIMER LOGIC ---
  void _toggleTimer() {
    setState(() {
      if (_isActive) {
        // STOPPING
        _stopSession();
      } else {
        // STARTING
        _isActive = true;
        _startTime = DateTime.now();
        _stopwatch.reset();
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _formattedTime = _formatDuration(_stopwatch.elapsed);
          });
        });
      }
    });
  }

  void _stopSession() async {
    _stopwatch.stop();
    _timer?.cancel();

    // Save data before resetting
    final durationSeconds = _stopwatch.elapsed.inSeconds;
    final startTimeToSave = _startTime;

    setState(() {
      _isActive = false;
      _formattedTime = "00:00";
    });

    if (durationSeconds < 5) {
      // Ignore accidental taps (too short)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ignored (too short)")),
      );
      return;
    }

    // SAVE TO FIREBASE
    if (user != null && startTimeToSave != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('contractions')
          .add({
        'start_time': startTimeToSave,
        'duration_seconds': durationSeconds,
        'timestamp': FieldValue.serverTimestamp(), // For sorting
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraction recorded!")),
      );
    }
  }

  // Helper to format 65 seconds -> "01:05"
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Contraction Timer"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. THE BIG TIMER AREA
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isActive ? "Active Contraction" : "Ready to track",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isActive ? Colors.redAccent : Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 40),

                  // The Button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isActive
                            ? Colors.redAccent
                            : Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (_isActive ? Colors.red : Colors.purple)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isActive ? Icons.stop : Icons.play_arrow,
                            size: 60,
                            color: Colors.white,
                          ),
                          Text(
                            _isActive ? "STOP" : "START",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. THE HISTORY LIST
          Expanded(
            flex: 3,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('contractions')
                  .orderBy('start_time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No contractions recorded yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final startTime =
                    (data['start_time'] as Timestamp).toDate();
                    final durationSec = data['duration_seconds'] as int;

                    // Frequency Calculation
                    String frequencyText = "--";
                    if (index < docs.length - 1) {
                      final nextData =
                      docs[index + 1].data() as Map<String, dynamic>;
                      final prevStartTime =
                      (nextData['start_time'] as Timestamp).toDate();
                      final diff = startTime.difference(prevStartTime);
                      frequencyText =
                      "${diff.inMinutes}m ${diff.inSeconds % 60}s";
                    }

                    // How Delete Widget 101
                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // DELETE FROM FIREBASE
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('contractions')
                            .doc(doc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Entry deleted")),
                        );
                      },
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              "${startTime.day}/${startTime.month}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Duration",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                    Text(
                                      "${(durationSec / 60).floor()}m ${durationSec % 60}s",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Freq",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                    Text(
                                      frequencyText,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}