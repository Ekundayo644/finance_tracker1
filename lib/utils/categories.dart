import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  const CategoryInfo(this.name, this.icon, this.color);
}

const List<CategoryInfo> expenseCategories = [
  CategoryInfo('Food', Icons.restaurant, Colors.orange),
  CategoryInfo('Transport', Icons.directions_bus, Colors.blue),
  CategoryInfo('Bills', Icons.receipt_long, Colors.red),
  CategoryInfo('Shopping', Icons.shopping_bag, Colors.purple),
  CategoryInfo('Health', Icons.local_hospital, Colors.teal),
  CategoryInfo('Entertainment', Icons.movie, Colors.pink),
  CategoryInfo('Other', Icons.category, Colors.grey),
];

const List<CategoryInfo> incomeCategories = [
  CategoryInfo('Salary', Icons.work, Colors.green),
  CategoryInfo('Business', Icons.storefront, Colors.green),
  CategoryInfo('Gift', Icons.card_giftcard, Colors.green),
  CategoryInfo('Other', Icons.attach_money, Colors.green),
];

CategoryInfo categoryInfo(String name, bool isIncome) {
  final list = isIncome ? incomeCategories : expenseCategories;
  return list.firstWhere(
    (c) => c.name == name,
    orElse: () => list.last,
  );
}