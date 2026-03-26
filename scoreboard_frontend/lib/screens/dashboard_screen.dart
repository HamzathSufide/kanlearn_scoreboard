import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../auth/auth_service.dart';
import '../services/firestore_service.dart';
import 'leaderboard_screen.dart';
import 'scrum_board_screen.dart';
import 'events_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppUser user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(user: widget.user),
      LeaderboardScreen(user: widget.user),
      ScrumBoardScreen(user: widget.user),
      EventsScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12)],
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF1A1A1A),
          indicatorColor: const Color(0xFFE50914).withOpacity(0.2),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Color(0xFFE50914)), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard, color: Color(0xFFE50914)), label: 'Leaders'),
            NavigationDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban, color: Color(0xFFE50914)), label: 'Scrum'),
            NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event, color: Color(0xFFE50914)), label: 'Events'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final AppUser user;
  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          backgroundColor: const Color(0xFF0D0D0D),
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0A0A), Color(0xFF0D0D0D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFFE50914), Color(0xFFD4AF37)]),
                        ),
                        child: Center(
                          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Welcome back,', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        Text(user.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
                    ),
                    child: Text(user.role.replaceAll('_', ' '), style: const TextStyle(color: Color(0xFFE50914), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('OVERVIEW', style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 2, color: Colors.white38)),
              const SizedBox(height: 12),
              StreamBuilder<List<Batch>>(
                stream: db.batchesStream(),
                builder: (ctx, snap) {
                  final batches = snap.data ?? [];
                  return Column(children: [
                    _statRow([
                      _StatCard(label: 'Total Batches', value: '${batches.length}', icon: Icons.group_work_outlined, color: const Color(0xFFE50914)),
                      _StatCard(label: 'My Role', value: user.role == 'MASTER_ADMIN' ? 'Master' : user.role, icon: Icons.shield_outlined, color: const Color(0xFFD4AF37)),
                    ]),
                    const SizedBox(height: 12),
                    if (batches.isNotEmpty) ...[
                      Text('BATCHES', style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 2, color: Colors.white38)),
                      const SizedBox(height: 10),
                      ...batches.map((b) => _BatchCard(batch: b)),
                    ],
                    if (user.isAdmin && batches.isEmpty)
                      _EmptyState(message: 'No batches yet. Create your first batch!', icon: Icons.group_work_outlined),
                  ]);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _statRow(List<Widget> children) => Row(
    children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: c))).toList(),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 10),
      Text(value, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
    ]),
  );
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(children: [
      Container(width: 8, height: 40, decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(batch.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        if (batch.description.isNotEmpty)
          Text(batch.description, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
      ])),
      const Icon(Icons.chevron_right, color: Colors.white38),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      Icon(icon, size: 56, color: Colors.white12),
      const SizedBox(height: 12),
      Text(message, style: GoogleFonts.inter(color: Colors.white38, fontSize: 14), textAlign: TextAlign.center),
    ]),
  );
}
