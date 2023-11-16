import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class LessonResultViewModel with ChangeNotifier {
  late Future<String> mdContents;
  late Future<String> cssContents;

  LessonResultViewModel() {
    // Load data when the view model is created
    loadContents();
  }

  Future<void> loadContents() async {
    try {
      mdContents = loadFileContents('assets/test.md');
      cssContents = loadFileContents('assets/styles/markdown.css');
      
      // Notify listeners that the data has been loaded
      notifyListeners();
    } catch (error) {
      // Handle errors
      developer.log('Error loading contents: $error');
    }
  }
}

Future<String> loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}