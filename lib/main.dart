import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/notes/notes_provider.dart';
import 'package:serenity_diary/providers/water/water_provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/providers/notebooks/notebooks_provider.dart';
import 'package:serenity_diary/screens/home/home_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => NotebooksProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          FairyTheme.currentTheme = prefs.appTheme;

          return MaterialApp(
            key: ValueKey(prefs.appTheme),
            debugShowCheckedModeBanner: false,
            title: 'Serenity',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: FairyTheme.lavender,
                brightness: prefs.appTheme == ThemeType.nightForest ? Brightness.dark : Brightness.light,
              ),
              textTheme: GoogleFonts.nunitoTextTheme(),
              scaffoldBackgroundColor: FairyTheme.bgSage,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
