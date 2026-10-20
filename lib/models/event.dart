class Event {
  final String id;
  final String title;
  final String sport;
  final DateTime startTime;
  final DateTime? endTime;
  final String? homeTeam;
  final String? awayTeam;
  final String? homeScore;
  final String? awayScore;
  final bool isLive;
  final String channelId;
  final String channelName;
  final String? logoUrl;
  final String? thumbnailUrl;
  final String? description;

  Event({
    required this.id,
    required this.title,
    required this.sport,
    required this.startTime,
    this.endTime,
    this.homeTeam,
    this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.isLive,
    required this.channelId,
    required this.channelName,
    this.logoUrl,
    this.thumbnailUrl,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? json['channel_id']?.toString() ?? '',
      title: json['event'] ?? json['title'] ?? 'Evento',
      sport: json['sport'] ?? 'Deportes',
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time']) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'])
          : null,
      homeTeam: json['home_team'],
      awayTeam: json['away_team'],
      homeScore: json['home_score'],
      awayScore: json['away_score'],
      isLive: json['is_live'] ?? false,
      channelId: json['channel_id']?.toString() ?? '',
      channelName: json['channel_name'] ?? json['title'] ?? 'Canal',
      logoUrl: json['logo_url'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sport': sport,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'home_team': homeTeam,
      'away_team': awayTeam,
      'home_score': homeScore,
      'away_score': awayScore,
      'is_live': isLive,
      'channel_id': channelId,
      'channel_name': channelName,
      'logo_url': logoUrl,
      'thumbnail_url': thumbnailUrl,
      'description': description,
    };
  }

  String get displayTime {
    final now = DateTime.now();
    final diff = startTime.difference(now);
    if (isLive) return 'EN VIVO';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'AHORA';
  }

  String get scoreDisplay {
    if (homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return '';
  }

  bool get hasScore => homeScore != null && awayScore != null;
}

class Channel {
  final String id;
  final String name;
  final String? logoUrl;

  Channel({required this.id, required this.name, this.logoUrl});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['channel_id']?.toString() ?? '',
      name: json['channel_name'] ?? 'Canal',
      logoUrl: json['logo_url'],
    );
  }
}
