import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Quản lý thu chi",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2F80ED),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // CARD SỐ DƯ
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SỐ DƯ HIỆN TẠI",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "5.000.000 đ",
                        style: TextStyle(
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
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // THU / CHI
          Row(
            children: [
              Expanded(
                child: infoCard(
                  Icons.arrow_downward,
                  Colors.green,
                  "TỔNG THU NHẬP",
                  "8.000.000 đ",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: infoCard(
                  Icons.arrow_upward,
                  Colors.red,
                  "TỔNG CHI TIÊU",
                  "3.000.000 đ",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Giao dịch gần đây",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Xem tất cả",
                style: TextStyle(
                  color: Color(0xff2F80ED),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          transaction(
            Icons.restaurant,
            Colors.orange,
            "Ăn trưa",
            "Ăn uống",
            "03/09/2024",
            "-50.000 đ",
            Colors.red,
          ),

          transaction(
            Icons.directions_car,
            Colors.blue,
            "Xăng xe",
            "Di chuyển",
            "03/09/2024",
            "-100.000 đ",
            Colors.red,
          ),

          transaction(
            Icons.attach_money,
            Colors.green,
            "Lương tháng 9",
            "Thu nhập",
            "01/09/2024",
            "+8.000.000 đ",
            Colors.green,
          ),

          transaction(
            Icons.shopping_cart,
            Colors.purple,
            "Mua sắm",
            "Mua sắm",
            "31/08/2024",
            "-300.000 đ",
            Colors.red,
          ),

          transaction(
            Icons.school,
            Colors.teal,
            "Học phí",
            "Giáo dục",
            "30/08/2024",
            "-500.000 đ",
            Colors.red,
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: "Giao dịch",
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: "Thống kê",
          ),
        ],
      ),
    );
  }

  static Widget infoCard(
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
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10),
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
          )
        ],
      ),
    );
  }

  static Widget transaction(
      IconData icon,
      Color iconColor,
      String title,
      String category,
      String date,
      String amount,
      Color amountColor,
      ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category),
            Text(
              date,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}