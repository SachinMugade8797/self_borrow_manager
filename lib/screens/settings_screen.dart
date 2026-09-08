import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = 'INR';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Preferences", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _settingTile(
                    "Currency",
                    Icons.currency_exchange,
                    DropdownButton<String>(
                      value: _currency,
                      underline: const SizedBox(),
                      items: ["INR", "USD", "EUR"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                  const Divider(height: 1),
                  _settingTile(
                    "Language",
                    Icons.language,
                    DropdownButton<String>(
                      value: _language,
                      underline: const SizedBox(),
                      items: ["English", "Hindi", "Marathi"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("About", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Color(0xFF00897B)),
                    title: Text("App Version"),
                    trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF00897B)),
                    title: const Text("Privacy Policy"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Settings saved!")),
                  );
                },
                child: const Text("SAVE SETTINGS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(String label, IconData icon, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00897B)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          trailing,
        ],
      ),
    );
  }
}
