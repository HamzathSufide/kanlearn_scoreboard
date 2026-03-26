import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class EventsScreen extends StatelessWidget {
  final AppUser user;
  const EventsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('Events', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<AppEvent>>(
        stream: db.eventsStream(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }
          final events = snap.data ?? [];
          if (events.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.event_outlined, size: 60, color: Colors.white12),
              const SizedBox(height: 12),
              Text('No upcoming events', style: GoogleFonts.inter(color: Colors.white38, fontSize: 14)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: events.length,
            itemBuilder: (_, i) => _EventCard(event: events[i]),
          );
        },
      ),
      floatingActionButton: user.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFE50914),
              onPressed: () => _showAddEventDialog(context, db),
              icon: const Icon(Icons.add),
              label: const Text('Event'),
            )
          : null,
    );
  }

  void _showAddEventDialog(BuildContext context, FirestoreService db) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? picked;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('New Event', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDec('Event Title')),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDec('Description'), maxLines: 2),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final d = await showDateTimePicker(ctx);
                if (d != null) setS(() => picked = d);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0D0D0D), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 18),
                  const SizedBox(width: 8),
                  Text(picked == null ? 'Pick date & time' : DateFormat('MMM dd, yyyy – hh:mm a').format(picked!),
                      style: TextStyle(color: picked == null ? Colors.white38 : Colors.white, fontSize: 13)),
                ]),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty && picked != null) {
                  db.createEvent(AppEvent(id: '', title: titleCtrl.text.trim(), description: descCtrl.text.trim(), eventTime: picked!));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white54),
    filled: true, fillColor: const Color(0xFF0D0D0D),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );
}

Future<DateTime?> showDateTimePicker(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (ctx, child) => Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFE50914), surface: Color(0xFF1A1A1A)),
      ),
      child: child!,
    ),
  );
  if (date == null) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (ctx, child) => Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFE50914), surface: Color(0xFF1A1A1A)),
      ),
      child: child!,
    ),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _EventCard extends StatelessWidget {
  final AppEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isPast = event.eventTime.isBefore(DateTime.now());
    final color = isPast ? Colors.white24 : const Color(0xFFD4AF37);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPast ? Colors.white10 : color.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Text(DateFormat('MMM').format(event.eventTime).toUpperCase(),
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(DateFormat('dd').format(event.eventTime),
              style: GoogleFonts.outfit(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(event.description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.access_time, size: 13, color: color),
            const SizedBox(width: 4),
            Text(DateFormat('hh:mm a').format(event.eventTime), style: TextStyle(color: color, fontSize: 12)),
            if (isPast) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
                child: const Text('Past', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ),
            ],
          ]),
        ])),
      ]),
    );
  }
}
