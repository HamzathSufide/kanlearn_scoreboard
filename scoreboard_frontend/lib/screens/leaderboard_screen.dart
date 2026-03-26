import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final AppUser user;
  const LeaderboardScreen({super.key, required this.user});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedBatchId = '';
  String _selectedMonth = DateFormat('MMMM-yyyy').format(DateTime.now());
  final _db = FirestoreService();

  static const _rankColors = [Color(0xFFD4AF37), Color(0xFFB0B0B0), Color(0xFFCD7F32)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('🏆 Leaderboard', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              backgroundColor: const Color(0xFF1A1A1A),
              label: Text(_selectedMonth, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              avatar: const Icon(Icons.calendar_month, size: 14, color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Batch selector
          StreamBuilder<List<Batch>>(
            stream: _db.batchesStream(),
            builder: (ctx, snap) {
              final batches = snap.data ?? [];
              if (batches.isNotEmpty && _selectedBatchId.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _selectedBatchId = batches[0].id);
                });
              }
              return SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: batches.length,
                  itemBuilder: (_, i) {
                    final b = batches[i];
                    final sel = b.id == _selectedBatchId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBatchId = b.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFFE50914) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? const Color(0xFFE50914) : Colors.white12),
                        ),
                        child: Center(child: Text(b.name, style: TextStyle(color: sel ? Colors.white : Colors.white54, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13))),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Leaderboard
          Expanded(
            child: _selectedBatchId.isEmpty
                ? const Center(child: Text('Select a batch', style: TextStyle(color: Colors.white38)))
                : StreamBuilder<List<ScoreEntry>>(
                    stream: _db.leaderboardStream(_selectedBatchId, _selectedMonth),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                      }
                      final scores = snap.data ?? [];
                      if (scores.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.emoji_events_outlined, size: 60, color: Colors.white12),
                          const SizedBox(height: 12),
                          Text('No scores for $_selectedMonth', style: const TextStyle(color: Colors.white38)),
                        ]));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: scores.length,
                        itemBuilder: (_, i) => _LeaderCard(entry: scores[i], rank: i + 1, rankColors: _rankColors),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  final ScoreEntry entry;
  final int rank;
  final List<Color> rankColors;

  const _LeaderCard({required this.entry, required this.rank, required this.rankColors});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final color = isTop3 ? rankColors[rank - 1] : Colors.white38;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTop3 ? color.withOpacity(0.4) : Colors.white10),
        boxShadow: isTop3 ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12)] : null,
      ),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: isTop3
              ? Icon(Icons.emoji_events, color: color, size: 28)
              : Text('#$rank', style: GoogleFonts.outfit(color: Colors.white38, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.4)]),
          ),
          child: Center(child: Text(entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(entry.userName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text('${entry.scoreValue} pts', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ]),
    );
  }
}
