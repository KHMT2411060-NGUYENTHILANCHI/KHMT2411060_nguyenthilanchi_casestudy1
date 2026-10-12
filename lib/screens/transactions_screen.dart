
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../database/transaction_model.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  String _searchText = '';
  String _selectedType = 'all';

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Đọc toàn bộ giao dịch từ SQLite.
  Future<void> _loadTransactions() async {
    try {
      final data =
      await DatabaseHelper.instance.getTransactions();

      final transactions = data
          .map((item) => TransactionModel.fromMap(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải giao dịch: $e'),
        ),
      );
    }
  }

  // Lọc theo từ khóa và loại giao dịch.
  List<TransactionModel> get _filteredTransactions {
    return _transactions.where((transaction) {
      final keyword = _searchText.toLowerCase().trim();

      final matchesSearch =
          transaction.category.toLowerCase().contains(keyword) ||
              transaction.note.toLowerCase().contains(keyword) ||
              transaction.date.toLowerCase().contains(keyword);

      final matchesType = _selectedType == 'all' ||
          transaction.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();
  }

  // Định dạng số tiền theo kiểu 1.000.000.
  String _formatMoney(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);

      final remaining = value.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Giáo dục':
        return Icons.school;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getCategoryColor(String category) {
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
        return Colors.indigo;
    }
  }

  Future<void> _openEditScreen(
      TransactionModel transaction,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
        ),
      ),
    );

    // Tải lại danh sách sau khi sửa giao dịch.
    if (mounted) {
      await _loadTransactions();
    }
  }

  Widget _buildFilterChip(String label, String type) {
    final selected = _selectedType == type;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setState(() {
          _selectedType = type;
        });
      },
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: selected ? Colors.blue.shade900 : Colors.black87,
        fontWeight:
        selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildTransactionItem(
      TransactionModel transaction,
      ) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor:
          _getCategoryColor(transaction.category)
              .withValues(alpha: 0.12),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: _getCategoryColor(transaction.category),
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            transaction.note.trim().isEmpty
                ? transaction.date
                : '${transaction.date} • ${transaction.note}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${_formatMoney(transaction.amount)} đ',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isIncome ? 'Thu nhập' : 'Chi tiêu',
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
        onTap: () => _openEditScreen(transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF202B45),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _loadTransactions,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF202B45),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ô tìm kiếm.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tìm danh mục, ghi chú, ngày...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Bộ lọc loại giao dịch.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Thu nhập', 'income'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chi tiêu', 'expense'),
                ],
              ),
            ),

            // Số lượng kết quả.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Text(
                    'Lịch sử giao dịch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filtered.length} giao dịch',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách giao dịch.
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : RefreshIndicator(
                onRefresh: _loadTransactions,
                child: filtered.isEmpty
                    ? ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 70),
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Không tìm thấy giao dịch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Thử đổi từ khóa hoặc bộ lọc nhé.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 20,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(
                      filtered[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
