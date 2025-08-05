/// Dashboard Statistics Model
/// Dashboard'da görüntülenecek istatistikleri tutar
class DashboardStatsModel {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final int todayRides;
  final int weeklyRides;
  final int monthlyRides;
  final int totalRides;
  final double todayExpenses;
  final double weeklyExpenses;
  final double monthlyExpenses;
  final double todayProfit;
  final double weeklyProfit;
  final double monthlyProfit;
  final DateTime lastRideDate;
  final DateTime lastUpdated;

  const DashboardStatsModel({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.todayRides,
    required this.weeklyRides,
    required this.monthlyRides,
    required this.totalRides,
    required this.todayExpenses,
    required this.weeklyExpenses,
    required this.monthlyExpenses,
    required this.todayProfit,
    required this.weeklyProfit,
    required this.monthlyProfit,
    required this.lastRideDate,
    required this.lastUpdated,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      todayRides: json['todayRides'] ?? 0,
      weeklyRides: json['weeklyRides'] ?? 0,
      monthlyRides: json['monthlyRides'] ?? 0,
      totalRides: json['totalRides'] ?? 0,
      todayExpenses: (json['todayExpenses'] as num?)?.toDouble() ?? 0.0,
      weeklyExpenses: (json['weeklyExpenses'] as num?)?.toDouble() ?? 0.0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      todayProfit: (json['todayProfit'] as num?)?.toDouble() ?? 0.0,
      weeklyProfit: (json['weeklyProfit'] as num?)?.toDouble() ?? 0.0,
      monthlyProfit: (json['monthlyProfit'] as num?)?.toDouble() ?? 0.0,
      lastRideDate: json['lastRideDate'] != null
          ? DateTime.parse(json['lastRideDate'])
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayEarnings': todayEarnings,
      'weeklyEarnings': weeklyEarnings,
      'monthlyEarnings': monthlyEarnings,
      'totalEarnings': totalEarnings,
      'todayRides': todayRides,
      'weeklyRides': weeklyRides,
      'monthlyRides': monthlyRides,
      'totalRides': totalRides,
      'todayExpenses': todayExpenses,
      'weeklyExpenses': weeklyExpenses,
      'monthlyExpenses': monthlyExpenses,
      'todayProfit': todayProfit,
      'weeklyProfit': weeklyProfit,
      'monthlyProfit': monthlyProfit,
      'lastRideDate': lastRideDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  DashboardStatsModel copyWith({
    double? todayEarnings,
    double? weeklyEarnings,
    double? monthlyEarnings,
    double? totalEarnings,
    int? todayRides,
    int? weeklyRides,
    int? monthlyRides,
    int? totalRides,
    double? todayExpenses,
    double? weeklyExpenses,
    double? monthlyExpenses,
    double? todayProfit,
    double? weeklyProfit,
    double? monthlyProfit,
    DateTime? lastRideDate,
    DateTime? lastUpdated,
  }) {
    return DashboardStatsModel(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayRides: todayRides ?? this.todayRides,
      weeklyRides: weeklyRides ?? this.weeklyRides,
      monthlyRides: monthlyRides ?? this.monthlyRides,
      totalRides: totalRides ?? this.totalRides,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      weeklyExpenses: weeklyExpenses ?? this.weeklyExpenses,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      todayProfit: todayProfit ?? this.todayProfit,
      weeklyProfit: weeklyProfit ?? this.weeklyProfit,
      monthlyProfit: monthlyProfit ?? this.monthlyProfit,
      lastRideDate: lastRideDate ?? this.lastRideDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Empty stats for initialization
  static DashboardStatsModel empty() {
    final now = DateTime.now();
    return DashboardStatsModel(
      todayEarnings: 0.0,
      weeklyEarnings: 0.0,
      monthlyEarnings: 0.0,
      totalEarnings: 0.0,
      todayRides: 0,
      weeklyRides: 0,
      monthlyRides: 0,
      totalRides: 0,
      todayExpenses: 0.0,
      weeklyExpenses: 0.0,
      monthlyExpenses: 0.0,
      todayProfit: 0.0,
      weeklyProfit: 0.0,
      monthlyProfit: 0.0,
      lastRideDate: now,
      lastUpdated: now,
    );
  }

  @override
  String toString() {
    return 'DashboardStatsModel('
        'todayEarnings: $todayEarnings, '
        'weeklyEarnings: $weeklyEarnings, '
        'monthlyEarnings: $monthlyEarnings, '
        'totalRides: $totalRides, '
        'todayRides: $todayRides, '
        'lastUpdated: $lastUpdated'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStatsModel &&
        other.todayEarnings == todayEarnings &&
        other.weeklyEarnings == weeklyEarnings &&
        other.monthlyEarnings == monthlyEarnings &&
        other.totalRides == totalRides &&
        other.todayRides == todayRides;
  }

  @override
  int get hashCode {
    return todayEarnings.hashCode ^
        weeklyEarnings.hashCode ^
        monthlyEarnings.hashCode ^
        totalRides.hashCode ^
        todayRides.hashCode;
  }
}
