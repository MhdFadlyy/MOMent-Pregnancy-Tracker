import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers for the Dialog
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // --- SHOW ADD/EDIT DIALOG ---
  void _showAppointmentDialog({DocumentSnapshot? doc}) {
    // Reset or Pre-fill data
    if (doc != null) {
      // EDIT MODE
      final data = doc.data() as Map<String, dynamic>;
      _titleController.text = data['title'];
      _doctorController.text = data['doctor'] ?? '';
      final timestamp = data['date'] as Timestamp;
      final fullDate = timestamp.toDate();
      _selectedDate = fullDate;
      _selectedTime = TimeOfDay.fromDateTime(fullDate);
    } else {
      // ADD MODE
      _titleController.clear();
      _doctorController.clear();
      _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default tomorrow
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(doc == null ? "Add Appointment" : "Edit Appointment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Purpose (e.g. Ultrasound)", prefixIcon: Icon(Icons.event_note)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _doctorController,
                      decoration: const InputDecoration(labelText: "Doctor / Clinic", prefixIcon: Icon(Icons.local_hospital)),
                    ),
                    const SizedBox(height: 20),

                    // Date Picker
                    ListTile(
                      title: Text(_selectedDate == null
                          ? "Pick Date"
                          : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!)),
                      leading: const Icon(Icons.calendar_today, color: Colors.purple),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDate = picked);
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.grey)),
                    ),
                    const SizedBox(height: 10),

                    // Time Picker
                    ListTile(
                      title: Text(_selectedTime == null
                          ? "Pick Time"
                          : _selectedTime!.format(context)),
                      leading: const Icon(Icons.access_time, color: Colors.purple),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedTime = picked);
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty || _selectedDate == null || _selectedTime == null) return;

                    // Combine Date and Time
                    final DateTime finalDateTime = DateTime(
                      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                      _selectedTime!.hour, _selectedTime!.minute,
                    );

                    final Map<String, dynamic> data = {
                      'title': _titleController.text.trim(),
                      'doctor': _doctorController.text.trim(),
                      'date': Timestamp.fromDate(finalDateTime),
                    };

                    if (doc == null) {
                      // Create New
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('appointments')
                          .add(data);
                    } else {
                      // Update Existing
                      await doc.reference.update(data);
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAppointmentDialog(),
        label: const Text("Add Visit"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('appointments')
            .orderBy('date', descending: false) // Upcoming first
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No upcoming visits.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  doc.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment deleted")));
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('MMM').format(date).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
                          Text(date.day.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                        ],
                      ),
                    ),
                    title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(DateFormat('h:mm a').format(date)),
                        ]),
                        if (data['doctor'] != '') ...[
                          const SizedBox(height: 4),
                          Text("Dr. ${data['doctor']}", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ]
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _showAppointmentDialog(doc: doc),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}