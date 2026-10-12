
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> transactions = [];

  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  // Đọc dữ liệu từ SQLite
  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    final list = data
        .map((item) => TransactionModel.fromMap(item))
        .toList();

    double income = 0;
    double expense = 0;

    for (final transaction in list) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else if (transaction.type == 'expense') {
        expense += transaction.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      transactions = list;
      totalIncome = income;
      totalExpense = expense;
      balance = income - expense;
    });
  }

  // Định dạng tiền Việt Nam
  String formatMoney(double money) {
    return '${money.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )} đ';
  }

  // Icon theo danh mục
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Giáo dục':
        return Icons.school;
      default:
        return Icons.receipt_long;
    }
  }

  // Màu icon theo danh mục
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return Colors.orange;
      case 'Di chuyển':
        return Colors.blue;
      case 'Mua sắm':
        return Colors.purple;
      case 'Giáo dục':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      // Thanh tiêu đề
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),
        ],
      ),

      // Nút thêm giao dịch
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2F80ED),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );

          await loadTransactions();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // Nội dung Dashboard
      body: RefreshIndicator(
        onRefresh: loadTransactions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thẻ số dư hiện tại
            Container(
              height: 135,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff4A8DFF),
                    Color(0xff176BFF),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SỐ DƯ HIỆN TẠI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatMoney(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 60,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tổng thu và tổng chi
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    Icons.arrow_downward,
                    Colors.green,
                    'TỔNG THU NHẬP',
                    formatMoney(totalIncome),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: infoCard(
                    Icons.arrow_upward,
                    Colors.red,
                    'TỔNG CHI TIÊU',
                    formatMoney(totalExpense),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tiêu đề giao dịch gần đây
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Chuyển sang tab Giao dịch
                    // được quản lý bởi MainNavigationScreen.
                  },
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: Color(0xff2F80ED),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Danh sách giao dịch
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    'Chưa có giao dịch nào',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...transactions
                  .take(10)
                  .map((transaction) => transactionItem(transaction)),
          ],
        ),
      ),

      // Không đặt bottomNavigationBar ở đây.
      // MainNavigationScreen quản lý thanh điều hướng.
    );
  }

  // Thẻ tổng thu / tổng chi
  Widget infoCard(
      IconData icon,
      Color color,
      String title,
      String money,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 18,
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  money,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Một giao dịch trong danh sách
  Widget transactionItem(TransactionModel transaction) {
    final bool isIncome = transaction.type == 'income';

    final Color amountColor =
    isIncome ? Colors.green : Colors.red;

    final String amountText =
        '${isIncome ? '+' : '-'}${formatMoney(transaction.amount)}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // Bấm giao dịch để chỉnh sửa
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTransactionScreen(
                transaction: transaction,
              ),
            ),
          );

          await loadTransactions();
        },

        // Icon danh mục
        leading: CircleAvatar(
          backgroundColor: getCategoryColor(transaction.category),
          child: Icon(
            getCategoryIcon(transaction.category),
            color: Colors.white,
          ),
        ),

        // Tên giao dịch
        title: Text(
          transaction.note.isEmpty
              ? transaction.category
              : transaction.note,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Danh mục và ngày
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              transaction.date,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),

        // Số tiền
        trailing: Text(
          amountText,
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
