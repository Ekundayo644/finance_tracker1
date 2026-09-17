enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  // ✅ Accepts userId so it can be included in the insert
  Map<String, dynamic> toSupabase({required String userId}) => {
        'id': id,
        'user_id': userId,          // ✅ THE FIX
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'type': type.name,
      };

  factory Transaction.fromSupabase(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        date: DateTime.parse(map['date'] as String).toLocal(),
        type: (map['type'] as String) == 'income'
            ? TransactionType.income
            : TransactionType.expense,
      );
}