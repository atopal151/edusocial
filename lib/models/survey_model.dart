class SurveyModel {
  final int id;
  final String title;
  final bool multipleChoice;
  final List<String> choices;
  final List<SurveyChoice> choiceResults;
  final String senderName;
  final String senderUsername;
  final String senderAvatar;
  final DateTime createdAt;
  final bool isAnswered;

  SurveyModel({
    required this.id,
    required this.title,
    required this.multipleChoice,
    required this.choices,
    required this.choiceResults,
    required this.senderName,
    required this.senderUsername,
    required this.senderAvatar,
    required this.createdAt,
    required this.isAnswered,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      multipleChoice: json['multiple_choice'] ?? false,
      choices: List<String>.from(json['choices'] ?? []),
      choiceResults: (json['choice_results'] as List<dynamic>?)
          ?.map((e) => SurveyChoice.fromJson(e))
          .toList() ?? [],
      senderName: json['sender_name'] ?? '',
      senderUsername: json['sender_username'] ?? '',
      senderAvatar: json['sender_avatar'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isAnswered: json['is_answered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'multiple_choice': multipleChoice,
      'choices': choices,
      'choice_results': choiceResults.map((e) => e.toJson()).toList(),
      'sender_name': senderName,
      'sender_username': senderUsername,
      'sender_avatar': senderAvatar,
      'created_at': createdAt.toIso8601String(),
      'is_answered': isAnswered,
    };
  }
}

class SurveyChoice {
  final String choice;
  final int voteCount;
  final double percentage;
  final bool isSelected;

  SurveyChoice({
    required this.choice,
    required this.voteCount,
    required this.percentage,
    required this.isSelected,
  });

  factory SurveyChoice.fromJson(Map<String, dynamic> json) {
    return SurveyChoice(
      choice: json['choice'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      isSelected: json['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choice': choice,
      'vote_count': voteCount,
      'percentage': percentage,
      'is_selected': isSelected,
    };
  }
}
