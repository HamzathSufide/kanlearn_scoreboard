import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── USERS ───────────────────────────────────────────────────────────────
  Future<List<AppUser>> getUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }

  Future<void> createUser(AppUser user) =>
      _db.collection('users').doc(user.uid).set(user.toMap());

  // ─── BATCHES ─────────────────────────────────────────────────────────────
  Stream<List<Batch>> batchesStream() => _db
      .collection('batches')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Batch.fromMap(d.id, d.data())).toList());

  Future<void> createBatch(Batch batch) =>
      _db.collection('batches').add(batch.toMap());

  // ─── SCORES ──────────────────────────────────────────────────────────────
  Stream<List<ScoreEntry>> leaderboardStream(String batchId, String month) =>
      _db
          .collection('scores')
          .where('batchId', isEqualTo: batchId)
          .where('month', isEqualTo: month)
          .orderBy('scoreValue', descending: true)
          .limit(10)
          .snapshots()
          .map((s) =>
              s.docs.map((d) => ScoreEntry.fromMap(d.id, d.data())).toList());

  Future<void> addScore(ScoreEntry score) =>
      _db.collection('scores').add(score.toMap());

  Future<void> updateScore(String id, int newValue) =>
      _db.collection('scores').doc(id).update({
        'scoreValue': newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ─── TASKS ───────────────────────────────────────────────────────────────
  Stream<List<TaskItem>> tasksStream(String batchId) => _db
      .collection('tasks')
      .where('batchId', isEqualTo: batchId)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => TaskItem.fromMap(d.id, d.data())).toList());

  Future<void> createTask(TaskItem task) =>
      _db.collection('tasks').add(task.toMap());

  Future<void> updateTaskStatus(String id, String status) =>
      _db.collection('tasks').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ─── EVENTS ──────────────────────────────────────────────────────────────
  Stream<List<AppEvent>> eventsStream() => _db
      .collection('events')
      .orderBy('eventTime')
      .snapshots()
      .map((s) =>
          s.docs.map((d) => AppEvent.fromMap(d.id, d.data())).toList());

  Future<void> createEvent(AppEvent event) =>
      _db.collection('events').add(event.toMap());
}
