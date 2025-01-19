import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // *****************
  // Static Colors
  // *****************
  static final Color _lightPrimaryColor = Colors.grey.shade100;
  static final Color _lightPrimaryVariantColor = Colors.grey.shade400;
  static const Color _lightOnPrimaryColor = Colors.black;
  static const Color _lightTextColorPrimary = Colors.black;
  static const Color _appbarColorLight = Colors.black;

  // static final Color _darkPrimaryColor = Colors.grey.shade900;
  // static final Color _darkPrimaryVariantColor = Colors.grey.shade700;
  // static const Color _darkOnPrimaryColor = Colors.white;
  // static const Color _darkTextColorPrimary = Colors.white;
  // static final Color _appbarColorDark = Colors.grey.shade800;

  static const Color _iconColor = Colors.white;

  // *****************
  // Text Style - Light
  // *****************
  // static const TextStyle _lightHeadingText = TextStyle(
  //   color: _lightTextColorPrimary,
  //   fontFamily: "Rubik",
  //   fontSize: 20,
  //   fontWeight: FontWeight.bold,
  // );
  //
  // static const TextStyle _lightBodyText = TextStyle(
  //   color: _lightTextColorPrimary,
  //   fontFamily: "Rubik",
  //   fontStyle: FontStyle.italic,
  //   fontWeight: FontWeight.bold,
  //   fontSize: 16,
  // );
  //
  // static const TextTheme _lightTextTheme = TextTheme(
  //   headlineLarge: _lightHeadingText,
  //   bodyLarge: _lightBodyText,
  // );

  // *****************
  // Text Style - Dark
  // *****************
  // static final TextStyle _darkThemeHeadingTextStyle =
  //     _lightHeadingText.copyWith(color: _darkTextColorPrimary);
  //
  // static final TextStyle _darkThemeBodyTextStyle =
  //     _lightBodyText.copyWith(color: _darkTextColorPrimary);
  //
  // static final TextTheme _darkTextTheme = TextTheme(
  //   headlineLarge: _darkThemeHeadingTextStyle,
  //   bodyLarge: _darkThemeBodyTextStyle,
  // );

  // *****************
  // Theme light/dark
  // *****************

  static final ThemeData lightTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.grey.shade300,
      selectionHandleColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: _iconColor),
    ),
    colorScheme: const ColorScheme.light(),
  );
  //
  // static final ThemeData darkTheme = ThemeData(
  //   scaffoldBackgroundColor: _darkPrimaryColor,
  //   textSelectionTheme: TextSelectionThemeData(
  //     selectionColor: Colors.grey.shade300,
  //     selectionHandleColor: Colors.black,
  //   ),
  //   appBarTheme: AppBarTheme(
  //     color: _appbarColorDark,
  //     iconTheme: const IconThemeData(color: _iconColor),
  //   ),
  //   colorScheme: ColorScheme.dark(
  //     primary: _darkPrimaryColor,
  //     onPrimary: _darkOnPrimaryColor,
  //     secondary: _darkPrimaryVariantColor,
  //     primaryContainer: _darkPrimaryVariantColor,
  //   ),
  //   //textTheme: _darkTextTheme,
  //   bottomAppBarTheme: BottomAppBarTheme(color: _appbarColorDark),
  // );
}
