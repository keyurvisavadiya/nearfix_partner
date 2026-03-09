import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  bool isLoading = true;
  double settledAmount = 0;
  double pendingAmount = 0;
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchLedgerData();
  }

  Future<void> _fetchLedgerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int providerId = prefs.getInt('provider_id') ?? 0;

      // Replace with your current Ngrok/Base URL
      final url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_ledger.php?provider_id=$providerId";

      final response = await http.get(Uri.parse(url), headers: {"ngrok-skip-browser-warning": "true"});
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        setState(() {
          settledAmount = double.parse(decoded['settled'].toString());
          pendingAmount = double.parse(decoded['pending'].toString());
          transactions = decoded['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Ledger Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TRANSACTION LEDGER',
          style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF33365D)))
          : RefreshIndicator(
        onRefresh: _fetchLedgerData,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- Top Summary Cards ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildSummaryCard('SETTLED', '₹${settledAmount.toInt()}', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  _buildSummaryCard('PENDING', '₹${pendingAmount.toInt()}', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // --- Transaction List ---
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  return _buildTransactionTile(
                      item['service_name'] ?? 'Service',
                      '₹${item['amount']}',
                      item['booking_date'] ?? '',
                      item['status'] == 'completed'
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Keep your existing UI Helper methods (_buildSummaryCard & _buildTransactionTile) below ---
  Widget _buildSummaryCard(String label, String amount, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, String date, bool isSettled) {
    final statusColor = isSettled ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00);
    final statusBg = isSettled ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(isSettled ? Icons.check_circle_outline : Icons.access_time, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              Text(isSettled ? 'SETTLED' : 'PENDING', style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}