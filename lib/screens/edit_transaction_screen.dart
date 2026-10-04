import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {

  late bool isExpense;
  late String selectedCategory;

  late TextEditingController moneyController;
  late TextEditingController dateController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();

    // Lấy dữ liệu giao dịch đang chọn
    isExpense = widget.transaction.type == 'expense';

    selectedCategory = widget.transaction.category;

    moneyController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(0),
    );

    dateController = TextEditingController(
      text: widget.transaction.date,
    );

    noteController = TextEditingController(
      text: widget.transaction.note,
    );
  }

  @override
  void dispose() {
    moneyController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Lưu thay đổi
  Future<void> updateTransaction() async {
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

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      type: isExpense ? 'expense' : 'income',
      category: selectedCategory,
      amount: amount,
      date: dateController.text.trim(),
      note: noteController.text.trim(),
    );

    await DatabaseHelper.instance.updateTransaction(
      widget.transaction.id!,
      updatedTransaction.toMap(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã cập nhật giao dịch"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa giao dịch"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // =========================
            // CHI TIÊU / THU NHẬP
            // =========================
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

            // =========================
            // DANH MỤC
            // =========================
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

            // =========================
            // SỐ TIỀN
            // =========================
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Số tiền",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // NGÀY
            // =========================
            TextField(
              controller: dateController,

              decoration: const InputDecoration(
                labelText: "Ngày giao dịch",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // GHI CHÚ
            // =========================
            TextField(
              controller: noteController,
              maxLines: 3,

              decoration: const InputDecoration(
                labelText: "Ghi chú",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // =========================
            // NÚT LƯU
            // =========================
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: updateTransaction,

                child: const Text("Lưu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}