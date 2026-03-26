class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // MASTER_ADMIN, ADMIN, USER
  final String? batchId;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.batchId,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'USER',
      batchId: map['batchId'],
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'batchId': batchId,
        'createdAt': createdAt,
      };

  bool get isMasterAdmin => role == 'MASTER_ADMIN';
  bool get isAdmin => role == 'ADMIN' || isMasterAdmin;
}

class Batch {
  final String id;
  final String name;
  final String description;

  Batch({required this.id, required this.name, required this.description});

  factory Batch.fromMap(String id, Map<String, dynamic> map) => Batch(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'createdAt': DateTime.now(),
      };
}

class ScoreEntry {
  final String id;
  final String userId;
  final String userName;
  final String batchId;
  final int scoreValue;
  final String month;

  ScoreEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.batchId,
    required this.scoreValue,
    required this.month,
  });

  factory ScoreEntry.fromMap(String id, Map<String, dynamic> map) =>
      ScoreEntry(
        id: id,
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        batchId: map['batchId'] ?? '',
        scoreValue: map['scoreValue'] ?? 0,
        month: map['month'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'batchId': batchId,
        'scoreValue': scoreValue,
        'month': month,
        'updatedAt': DateTime.now(),
      };
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  String status; // TODO, IN_PROGRESS, DONE
  final String? assignedTo;
  final String batchId;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    required this.batchId,
  });

  factory TaskItem.fromMap(String id, Map<String, dynamic> map) => TaskItem(
        id: id,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        status: map['status'] ?? 'TODO',
        assignedTo: map['assignedTo'],
        batchId: map['batchId'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'status': status,
        'assignedTo': assignedTo,
        'batchId': batchId,
        'updatedAt': DateTime.now(),
      };
}

class AppEvent {
  final String id;
  final String title;
  final String description;
  final DateTime eventTime;

  AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventTime,
  });

  factory AppEvent.fromMap(String id, Map<String, dynamic> map) => AppEvent(
        id: id,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        eventTime: (map['eventTime'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'eventTime': eventTime,
        'createdAt': DateTime.now(),
      };
}
