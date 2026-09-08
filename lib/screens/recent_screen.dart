import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaction_entry.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<TransactionEntry> _txns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DatabaseHelper.instance.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _txns = txns;
      _loading = false;
    });
  }

  Future<void> _settle(TransactionEntry t) async {
    await DatabaseHelper.instance.settleTransaction(t.id!);
    _load();
  }

  Future<void> _delete(TransactionEntry t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteTransaction(t.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent Transactions")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _txns.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No transactions yet", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _txns.length,
                  itemBuilder: (_, i) {
                    final t = _txns[i];
                    final isGave = t.type == 'gave';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isGave
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          child: Icon(
                            isGave ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isGave ? Colors.red : Colors.green,
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
                              "${isGave ? '-' : '+'}₹${t.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: isGave ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                decoration: t.isSettled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${t.note ?? (isGave ? 'Gave' : 'Received')} • ${t.date}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            if (t.isSettled)
                              const Chip(
                                label: Text("Settled", style: TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            if (!t.isSettled)
                              const PopupMenuItem(value: 'settle', child: Text("Mark Settled")),
                            const PopupMenuItem(value: 'delete', child: Text("Delete")),
                          ],
                          onSelected: (v) {
                            if (v == 'settle') _settle(t);
                            if (v == 'delete') _delete(t);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
