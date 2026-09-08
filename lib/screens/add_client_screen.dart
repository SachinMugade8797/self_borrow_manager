import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../models/client.dart';

class AddClientScreen extends StatefulWidget {
  final Client? existingClient;
  const AddClientScreen({super.key, this.existingClient});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.existingClient != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingClient!.name;
      _phoneController.text = widget.existingClient!.phone;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client name is required")),
      );
      return;
    }

    if (phone.isNotEmpty && phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number must be 10 digits")),
      );
      return;
    }

    setState(() => _saving = true);

    if (_isEditing) {
      final updated = widget.existingClient!.copyWith(name: name, phone: phone);
      await DatabaseHelper.instance.updateClient(updated);
    } else {
      final client = Client(
        name: name,
        phone: phone,
        createdAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertClient(client);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Client" : "Add Client"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Full Name *",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                counterText: '',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? "UPDATE CLIENT" : "SAVE CLIENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
