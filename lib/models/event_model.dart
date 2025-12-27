class Event {
  final int? id;
  final String title;
  final String description;
  final String type; // 'announcement' or 'poll'
  final DateTime createdAt;
  final DateTime? endDate;
  final bool isActive;
  final List<PollOption>? pollOptions;
  final Map<int, int>? userVotes; // userId -> optionId

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.endDate,
    this.isActive = true,
    this.pollOptions,
    this.userVotes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        type: json['type'] ?? 'announcement',
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : DateTime.now(),
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        isActive: json['is_active'] == true || json['is_active'] == 1,
        pollOptions: _parsePollOptions(json['poll_options']),
        userVotes: _parseUserVotes(json['user_votes']),
      );
    } catch (e) {
      print('Error parsing event: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static List<PollOption>? _parsePollOptions(dynamic pollOptionsData) {
    if (pollOptionsData == null) return null;
    
    if (pollOptionsData is List) {
      return pollOptionsData.map((e) => PollOption.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    return null;
  }

  static Map<int, int>? _parseUserVotes(dynamic userVotesData) {
    if (userVotesData == null) return null;
    
    if (userVotesData is Map) {
      final result = <int, int>{};
      userVotesData.forEach((key, value) {
        final userId = key is String ? int.parse(key) : key as int;
        final optionId = value is String ? int.parse(value) : value as int;
        result[userId] = optionId;
      });
      return result;
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'poll_options': pollOptions?.map((e) => e.toJson()).toList(),
      'user_votes': userVotes,
    };
  }
}

class PollOption {
  final int? id;
  final String text;
  final int votes;

  PollOption({
    this.id,
    required this.text,
    this.votes = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    try {
      return PollOption(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        text: json['text'] ?? '',
        votes: json['votes'] is String ? int.parse(json['votes']) : (json['votes'] ?? 0),
      );
    } catch (e) {
      print('Error parsing poll option: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }
}