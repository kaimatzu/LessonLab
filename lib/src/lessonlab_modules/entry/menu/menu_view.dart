import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/menu_card.dart';

import '../../../settings/settings_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key
      // add menu item here
      });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.25;
    double cardHeight = MediaQuery.of(context).size.height * 0.25;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          toolbarHeight: 120.0,
          title: Row(
            children: [
              const SizedBox(width: 15),
              Image.asset(
                'assets/images/lessonlab_logo_final.jpg',
                width: 100.0,
                height: 100.0,
              ),
              const SizedBox(width: 15),
              const Text(
                'LessonLab',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          centerTitle: false,
          flexibleSpace: Container(),
          backgroundColor: Colors.white,
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(width: 1, color: Colors.black12),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
      ),
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
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('New Material'),
                ),
                // Add more items as needed
              ],
            ),
            const SizedBox(height: 16.0), 
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing:  24.0,
                  childAspectRatio: cardWidth / cardHeight,
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: MenuCard(
                      title: 'Item $index',
                      content: 'Description for Item $index',
                    ),
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
