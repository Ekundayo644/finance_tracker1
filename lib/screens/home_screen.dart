import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../utils/formatters.dart';
import '../utils/categories.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.instance.getAll();
      setState(() {
        _transactions = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double get _totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _deleteTransaction(String id) async {
    try {
      await SupabaseService.instance.delete(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _openEdit(Transaction transaction) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _logout() async {
    await SupabaseService.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatsScreen(transactions: _transactions),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  _buildBalanceCard(),
                  Expanded(
                    child: _transactions.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (_, i) =>
                                _buildTile(_transactions[i]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Balance',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            formatCurrency(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _balanceChip(
                  Icons.arrow_downward,
                  'Income',
                  _totalIncome,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _balanceChip(
                  Icons.arrow_upward,
                  'Expense',
                  _totalExpense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(IconData icon, String label, double value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white24,
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(
              formatCurrency(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text('No transactions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
        SizedBox(height: 8),
        Center(
          child: Text('Tap + to add your first one',
              style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildTile(Transaction t) {
    final info = categoryInfo(t.category, t.isIncome);
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTransaction(t.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: info.color.withValues(alpha: 0.15),
          child: Icon(info.icon, color: info.color),
        ),
        title: Text(t.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${t.category} • ${formatDate(t.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${t.isIncome ? '+' : '-'}${formatCurrency(t.amount)}',
              style: TextStyle(
                color: t.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _openEdit(t),
            ),
          ],
        ),
      ),
    );
  }
}