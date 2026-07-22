import 'dart:convert';

class Note {
  final int id;
  final String title;
  final String rawTranscript;
  final String summaryJson;
  final int createdAt;

  Note({
    required this.id,
    required this.title,
    required this.rawTranscript,
    required this.summaryJson,
    required this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      title: map['title'] as String,
      rawTranscript: map['raw_transcript'] as String,
      summaryJson: map['summary_json'] as String,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'raw_transcript': rawTranscript,
      'summary_json': summaryJson,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> get parsedSummary {
    try {
      return jsonDecode(summaryJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
