import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  int _kicks = 0;
  DateTime? _firstKickTime;
  DateTime? _lastKickTime;
  bool _isSaving = false;

  final User? user = FirebaseAuth.instance.currentUser;

  void _addKick() {
    setState(() {
      if (_kicks == 0) {
        _firstKickTime = DateTime.now();
      }
      _kicks++;
      _lastKickTime = DateTime.now();
    });
  }

  void _resetSession() {
    setState(() {
      _kicks = 0;
      _firstKickTime = null;
      _lastKickTime = null;
    });
  }

  Future<void> _saveSession() async {
    if (_kicks == 0 || user == null) return;

    setState(() => _isSaving = true);

    try {
      final duration = _lastKickTime!.difference(_firstKickTime!).inMinutes;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('kicks')
          .add({
        'count': _kicks,
        'duration_minutes': duration,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to Cloud!")),
        );
      }
      _resetSession();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getDuration() {
    if (_firstKickTime == null || _lastKickTime == null) return "0 min";
    final duration = _lastKickTime!.difference(_firstKickTime!);
    return "${duration.inMinutes} min ${duration.inSeconds % 60} sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Kick Counter"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Counter UI
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$_kicks",
                      style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  Text("Duration: ${_getDuration()}",
                      style:
                      const TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _addKick,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary
                          ],
                        ),
                      ),
                      child: const Center(
                          child: Icon(Icons.touch_app,
                              size: 60, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Save Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: _resetSession, child: const Text("Reset")),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSession,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white),
                    child: _isSaving
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Text("Save Session"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. REAL-TIME HISTORY LIST
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("History",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ),

          Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('kicks')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No kicks recorded yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final kickData = doc.data() as Map<String, dynamic>;
                    final date =
                        (kickData['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();

                    // SWIPE TO DELETE WIDGET
                    return Dismissible(
                      key: Key(doc.id),
                      direction:
                      DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // DELETE FROM FIREBASE
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('kicks')
                            .doc(doc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Session deleted")),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                            child: Icon(Icons.history,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          title: Text("${kickData['count']} Kicks"),
                          subtitle: Text(
                              "${kickData['duration_minutes']} minutes duration"),
                          trailing: Text(
                            "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ),
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