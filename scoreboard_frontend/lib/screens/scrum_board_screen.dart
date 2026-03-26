import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class ScrumBoardScreen extends StatefulWidget {
  final AppUser user;
  const ScrumBoardScreen({super.key, required this.user});

  @override
  State<ScrumBoardScreen> createState() => _ScrumBoardScreenState();
}

class _ScrumBoardScreenState extends State<ScrumBoardScreen> {
  final _db = FirestoreService();
  String _batchId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('Scrum Board', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        // Batch selector
        StreamBuilder<List<Batch>>(
          stream: _db.batchesStream(),
          builder: (ctx, snap) {
            final batches = snap.data ?? [];
            if (batches.isNotEmpty && _batchId.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _batchId = batches[0].id));
            }
            return SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: batches.length,
                itemBuilder: (_, i) {
                  final b = batches[i];
                  final sel = b.id == _batchId;
                  return GestureDetector(
                    onTap: () => setState(() => _batchId = b.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFE50914) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? const Color(0xFFE50914) : Colors.white12),
                      ),
                      child: Center(child: Text(b.name, style: TextStyle(color: sel ? Colors.white : Colors.white54, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal))),
                    ),
                  );
                },
              ),
            );
          },
        ),
        // Kanban columns
        Expanded(
          child: _batchId.isEmpty
              ? const Center(child: Text('Select a batch', style: TextStyle(color: Colors.white38)))
              : StreamBuilder<List<TaskItem>>(
                  stream: _db.tasksStream(_batchId),
                  builder: (ctx, snap) {
                    final tasks = snap.data ?? [];
                    return Row(
                      children: ['TODO', 'IN_PROGRESS', 'DONE'].map((status) {
                        final colTasks = tasks.where((t) => t.status == status).toList();
                        return Expanded(child: _KanbanColumn(
                          status: status,
                          tasks: colTasks,
                          onMove: (task, newStatus) => _db.updateTaskStatus(task.id, newStatus),
                          canEdit: widget.user.isAdmin,
                        ));
                      }).toList(),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: widget.user.isAdmin && _batchId.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFE50914),
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Task'),
            )
          : null,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('New Task', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Title')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Description'), maxLines: 2),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                _db.createTask(TaskItem(id: '', title: titleCtrl.text.trim(), description: descCtrl.text.trim(), status: 'TODO', batchId: _batchId));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white54),
    filled: true, fillColor: const Color(0xFF0D0D0D),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );
}

class _KanbanColumn extends StatelessWidget {
  final String status;
  final List<TaskItem> tasks;
  final Function(TaskItem, String) onMove;
  final bool canEdit;

  const _KanbanColumn({required this.status, required this.tasks, required this.onMove, required this.canEdit});

  static const _labels = {'TODO': 'To Do', 'IN_PROGRESS': 'In Progress', 'DONE': 'Done'};
  static const _colors = {'TODO': Color(0xFF607D8B), 'IN_PROGRESS': Color(0xFFE50914), 'DONE': Color(0xFF4CAF50)};

  @override
  Widget build(BuildContext context) {
    final color = _colors[status]!;
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: color.withOpacity(0.3))),
          ),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(_labels[status]!, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('${tasks.length}', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (_, i) => _TaskCard(task: tasks[i], onMove: onMove, canEdit: canEdit),
          ),
        ),
      ]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final Function(TaskItem, String) onMove;
  final bool canEdit;

  const _TaskCard({required this.task, required this.onMove, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(task.description, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        if (canEdit) ...[
          const SizedBox(height: 8),
          Row(children: [
            if (task.status != 'TODO') _MoveBtn(label: '←', color: Colors.blueGrey, onTap: () {
              final prev = {'IN_PROGRESS': 'TODO', 'DONE': 'IN_PROGRESS'};
              onMove(task, prev[task.status]!);
            }),
            const Spacer(),
            if (task.status != 'DONE') _MoveBtn(label: '→', color: const Color(0xFFE50914), onTap: () {
              final next = {'TODO': 'IN_PROGRESS', 'IN_PROGRESS': 'DONE'};
              onMove(task, next[task.status]!);
            }),
          ]),
        ],
      ]),
    );
  }
}

class _MoveBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MoveBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    ),
  );
}
