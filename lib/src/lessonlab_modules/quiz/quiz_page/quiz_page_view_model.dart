import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/components/number_field.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
// import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:rinf/rinf.dart';

class QuizPageViewModel extends ChangeNotifier {
  QuizPageViewModel() {}

  //TODO: GET QUESTIONS FROM BACKEND

  final _questions = const [
    {
      'question': 'How long is New Zealand’s Ninety Mile Beach?',
      'answers': [
        {'answerText': '88km, so 55 miles long.', 'score': true},
        {'answerText': '55km, so 34 miles long.', 'score': false},
        {'answerText': '90km, so 56 miles long.', 'score': false},
      ],
    },
    {
      'question':
          'In which month does the German festival of Oktoberfest mostly take place?',
      'answers': [
        {'answerText': 'January', 'score': false},
        {'answerText': 'October', 'score': false},
        {'answerText': 'September', 'score': true},
      ],
    },
    {
      'question': 'Who composed the music for Sonic the Hedgehog 3?',
      'answers': [
        {'answerText': 'Britney Spears', 'score': false},
        {'answerText': 'Timbaland', 'score': false},
        {'answerText': 'Michael Jackson', 'score': true},
      ],
    },
    {
      'question':
          'In Georgia (the state), it’s illegal to eat what with a fork?',
      'answers': [
        {'answerText': 'Hamburgers', 'score': false},
        {'answerText': 'Fried chicken', 'score': true},
        {'answerText': 'Pizza', 'score': false},
      ],
    },
    {
      'question':
          'Which part of his body did musician Gene Simmons from Kiss insure for one million dollars?',
      'answers': [
        {'answerText': 'His tongue', 'score': true},
        {'answerText': 'His leg', 'score': false},
        {'answerText': 'His butt', 'score': false},
      ],
    },
    {
      'question': 'In which country are Panama hats made?',
      'answers': [
        {'answerText': 'Ecuador', 'score': true},
        {'answerText': 'Panama (duh)', 'score': false},
        {'answerText': 'Portugal', 'score': false},
      ],
    },
    {
      'question': 'From which country do French fries originate?',
      'answers': [
        {'answerText': 'Belgium', 'score': true},
        {'answerText': 'France (duh)', 'score': false},
        {'answerText': 'Switzerland', 'score': false},
      ],
    },
    {
      'question': 'Which sea creature has three hearts?',
      'answers': [
        {'answerText': 'Great White Sharks', 'score': false},
        {'answerText': 'Killer Whales', 'score': false},
        {'answerText': 'The Octopus', 'score': true},
      ],
    },
    {
      'question': 'Which European country eats the most chocolate per capita?',
      'answers': [
        {'answerText': 'Belgium', 'score': false},
        {'answerText': 'The Netherlands', 'score': false},
        {'answerText': 'Switzerland', 'score': true},
      ],
    },
  ];

  get questions => _questions;
}
