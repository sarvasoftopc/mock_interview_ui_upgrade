// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'per_answer_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerAnswerAnalysis _$PerAnswerAnalysisFromJson(Map<String, dynamic> json) =>
    PerAnswerAnalysis(
      relevance: (json['relevance'] as num).toInt(),
      completeness: (json['completeness'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toInt(),
      fluency: (json['fluency'] as num).toInt(),
      confidence: (json['confidence'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      model_answer: json['model_answer'] as String,
      question_id: json['question_id'] as String,
      question: json['question'] as String,
      candidate_answer: json['candidate_answer'] as String,
      feedback: json['feedback'] as String,
    );

Map<String, dynamic> _$PerAnswerAnalysisToJson(PerAnswerAnalysis instance) =>
    <String, dynamic>{
      'relevance': instance.relevance,
      'completeness': instance.completeness,
      'accuracy': instance.accuracy,
      'fluency': instance.fluency,
      'confidence': instance.confidence,
      'score': instance.score,
      'model_answer': instance.model_answer,
      'candidate_answer': instance.candidate_answer,
      'question_id': instance.question_id,
      'question': instance.question,
      'feedback': instance.feedback,
    };
