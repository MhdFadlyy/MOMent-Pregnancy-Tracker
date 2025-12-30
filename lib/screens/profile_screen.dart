import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  User? user;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. FETCH DATA
  Future<void> _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            if (data['due_date'] != null) {
              _selectedDate = (data['due_date'] as Timestamp).toDate();
            }
          });
        }
      } catch (e) {
        print("Error loading profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  // 2. SAVE DATA
  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'due_date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'email': user!.email,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => _isEditing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. LOGOUT
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  // 4. DELETE ACCOUNT
  Future<void> _deleteAccount() async {
    // A. Show Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This will permanently delete your data (Kicks, Health logs, Profile). This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete Permanently"),
          ),
        ],
      ),
    );

    if (confirm != true || user == null) return;

    setState(() => _isLoading = true);

    try {
      // B. Delete Data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();

      // C. Delete User from Authentication
      await user!.delete();

      // D. Navigate to Login
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deleted.")));
      }
    } on FirebaseAuthException catch (e) {
      // Security Check: If user hasn't logged in recently, Firebase requires re-login
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log out and log in again to perform this sensitive action.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime initial = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) _saveProfile();
              else setState(() => _isEditing = true);
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
                  ),
                  if (_isEditing)
                    Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, backgroundColor: Theme.of(context).colorScheme.primary, child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(user?.email ?? "No Email", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),

            // Fields
            TextField(controller: _nameController, enabled: _isEditing, decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _ageController, enabled: _isEditing, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Age", prefixIcon: Icon(Icons.cake_outlined), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isEditing ? _pickDate : null,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: _selectedDate == null ? "Not set" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: "Baby's Due Date", prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            if (!_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.black, side: const BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 20),

              // DELETE ACCOUNT BUTTON
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(Icons.delete_forever, size: 20),
                  label: const Text("Delete Account"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}