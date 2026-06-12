enum SessionType { practice, round }

class Record {
  Record({
    required this.id,
    required this.date,
    required this.type,
    required this.goodFeel,
    required this.missCause,
    required this.nextTry,
    required this.tags,
    required this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime date;
  final SessionType type;
  final String goodFeel;
  final String missCause;
  final String nextTry;
  final List<String> tags;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Record copyWith({
    String? id,
    DateTime? date,
    SessionType? type,
    String? goodFeel,
    String? missCause,
    String? nextTry,
    List<String>? tags,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      goodFeel: goodFeel ?? this.goodFeel,
      missCause: missCause ?? this.missCause,
      nextTry: nextTry ?? this.nextTry,
      tags: tags ?? this.tags,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'goodFeel': goodFeel,
      'missCause': missCause,
      'nextTry': nextTry,
      'tags': tags,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    final record = tryFromJson(json);
    if (record == null) {
      throw const FormatException('Invalid record JSON');
    }
    return record;
  }

  /// Returns null when required fields are missing or invalid.
  static Record? tryFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      return null;
    }

    final goodFeel = json['goodFeel'];
    final missCause = json['missCause'];
    final nextTry = json['nextTry'];
    if (goodFeel is! String || missCause is! String || nextTry is! String) {
      return null;
    }

    final fallbackNow = DateTime.now();
    final date = _parseDateTime(json['date'], fallbackNow);
    final createdAt = _parseDateTime(json['createdAt'], date);
    final updatedAt = _parseDateTime(json['updatedAt'], createdAt);

    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.whereType<String>().toList()
        : <String>[];

    return Record(
      id: id,
      date: date,
      type: _parseSessionType(json['type']),
      goodFeel: goodFeel,
      missCause: missCause,
      nextTry: nextTry,
      tags: tags,
      memo: (json['memo'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SessionType _parseSessionType(dynamic value) {
    if (value is String) {
      for (final type in SessionType.values) {
        if (type.name == value) {
          return type;
        }
      }
    }
    return SessionType.practice;
  }

  static DateTime _parseDateTime(dynamic value, DateTime fallback) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return fallback;
      }
    }
    return fallback;
  }
}
