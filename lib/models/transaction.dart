// lib/models/transaction.dart
import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense
}

class Transaction {
  final String id;
  final String name;
  final double amount;
  final TransactionType transactionType;
  final DateTime date;
  final String? category;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.transactionType,
    required this.date,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'transaction_type': transactionType.toString().split('.').last,
      'date': date.toIso8601String(),
      if (category != null) 'category': category,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      transactionType: json['transaction_type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }

  Transaction copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionType? transactionType,
    DateTime? date,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}