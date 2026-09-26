import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {

  bool isExpense = true;

  final money =
  TextEditingController(text: "100000");

  final date =
  TextEditingController(text: "12/04/2025");

  final note =
  TextEditingController(text: "Ăn trưa");

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
              value: "Ăn uống",
              decoration: const InputDecoration(
                labelText: "Danh mục",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Ăn uống",
                  child: Text("Ăn uống"),
                ),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            TextField(
              controller: money,
              decoration: const InputDecoration(
                labelText: "Số tiền",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: date,
              decoration: const InputDecoration(
                labelText: "Ngày giao dịch",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: note,
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
                  Navigator.pop(context);
                },
                child: const Text("Lưu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}