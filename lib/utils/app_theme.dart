import 'package:flutter/material.dart';

// Gold Gradient Colors
const Color goldStart = Color(0xFFAE8625);
const Color goldMiddle1 = Color(0xFFF7EF8A);
const Color goldMiddle2 = Color(0xFFD2AC47);
const Color goldEnd = Color(0xFFEDC967);

// Gold Gradient - Linear (for backgrounds, buttons, etc.)
const LinearGradient goldGradient = LinearGradient(
  colors: [goldStart, goldMiddle1, goldMiddle2, goldEnd],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// Use the first color of the gradient as the seed color
const Color goldSeedColor = goldStart;

final ColorScheme goldColorScheme = ColorScheme.fromSeed(
  seedColor: goldSeedColor,
  brightness: Brightness.light,
);

final ThemeData goldTheme = ThemeData(
  colorScheme: goldColorScheme,
  useMaterial3: true,
  // Optionally, you can further customize the theme here
);
