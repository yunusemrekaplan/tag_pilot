/// Report Model - Rapor verilerini tutar
class ReportModel {
  final String id;
  final String title;
  final String type; // 'daily', 'weekly', 'monthly', 'custom'
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String? userId;

  const ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.createdAt,
    this.userId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      data: json['data'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    String? userId,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}

/// Chart Data Model - Grafik verilerini tutar
class ChartDataModel {
  final String label;
  final double value;
  final String? color;
  final Map<String, dynamic>? additionalData;

  const ChartDataModel({
    required this.label,
    required this.value,
    this.color,
    this.additionalData,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      color: json['color'],
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color,
      'additionalData': additionalData,
    };
  }
}

/// Analytics Model - Analitik verilerini tutar
class AnalyticsModel {
  final Map<String, dynamic> summary;
  final List<ChartDataModel> trends;
  final Map<String, dynamic> comparisons;
  final List<String> insights;
  final Map<String, dynamic> recommendations;

  const AnalyticsModel({
    required this.summary,
    required this.trends,
    required this.comparisons,
    required this.insights,
    required this.recommendations,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      summary: json['summary'] ?? {},
      trends: (json['trends'] as List<dynamic>?)?.map((e) => ChartDataModel.fromJson(e)).toList() ?? [],
      comparisons: json['comparisons'] ?? {},
      insights: List<String>.from(json['insights'] ?? []),
      recommendations: json['recommendations'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'trends': trends.map((e) => e.toJson()).toList(),
      'comparisons': comparisons,
      'insights': insights,
      'recommendations': recommendations,
    };
  }
}

/// Trend Data Model - Trend verilerini tutar
class TrendDataModel {
  final DateTime date;
  final double earnings;
  final double profit;
  final double distance;
  final double expenses;
  final int rideCount;

  const TrendDataModel({
    required this.date,
    required this.earnings,
    required this.profit,
    required this.distance,
    required this.expenses,
    required this.rideCount,
  });

  factory TrendDataModel.fromJson(Map<String, dynamic> json) {
    return TrendDataModel(
      date: DateTime.parse(json['date']),
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
      rideCount: json['rideCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'earnings': earnings,
      'profit': profit,
      'distance': distance,
      'expenses': expenses,
      'rideCount': rideCount,
    };
  }
}

/// Comparison Data Model - Karşılaştırma verilerini tutar
class ComparisonDataModel {
  final String period1;
  final String period2;
  final Map<String, double> period1Data;
  final Map<String, double> period2Data;
  final Map<String, double> differences;
  final Map<String, double> percentages;

  const ComparisonDataModel({
    required this.period1,
    required this.period2,
    required this.period1Data,
    required this.period2Data,
    required this.differences,
    required this.percentages,
  });

  factory ComparisonDataModel.fromJson(Map<String, dynamic> json) {
    return ComparisonDataModel(
      period1: json['period1'] ?? '',
      period2: json['period2'] ?? '',
      period1Data: Map<String, double>.from(json['period1Data'] ?? {}),
      period2Data: Map<String, double>.from(json['period2Data'] ?? {}),
      differences: Map<String, double>.from(json['differences'] ?? {}),
      percentages: Map<String, double>.from(json['percentages'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period1': period1,
      'period2': period2,
      'period1Data': period1Data,
      'period2Data': period2Data,
      'differences': differences,
      'percentages': percentages,
    };
  }
}
