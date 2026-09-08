import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/client.dart';
import '../models/transaction_entry.dart';
import 'add_client_screen.dart';
import 'add_entry_screen.dart';

class ManageClientsScreen extends StatefulWidget {
  const ManageClientsScreen({super.key});

  @override
  State<ManageClientsScreen> createState() => _ManageClientsScreenState();
}

class _ManageClientsScreenState extends State<ManageClientsScreen> {
  List<Client> _clients = [];
  bool _loading = true;

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
      _loading = false;
    });
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Client"),
        content: Text("Delete ${client.name}? All their transactions will also be deleted."),
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
      await DatabaseHelper.instance.deleteClient(client.id!);
      _loadClients();
    }
  }

  Future<Map<String, double>> _getClientBalance(int clientId) async {
    final txns = await DatabaseHelper.instance.getTransactionsByClient(clientId);
    double gave = 0, received = 0;
    for (var t in txns) {
      if (t.isSettled) continue;
      if (t.type == 'gave') {
        gave += t.amount;
      } else {
        received += t.amount;
      }
    }
    return {'gave': gave, 'received': received, 'balance': gave - received};
  }

  void _openClientDetail(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)),
    ).then((_) => _loadClients());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No clients yet", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _clients.length,
                  itemBuilder: (_, i) {
                    final client = _clients[i];
                    return FutureBuilder<Map<String, double>>(
                      future: _getClientBalance(client.id!),
                      builder: (_, snap) {
                        final balance = snap.data?['balance'] ?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.15),
                              child: Text(
                                client.name[0].toUpperCase(),
                                style: const TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(client.phone.isEmpty ? "No phone" : client.phone),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${balance.abs().toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: balance > 0 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  balance > 0 ? "owes you" : balance < 0 ? "you owe" : "settled",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () => _openClientDetail(client),
                            onLongPress: () => _deleteClient(client),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00897B),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClientScreen()));
          _loadClients();
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

// ── Client Detail Screen ──────────────────────────────────────────────────────

class ClientDetailScreen extends StatefulWidget {
  final Client client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  List<TransactionEntry> _txns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DatabaseHelper.instance.getTransactionsByClient(widget.client.id!);
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
    await DatabaseHelper.instance.deleteTransaction(t.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    double gave = 0, received = 0;
    for (var t in _txns) {
      if (!t.isSettled) {
        if (t.type == 'gave') {
          gave += t.amount;
        } else {
          received += t.amount;
        }
      }
    }
    final balance = gave - received;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddClientScreen(existingClient: widget.client)),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary strip
                Container(
                  color: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat("Gave", "₹${gave.toStringAsFixed(0)}", Colors.red.shade200),
                      _stat("Received", "₹${received.toStringAsFixed(0)}", Colors.green.shade200),
                      _stat(
                        "Balance",
                        "₹${balance.abs().toStringAsFixed(0)}",
                        balance > 0 ? Colors.red.shade200 : Colors.green.shade200,
                      ),
                    ],
                  ),
                ),
                // Transactions
                Expanded(
                  child: _txns.isEmpty
                      ? const Center(child: Text("No transactions yet"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _txns.length,
                          itemBuilder: (_, i) {
                            final t = _txns[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(
backgroundColor: t.type == 'gave'
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                  child: Icon(
                                    t.type == 'gave' ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: t.type == 'gave' ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      "₹${t.amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: t.type == 'gave' ? Colors.red : Colors.green,
                                        decoration: t.isSettled ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (t.isSettled) ...[
                                      const SizedBox(width: 8),
                                      const Chip(
                                        label: Text("Settled", style: TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  "${t.note ?? 'No note'} • ${t.date}${t.dueDate != null ? ' | Due: ${t.dueDate}' : ''}",
                                  style: const TextStyle(fontSize: 12),
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00897B),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryScreen(preselectedClient: widget.client),
            ),
          );
          _load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
