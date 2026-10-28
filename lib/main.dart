import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/nasaq_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: NasaqApp(),
    ),
  );
}

class NasaqApp extends StatelessWidget {
  const NasaqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'نَسَق | NASAQ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: NasaqTheme.lightPaperTheme,
      routerConfig: appRouter,
    );
  }
}
