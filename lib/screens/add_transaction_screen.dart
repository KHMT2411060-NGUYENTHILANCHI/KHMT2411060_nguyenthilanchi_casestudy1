import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  bool isExpense = true;

  String selectedCategory = "Ăn uống";

  final moneyController = TextEditingController();

  final dateController = TextEditingController();

  final noteController = TextEditingController();

  @override
  void dispose() {
    moneyController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {

    final amount =
    double.tryParse(moneyController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập số tiền hợp lệ"),
        ),
      );
      return;
    }

    final transaction = TransactionModel(
      type: isExpense ? "expense" : "income",
      category: selectedCategory,
      amount: amount,
      date: dateController.text.trim(),
      note: noteController.text.trim(),
    );

    await DatabaseHelper.instance.insertTransaction(
      transaction.toMap(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã lưu giao dịch"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm giao dịch"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // Chi tiêu / Thu nhập
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text("Chi tiêu"),
                ),
                ButtonSegment(
                  value: false,
                  label: Text("Thu nhập"),
                ),
              ],

              selected: {isExpense},

              onSelectionChanged: (value) {
                setState(() {
                  isExpense = value.first;
                });
              },
            ),

            const SizedBox(height: 20),

            // Danh mục
            DropdownButtonFormField<String>(
              value: selectedCategory,

              decoration: const InputDecoration(
                labelText: "Danh mục",
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Ăn uống",
                  child: Text("Ăn uống"),
                ),

                DropdownMenuItem(
                  value: "Di chuyển",
                  child: Text("Di chuyển"),
                ),

                DropdownMenuItem(
                  value: "Mua sắm",
                  child: Text("Mua sắm"),
                ),

                DropdownMenuItem(
                  value: "Giáo dục",
                  child: Text("Giáo dục"),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Số tiền
            TextField(
              controller: moneyController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Số tiền",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Ngày giao dịch
            TextField(
              controller: dateController,

              decoration: const InputDecoration(
                labelText: "Ngày giao dịch",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16),

            // Ghi chú
            TextField(
              controller: noteController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: "Ghi chú",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: saveTransaction,

                child: const Text("Lưu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}