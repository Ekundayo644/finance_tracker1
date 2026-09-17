import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class SupabaseService {
  SupabaseService._private();
  static final SupabaseService instance = SupabaseService._private();

  final _client = Supabase.instance.client;

  // ─── AUTH ────────────────────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => _client.auth.currentSession != null;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── TRANSACTIONS ────────────────────────────────────────────
  Future<List<Transaction>> getAll() async {
    final data = await _client
        .from('transactions')
        .select()
        .order('date', ascending: false);

    return (data as List)
        .map((json) => Transaction.fromSupabase(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> insert(Transaction t) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to save a transaction');
    }

    await _client
        .from('transactions')
        .insert(t.toSupabase(userId: user.id));   // ✅ passes user_id
  }

  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  Future<void> update(Transaction t) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to update a transaction');
    }

    await _client
        .from('transactions')
        .update(t.toSupabase(userId: user.id))    // ✅ passes user_id
        .eq('id', t.id);
  }

  // ─── REALTIME (optional) ─────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getRealtimeStream() {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('date');
  }
}