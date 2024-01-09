import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_models/question_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/components/number_field.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
// import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:rinf/rinf.dart';

class QuizPageViewModel extends ChangeNotifier {
  QuizPageViewModel();
  final QuizPageConnectionOrchestrator orchestrator =
      QuizPageConnectionOrchestrator();
  final QuizPageModel model = QuizPageModel();

  // TODO: GET QUESTIONS FROM BACKEND

  List<QuestionModel?> get questions {
    developer.log("${model.quiz.id}", name: "get questions");
    return model.quiz.questions;
  }
  // get questions => _questions;

  void loadQuizModel() async {
    // orchestrator.getQuizModel().then((value) => model.quiz = value);
    developer.log("load quiz model", name: "function");
    model.quiz = await orchestrator.getQuizModel();
  }

  final _questions = const [
    {
      // `QuestionModel`
      'question': 'How long is New Zealand’s Ninety Mile Beach?',
      'answers': [
        {
          'answerText': '88km, so 55 miles long.',
          'isCorrect': true,
          'isSelected': false
        },
        {
          'answerText': '55km, so 34 miles long.',
          'isCorrect': false,
          'isSelected': false
        },
        {
          'answerText': '90km, so 56 miles long.',
          'isCorrect': false,
          'isSelected': false
        },
      ],
    },
    {
      'question':
          'In which month does the German festival of Oktoberfest mostly take place?',
      'answers': [
        {'answerText': 'January', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'October', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'September', 'isCorrect': true, 'isSelected': false},
      ],
    },
    {
      'question': 'Who composed the music for Sonic the Hedgehog 3?',
      'answers': [
        {
          'answerText': 'Britney Spears',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'Timbaland', 'isCorrect': false, 'isSelected': false},
        {
          'answerText': 'Michael Jackson',
          'isCorrect': true,
          'isSelected': false
        },
      ],
    },
    {
      'question':
          'In Georgia (the state), it’s illegal to eat what with a fork?',
      'answers': [
        {'answerText': 'Hamburgers', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Fried chicken', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'Pizza', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question':
          'Which part of his body did musician Gene Simmons from Kiss insure for one million dollars?',
      'answers': [
        {'answerText': 'His tongue', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'His leg', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'His butt', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'In which country are Panama hats made?',
      'answers': [
        {'answerText': 'Ecuador', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'Panama (duh)', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Portugal', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'From which country do French fries originate?',
      'answers': [
        {'answerText': 'Belgium', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'France (duh)', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Switzerland', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'Which sea creature has three hearts?',
      'answers': [
        {
          'answerText': 'Great White Sharks',
          'isCorrect': false,
          'isSelected': false
        },
        {
          'answerText': 'Killer Whales',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'The Octopus', 'isCorrect': true, 'isSelected': false},
      ],
    },
    {
      'question': 'Which European country eats the most chocolate per capita?',
      'answers': [
        {'answerText': 'Belgium', 'isCorrect': false, 'isSelected': false},
        {
          'answerText': 'The Netherlands',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'Switzerland', 'isCorrect': true, 'isSelected': false},
      ],
    },
  ];
}

/*
  final _questions = const [
    {
      // `QuestionModel`
      'question': 'How long is New Zealand’s Ninety Mile Beach?',
      'answers': [
        {
          'answerText': '88km, so 55 miles long.',
          'isCorrect': true,
          'isSelected': false
        },
        {
          'answerText': '55km, so 34 miles long.',
          'isCorrect': false,
          'isSelected': false
        },
        {
          'answerText': '90km, so 56 miles long.',
          'isCorrect': false,
          'isSelected': false
        },
      ],
    },
    {
      'question':
          'In which month does the German festival of Oktoberfest mostly take place?',
      'answers': [
        {'answerText': 'January', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'October', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'September', 'isCorrect': true, 'isSelected': false},
      ],
    },
    {
      'question': 'Who composed the music for Sonic the Hedgehog 3?',
      'answers': [
        {
          'answerText': 'Britney Spears',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'Timbaland', 'isCorrect': false, 'isSelected': false},
        {
          'answerText': 'Michael Jackson',
          'isCorrect': true,
          'isSelected': false
        },
      ],
    },
    {
      'question':
          'In Georgia (the state), it’s illegal to eat what with a fork?',
      'answers': [
        {'answerText': 'Hamburgers', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Fried chicken', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'Pizza', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question':
          'Which part of his body did musician Gene Simmons from Kiss insure for one million dollars?',
      'answers': [
        {'answerText': 'His tongue', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'His leg', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'His butt', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'In which country are Panama hats made?',
      'answers': [
        {'answerText': 'Ecuador', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'Panama (duh)', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Portugal', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'From which country do French fries originate?',
      'answers': [
        {'answerText': 'Belgium', 'isCorrect': true, 'isSelected': false},
        {'answerText': 'France (duh)', 'isCorrect': false, 'isSelected': false},
        {'answerText': 'Switzerland', 'isCorrect': false, 'isSelected': false},
      ],
    },
    {
      'question': 'Which sea creature has three hearts?',
      'answers': [
        {
          'answerText': 'Great White Sharks',
          'isCorrect': false,
          'isSelected': false
        },
        {
          'answerText': 'Killer Whales',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'The Octopus', 'isCorrect': true, 'isSelected': false},
      ],
    },
    {
      'question': 'Which European country eats the most chocolate per capita?',
      'answers': [
        {'answerText': 'Belgium', 'isCorrect': false, 'isSelected': false},
        {
          'answerText': 'The Netherlands',
          'isCorrect': false,
          'isSelected': false
        },
        {'answerText': 'Switzerland', 'isCorrect': true, 'isSelected': false},
      ],
    },
  ];

*/