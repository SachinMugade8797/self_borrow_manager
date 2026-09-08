import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction_entry.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<TransactionEntry> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getPendingReminders();
    if (!mounted) return;
    setState(() {
      _reminders = items;
      _loading = false;
    });
  }

  Future<void> _settle(TransactionEntry t) async {
    await DatabaseHelper.instance.settleTransaction(t.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No pending reminders 🎉", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reminders.length,
                  itemBuilder: (_, i) {
                    final t = _reminders[i];
                    final isOverdue = t.dueDate!.compareTo(today) < 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOverdue ? Colors.red.shade100 : Colors.orange.shade100,
                          child: Icon(
                            Icons.alarm,
                            color: isOverdue ? Colors.red : Colors.orange,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.clientName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              "₹${t.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: t.type == 'gave' ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.note ?? (t.type == 'gave' ? 'Gave' : 'Received')),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: isOverdue ? Colors.red : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Due: ${t.dueDate} ${isOverdue ? '(OVERDUE)' : '(Today)'}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () => _settle(t),
                          child: const Text("Settle", style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
