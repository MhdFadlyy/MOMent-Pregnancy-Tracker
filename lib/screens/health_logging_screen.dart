import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// PDF Imports
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HealthLoggingScreen extends StatefulWidget {
  const HealthLoggingScreen({super.key});

  @override
  State<HealthLoggingScreen> createState() => _HealthLoggingScreenState();
}

class _HealthLoggingScreenState extends State<HealthLoggingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? user = FirebaseAuth.instance.currentUser;

  // -- CONTROLLERS --
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  String _selectedMeal = "Breakfast";
  final List<String> _mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // --- 1. PDF GENERATION LOGIC ---
  Future<void> _printHealthData() async {
    if (user == null) return;

    // Show loading indicator
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      // A. Fetch Data from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('health_logs')
          .orderBy('timestamp', descending: true)
          .get();

      final docs = querySnapshot.docs;

      // B. Create PDF Document
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.openSansRegular();
      final fontBold = await PdfGoogleFonts.openSansBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("MOMent Health Report", style: pw.TextStyle(font: fontBold, fontSize: 24)),
                    pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now()), style: pw.TextStyle(font: font, fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table.fromTextArray(
                border: null,
                headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                },
                headers: ['Date & Time', 'Type', 'Details'],
                data: docs.map((doc) {
                  final data = doc.data();
                  final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final dateStr = DateFormat('MM-dd HH:mm').format(date);
                  final type = (data['type'] ?? 'General').toString().toUpperCase();

                  String details = "";
                  if (data['type'] == 'weight') {
                    details = "${data['value']} kg";
                  } else if (data['type'] == 'diet') {
                    details = "${data['meal_type']}: ${data['description']}";
                  } else {
                    details = "${data['description']} (${data['duration_mins']} mins)";
                  }

                  return [dateStr, type, details];
                }).toList(),
              ),
            ];
          },
        ),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // C. Open Print Dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'MOMent_Health_Report_${DateTime.now().millisecondsSinceEpoch}',
      );

    } catch (e) {
      if (mounted) Navigator.pop(context); // If error = close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
    }
  }

  // --- SAVE LOGIC ---
  Future<void> _saveLog() async {
    if (user == null) return;

    String type = "";
    Map<String, dynamic> data = {'timestamp': FieldValue.serverTimestamp()};

    if (_tabController.index == 0) {
      if (_weightController.text.isEmpty) return;
      type = "weight";
      data['value'] = double.tryParse(_weightController.text) ?? 0.0;
    } else if (_tabController.index == 1) {
      if (_foodController.text.isEmpty) return;
      type = "diet";
      data['description'] = _foodController.text;
      data['meal_type'] = _selectedMeal;
    } else {
      if (_activityController.text.isEmpty) return;
      type = "exercise";
      data['description'] = _activityController.text;
      data['duration_mins'] = int.tryParse(_durationController.text) ?? 0;
    }
    data['type'] = type;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('health_logs').add(data);
      _weightController.clear(); _foodController.clear(); _activityController.clear(); _durationController.clear();
      FocusScope.of(context).unfocus();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$type log added!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Health & Wellness"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // PRINT BUTTON
          TextButton.icon(
            onPressed: _printHealthData,
            icon: const Icon(Icons.print, size: 20),
            label: const Text("Report"),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight), text: "Weight"),
            Tab(icon: Icon(Icons.restaurant), text: "Diet"),
            Tab(icon: Icon(Icons.fitness_center), text: "Exercise"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. INPUT FORM
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            height: 220,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // WEIGHT
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Current Weight (kg)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.scale)),
                          ),
                        ],
                      ),
                      // DIET
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedMeal,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                            items: _mealTypes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (val) => setState(() => _selectedMeal = val!),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _foodController,
                            decoration: const InputDecoration(labelText: "What did you eat?", border: OutlineInputBorder(), prefixIcon: Icon(Icons.fastfood)),
                          ),
                        ],
                      ),
                      // EXERCISE
                      Row(
                        children: [
                          Expanded(flex: 2, child: TextField(controller: _activityController, decoration: const InputDecoration(labelText: "Activity", border: OutlineInputBorder()))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mins", border: OutlineInputBorder()))),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveLog,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                    child: _isSaving ? const Text("Saving...") : const Text("Log Entry"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. HISTORY LIST
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('health_logs').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("No logs yet."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] ?? 'unknown';
                    final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final formattedDate = "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2,'0')}";

                    IconData icon; Color color; String title; String subtitle;
                    if (type == 'weight') { icon = Icons.monitor_weight; color = Colors.blue; title = "${data['value']} kg"; subtitle = "Weight Logged"; }
                    else if (type == 'diet') { icon = Icons.restaurant; color = Colors.green; title = "${data['meal_type']}: ${data['description']}"; subtitle = "Diet Logged"; }
                    else { icon = Icons.fitness_center; color = Colors.orange; title = "${data['description']} (${data['duration_mins']} mins)"; subtitle = "Exercise Logged"; }

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) { doc.reference.delete(); },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$subtitle • $formattedDate"),
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