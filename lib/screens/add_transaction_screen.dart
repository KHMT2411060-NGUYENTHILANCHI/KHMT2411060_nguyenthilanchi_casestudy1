import 'package:flutter/material.dart';
import 'edit_transaction_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  bool isExpense = true;

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

            DropdownButtonFormField<String>(
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
              ],

              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số tiền",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                labelText: "Ngày giao dịch",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Ghi chú",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditTransactionScreen(),
                    ),
                  );
                },
                child: const Text("Lưu"),
              )
            ),
          ],
        ),
      ),
    );
  }
}