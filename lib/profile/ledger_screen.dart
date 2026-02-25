import 'package:flutter/material.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

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
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // --- Top Summary Cards ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildSummaryCard('SETTLED', '₹12,450', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                _buildSummaryCard('PENDING', '₹850', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // --- Transaction List ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTransactionTile('Full Bathroom Repair', '₹450', 'OCT 12', true),
                _buildTransactionTile('Pipe System Install', '₹2,100', 'OCT 10', true),
                _buildTransactionTile('Kitchen Sink Overhaul', '₹850', 'OCT 15', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the top green/orange summary cards
  Widget _buildSummaryCard(String label, String amount, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
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

  // Helper for the transaction list items
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(isSettled ? Icons.check_circle_outline : Icons.access_time, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Details
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
          // Amount and Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                isSettled ? 'SETTLED' : 'PENDING',
                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}