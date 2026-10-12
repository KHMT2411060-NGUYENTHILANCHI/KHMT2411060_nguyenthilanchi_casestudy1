
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/transaction_model.dart';

class StatisticsScreen extends StatefulWidget {
  final bool isActive;

  const StatisticsScreen({
    super.key,
    this.isActive = false,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedPeriod = 0;
  bool isLoading = true;

  List<TransactionModel> transactions = [];

  final Color blue = const Color(0xFF2878F0);
  final Color background = const Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      loadTransactions();
    }
  }

  Future<void> loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();
      final allTransactions = data
          .map((item) => TransactionModel.fromMap(item))
          .toList();

      if (!mounted) return;

      setState(() {
        transactions = allTransactions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được dữ liệu thống kê: $e'),
        ),
      );
    }
  }

  DateTime? parseDate(String value) {
    final text = value.trim();

    final isoDate = DateTime.tryParse(text);
    if (isoDate != null) return isoDate;

    final parts = text.split(RegExp(r'[/\-]'));

    if (parts.length == 3) {
      try {
        final first = int.parse(parts[0]);
        final second = int.parse(parts[1]);
        final third = int.parse(parts[2]);

        if (parts[0].length == 4) {
          return DateTime(first, second, third);
        }

        return DateTime(third, second, first);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  bool isInSelectedPeriod(TransactionModel transaction) {
    final date = parseDate(transaction.date);

    if (date == null) return true;

    final now = DateTime.now();

    if (selectedPeriod == 0) {
      return date.year == now.year && date.month == now.month;
    }

    if (selectedPeriod == 1) {
      final previousMonth = DateTime(now.year, now.month - 1);

      return date.year == previousMonth.year &&
          date.month == previousMonth.month;
    }

    return date.year == now.year;
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where(isInSelectedPeriod).toList();
  }

  double get totalIncome {
    return filteredTransactions
        .where((item) => item.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalMoney => totalIncome + totalExpense;

  double get balance => totalIncome - totalExpense;

  String formatMoney(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )} đ';
  }

  Map<String, double> get expenseByCategory {
    final result = <String, double>{};

    for (final transaction in filteredTransactions) {
      if (transaction.type == 'expense') {
        result.update(
          transaction.category,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: loadTransactions,
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadTransactions,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Bộ lọc thời gian
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _periodButton(0, 'Tháng này'),
                  _periodButton(1, 'Tháng trước'),
                  _periodButton(2, 'Năm nay'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Biểu đồ tròn
            Container(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tổng quan thu chi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 230,
                    width: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: DonutChartPainter(
                            income: totalIncome,
                            expense: totalExpense,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatMoney(totalMoney),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tổng thu chi',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _legend(
                        color: const Color(0xFF2E86DE),
                        label: 'Thu nhập',
                      ),
                      _legend(
                        color: const Color(0xFFFF6B6B),
                        label: 'Chi tiêu',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chi tiết thu chi
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết thu chi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _summaryRow(
                    'Tổng thu nhập',
                    formatMoney(totalIncome),
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                  const SizedBox(height: 16),
                  _summaryRow(
                    'Tổng chi tiêu',
                    formatMoney(totalExpense),
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                  const Divider(height: 28),
                  _summaryRow(
                    'Số dư',
                    formatMoney(balance),
                    blue,
                    Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chi tiêu theo danh mục
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiêu theo danh mục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (expenseByCategory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Chưa có dữ liệu chi tiêu',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...expenseByCategory.entries.map((entry) {
                      final percent = totalExpense > 0
                          ? entry.value / totalExpense
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text(
                                  formatMoney(entry.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: percent.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor:
                                const Color(0xFFE9EDF5),
                                valueColor:
                                AlwaysStoppedAnimation<Color>(blue),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(percent * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Tổng số giao dịch: ${filteredTransactions.length}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(int index, String label) {
    final selected = selectedPeriod == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontSize: 12,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _summaryRow(
      String title,
      String amount,
      Color color,
      IconData icon,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double income;
  final double expense;

  DonutChartPainter({
    required this.income,
    required this.expense,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - 5,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    final total = income + expense;

    if (total <= 0) {
      paint.color = const Color(0xFFE5E7EB);
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    const gap = 0.07;
    final usableAngle = math.pi * 2 - gap * 2;

    final incomeAngle = usableAngle * income / total;
    final expenseAngle = usableAngle * expense / total;

    double startAngle = -math.pi / 2;

    if (income > 0) {
      paint.color = const Color(0xFF2E86DE);
      canvas.drawArc(
        rect,
        startAngle,
        math.max(0, incomeAngle - gap),
        false,
        paint,
      );
      startAngle += incomeAngle;
    }

    if (expense > 0) {
      paint.color = const Color(0xFFFF6B6B);
      canvas.drawArc(
        rect,
        startAngle,
        math.max(0, expenseAngle - gap),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.income != income ||
        oldDelegate.expense != expense;
  }
}
