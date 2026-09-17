import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';

class StatsScreen extends StatelessWidget {
  final List<Transaction> transactions;
  const StatsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final incomes = transactions.where((t) => t.isIncome).toList();

    final totalExpense = expenses.fold<double>(0, (s, t) => s + t.amount);
    final totalIncome = incomes.fold<double>(0, (s, t) => s + t.amount);

    final byCategory = <String, double>{};
    for (final t in expenses) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: transactions.isEmpty
          ? const Center(child: Text('No data yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Income',
                        totalIncome,
                        Colors.green,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Expense',
                        totalExpense,
                        Colors.red,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Expenses by Category',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (byCategory.isEmpty)
                  const Text('No expenses recorded')
                else ...[
                  SizedBox(
                    height: 240,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: byCategory.entries.map((e) {
                          final info = categoryInfo(e.key, false);
                          final pct = (e.value / totalExpense) * 100;
                          return PieChartSectionData(
                            color: info.color,
                            value: e.value,
                            title: '${pct.toStringAsFixed(0)}%',
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...byCategory.entries.map((e) {
                    final info = categoryInfo(e.key, false);
                    final pct = (e.value / totalExpense) * 100;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            info.color.withValues(alpha: 0.15),
                        child: Icon(info.icon, size: 14, color: info.color),
                      ),
                      title: Text(e.key),
                      trailing: Text(
                        '${formatCurrency(e.value)}  (${pct.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }

  Widget _summaryCard(
      String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(value),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}