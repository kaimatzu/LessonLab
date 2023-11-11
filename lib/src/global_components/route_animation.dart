import 'package:flutter/material.dart';

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == Navigator.defaultRouteName) {
      return child;
    }

    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var fadeAnimation = animation.drive(tween);

    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }
}
