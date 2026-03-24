import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/market/models/app_colors.dart';

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
      final url =
          "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/get_ledger.php?provider_id=$providerId";
      final response = await http.get(Uri.parse(url),
          headers: {"ngrok-skip-browser-warning": "true"});
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: AppColors.dark),
          ),
        ),
        title: Text('Transaction Ledger',
            style: TextStyle(
                color: AppColors.dark,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchLedgerData,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Summary row
                          Row(
                            children: [
                              _summaryCard(
                                  'SETTLED',
                                  '₹${settledAmount.toInt()}',
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                  Icons.check_circle_outline_rounded),
                              const SizedBox(width: 12),
                              _summaryCard(
                                  'PENDING',
                                  '₹${pendingAmount.toInt()}',
                                  const Color(0xFFFEF3C7),
                                  const Color(0xFFF59E0B),
                                  Icons.access_time_rounded),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Header
                          Row(
                            children: [
                              Text('All Transactions',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.dark)),
                              const Spacer(),
                              Text('${transactions.length} records',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  transactions.isEmpty
                      ? SliverFillRemaining(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 56, color: AppColors.borderGrey),
                              const SizedBox(height: 12),
                              Text("No transactions yet",
                                  style: TextStyle(
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _buildTransactionTile(
                                      item['service_name'] ?? 'Service',
                                      '₹${item['amount']}',
                                      item['booking_date'] ?? '',
                                      item['status'] == 'completed'),
                                );
                              },
                              childCount: transactions.length,
                            ),
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String amount, Color bgColor,
      Color textColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text(amount,
                style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
      String title, String amount, String date, bool isSettled) {
    final statusColor =
        isSettled ? AppColors.primary : const Color(0xFFF59E0B);
    final statusBg =
        isSettled ? AppColors.primaryLight : const Color(0xFFFEF3C7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
                color: statusBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(
                isSettled
                    ? Icons.check_rounded
                    : Icons.access_time_rounded,
                color: statusColor,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.dark)),
                const SizedBox(height: 3),
                Text(date,
                    style: TextStyle(
                        color: AppColors.labelGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.dark)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(isSettled ? 'SETTLED' : 'PENDING',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
