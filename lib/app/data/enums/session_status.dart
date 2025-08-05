/// Session durumları
/// - active: Aktif olarak çalışıyor
/// - paused: Molada (ama paket devam ediyor)
/// - completed: Tamamen bitmiş
enum SessionStatus {
  active('active'),
  paused('paused'),
  completed('completed');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SessionStatus.active;
      case 'paused':
        return SessionStatus.paused;
      case 'completed':
        return SessionStatus.completed;
      default:
        throw ArgumentError('Geçersiz session durumu: $value');
    }
  }

  String get displayName {
    switch (this) {
      case SessionStatus.active:
        return 'Aktif';
      case SessionStatus.paused:
        return 'Molada';
      case SessionStatus.completed:
        return 'Tamamlandı';
    }
  }

  bool get isActive => this == SessionStatus.active;
  bool get isPaused => this == SessionStatus.paused;
  bool get isCompleted => this == SessionStatus.completed;
  bool get isRunning =>
      this == SessionStatus.active || this == SessionStatus.paused;
}

extension SessionStatusExtension on SessionStatus {
  String toJson() => value;

  static SessionStatus fromJson(String json) => SessionStatus.fromString(json);
}
