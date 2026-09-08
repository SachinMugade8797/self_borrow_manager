import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/client.dart';
import '../models/transaction_entry.dart';

class AddEntryScreen extends StatefulWidget {
  final Client? preselectedClient;
  const AddEntryScreen({super.key, this.preselectedClient});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  List<Client> _clients = [];
  Client? _selectedClient;
  String _type = 'gave'; // 'gave' or 'received'
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await DatabaseHelper.instance.getAllClients();
    if (!mounted) return;
    setState(() {
      _clients = clients;
      if (widget.preselectedClient != null && clients.isNotEmpty) {
        _selectedClient = clients.firstWhere(
          (c) => c.id == widget.preselectedClient!.id,
          orElse: () => clients.first,
        );
      }
    });
  }

  Future<void> _pickDate({bool isDue = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDue ? (_dueDate ?? DateTime.now()) : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDue) {
          _dueDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a client")),
      );
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount")),
      );
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    setState(() => _saving = true);

    final tx = TransactionEntry(
      clientId: _selectedClient!.id!,
      clientName: _selectedClient!.name,
      amount: amount,
      type: _type,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: _date.toIso8601String().substring(0, 10),
      dueDate: _dueDate?.toIso8601String().substring(0, 10),
    );

    await DatabaseHelper.instance.insertTransaction(tx);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  String _fmt(DateTime d) => "${d.day}/${d.month}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _typeBtn("gave", "↑ I Gave", Colors.red),
                  _typeBtn("received", "↓ I Received", Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<Client>(
              initialValue: _selectedClient,
              hint: const Text("Select Client"),
              decoration: InputDecoration(
                labelText: "Client",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _clients.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.name));
              }).toList(),
              onChanged: (c) => setState(() => _selectedClient = c),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Amount (₹)",
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Note (optional)",
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _dateTile("Date", _fmt(_date), () => _pickDate()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTile(
                    "Due Date",
                    _dueDate != null ? _fmt(_dueDate!) : "Optional",
                    () => _pickDate(isDue: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'gave' ? Colors.red : Colors.green,
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _type == 'gave' ? "SAVE — I GAVE ₹" : "SAVE — I RECEIVED ₹",
                        style: const TextStyle(fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String value, String label, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTile(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
