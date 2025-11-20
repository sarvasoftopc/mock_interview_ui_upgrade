import 'dart:convert';

class Question {
  final String id;
  final String text;
  final List<String> tags;
  final String difficulty;
  final String tts;
  Question({
    required this.id,
    required this.text,
    required this.tags,
    required this.difficulty,
    required this.tts
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') || !json.containsKey('text')) {
      throw FormatException('Missing required fields in Question JSON');
    }
    final tagsRaw = json['tags'];
    final tags = tagsRaw is List ? List<String>.from(tagsRaw.map((e) => e.toString())) : <String>[];
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      tags: tags,
      difficulty: json['difficulty']?.toString() ?? 'unknown',
      tts: json['tts']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'tags': tags, 'difficulty': difficulty};

  @override
  String toString() => jsonEncode(toJson());
}
