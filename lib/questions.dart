import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

Future<List<Question>> loadQuestions(String filePath) async {
  try {
    // Lire le contenu du fichier
    String content = await rootBundle.loadString(filePath);

    // Analyser le contenu JSON
    List<dynamic> questionsJson = json.decode(content);

    // Convertir les données JSON en objets Question
    List<Question> questions = questionsJson.map((json) {
      return Question(
        questionText: json['questionText'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctOptionIndex: json['correctOptionIndex'] ?? -1,
      );
    }).toList();

    return questions;
  } catch (e) {
    print('Erreur lors du chargement des questions depuis $filePath: $e');
    return [];
  }
}
