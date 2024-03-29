import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LessonLabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonLabAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100.0,
      title: Row(
        children: [
          const SizedBox(width: 15),
          SvgPicture.asset(
            'assets/svg/lessonlab_logo_final.svg',
            width: 40.0,
            height: 40.0,
          ),
          const SizedBox(width: 15),
          const Text(
            'LessonLab',
            style: TextStyle(
              color: Color.fromRGBO(49, 51, 56, 1),
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Calibri',
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 206, 45, 0.6),
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      backgroundColor: Colors.white,     
      elevation: 0,
      shape: const Border(),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
