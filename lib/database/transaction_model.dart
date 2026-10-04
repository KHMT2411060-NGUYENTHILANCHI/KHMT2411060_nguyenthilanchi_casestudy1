class TransactionModel {
  final int? id;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String note;

  TransactionModel({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });

  // Chuyển đối tượng thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }

  // Chuyển dữ liệu từ SQLite thành TransactionModel
  factory TransactionModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      note: map['note'] as String? ?? '',
    );
  }
}