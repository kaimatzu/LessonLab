import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/new_material_button.dart';
import 'package:lessonlab/src/global_components/route_animation.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/menu_card.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/new_material_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:provider/provider.dart';

class MenuView extends StatelessWidget {
  const MenuView({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final menuViewModel = context.watch<MenuViewModel>();
    double cardWidth = MediaQuery.of(context).size.width * 0.25;
    double cardHeight = MediaQuery.of(context).size.height * 0.25;

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
                NewMaterialButton(
                  onPressed: () {
                    menuViewModel.newMaterial(context);
                  },
                  icon: const Icon(Icons.add),
                  text: 'New Material',
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 24.0,
                  childAspectRatio: cardWidth / cardHeight,
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  // return SizedBox(
                  //   width: cardWidth,
                  //   height: cardHeight,
                  //   child: MenuCard(
                  //     title: 'Item $index',
                  //     content: 'Description for Item $index',
                  //   ),
                  // );
                  return MenuCard(
                    title: 'Item $index',
                    content: 'Description for Item $index',
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
