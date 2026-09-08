import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'add_client_screen.dart';
import 'manage_clients_screen.dart';
import 'add_entry_screen.dart';
import 'recent_screen.dart';
import 'reminder_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> _summary = {'gave': 0, 'received': 0, 'balance': 0};
  int _reminderCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await DatabaseHelper.instance.getSummary();
    final reminders = await DatabaseHelper.instance.getPendingReminders();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _reminderCount = reminders.length;
      _loading = false;
    });
  }

  void _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Borrow Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigate(const SettingsScreen()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 20),
                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildReminderBanner(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _summary['balance'] ?? 0;
    final isPositive = balance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Net Balance", style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            "₹${balance.abs().toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            isPositive ? "You are owed this amount" : "You owe this amount",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _balanceStat("↑ Gave", _summary['gave'] ?? 0, Colors.red.shade200),
              Container(height: 40, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
              _balanceStat("↓ Received", _summary['received'] ?? 0, Colors.green.shade200),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(Icons.person_add_outlined, "Add Client", const Color(0xFF5C6BC0),
            () => _navigate(const AddClientScreen())),
        _actionCard(Icons.people_outline, "Clients List", const Color(0xFF26A69A),
            () => _navigate(const ManageClientsScreen())),
        _actionCard(Icons.swap_horiz, "Lend / Borrow", const Color(0xFFEF5350),
            () => _navigate(const AddEntryScreen())),
        _actionCard(Icons.history, "Recent", const Color(0xFFFFA726),
            () => _navigate(const RecentScreen())),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderBanner() {
    if (_reminderCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _navigate(const ReminderScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$_reminderCount payment(s) are overdue or due today!",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
