// lib/models/forecast_transaction.dart
import 'transaction.dart';

class ForecastTransaction extends Transaction {
  final String? notes;
  final String? actualTransactionId;
  final bool realized;

  ForecastTransaction({
    required String id,
    required String name,
    required double amount,
    required TransactionType transactionType,
    required DateTime date,
    String? category,
    this.notes = '',
    this.actualTransactionId,
    this.realized = false,
  }) : super(
          id: id,
          name: name,
          amount: amount,
          transactionType: transactionType,
          date: date,
          category: category,
        );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['notes'] = notes;
    map['realized'] = realized;
    if (actualTransactionId != null) {
      map['actual_transaction_id'] = actualTransactionId;
    }
    return map;
  }

  factory ForecastTransaction.fromJson(Map<String, dynamic> json) {
    return ForecastTransaction(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      transactionType: json['transaction_type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(json['date']),
      category: json['category'],
      notes: json['notes'] ?? '',
      actualTransactionId: json['actual_transaction_id'],
      realized: json['realized'] ?? false,
    );
  }

  @override
  ForecastTransaction copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionType? transactionType,
    DateTime? date,
    String? category,
    String? notes,
    String? actualTransactionId,
    bool? realized,
  }) {
    return ForecastTransaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      actualTransactionId: actualTransactionId ?? this.actualTransactionId,
      realized: realized ?? this.realized,
    );
  }
}