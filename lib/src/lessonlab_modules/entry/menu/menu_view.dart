import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/new_material_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/menu_card.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';

import 'package:provider/provider.dart';

class MenuView extends StatelessWidget {
  MenuView({
    super.key,
  });

  static const routeName = '/';

  late MenuViewModel _menuViewModel;

  @override
  Widget build(BuildContext context) {
    _menuViewModel = context.watch<MenuViewModel>();
    double cardWidth = MediaQuery.of(context).size.width * 0.25;
    double cardHeight = MediaQuery.of(context).size.height * 0.25;

    var newMaterialButton = NewMaterialButton(
      onPressed: () {
        _menuViewModel.navigateToUploadScreen(context);
      },
      icon: const Icon(Icons.add),
      text: 'Create',
    );

    var grid = FutureBuilder<List<Object>>(
      future: Future.wait([
        _menuViewModel.menuModel.lessons,
        _menuViewModel.menuModel.quizzes,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading lesson content');
        } else {
          final List<Object> contents = snapshot.data!;
          final List<LessonModel> lessons = contents[0] as List<LessonModel>;
          final List<QuizModel> quizzes = contents[1] as List<QuizModel>;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 24.0,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: quizzes.length + lessons.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < lessons.length) {
                return FutureBuilder<String>(
                  // * Future builder for TITLE
                  future: lessons[index].title,
                  builder: (context, titleSnapshot) {
                    if (titleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (titleSnapshot.hasError) {
                      return const Text('Error loading lesson title');
                    } else {
                      return FutureBuilder<String>(
                        // * Future builder for CONTENT
                        future: lessons[index].content,
                        builder: (context, contentSnapshot) {
                          if (contentSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (contentSnapshot.hasError) {
                            return const Text('Error loading lesson content');
                          } else {
                            return FutureBuilder<int>(
                              // * Future builder for ID
                              future: lessons[index].id,
                              builder: (context, idSnapshot) {
                                if (contentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (contentSnapshot.hasError) {
                                  return const Text(
                                      'Error loading lesson content');
                                } else {
                                  return MenuCard(
                                    title: titleSnapshot.data!,
                                    content: contentSnapshot.data!,
                                    id: idSnapshot.data!,
                                  );
                                }
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                );
              } else {
                // Handle quizzes similarly if needed
                return Container(); // Placeholder for now
              }
            },
          );
        }
      },
    );

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                newMaterialButton,
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: grid,
            ),
          ],
        ),
      ),
    );
  }
}
