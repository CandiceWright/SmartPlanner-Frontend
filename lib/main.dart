import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Login/login.dart';
import 'views/Login/welcome_page.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import '/Themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //PlannerService.subscriptionProvider = SubscriptionsProvider();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeCollection = ThemeCollection(
      themes: {
        AppThemes.pink: ThemeData(
          //cardColor: Colors.pink.shade50,
          cardColor: AppThemes().pinkAccentSwatch,
          // colorScheme: ColorScheme.fromSwatch(
          //   primarySwatch: AppThemes().pinkPrimarySwatch,

          // ),
          primarySwatch: AppThemes().pinkPrimarySwatch,
          //splashColor: Colors.pink.shade50,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0),
        ),
        AppThemes.blue: ThemeData(
          cardColor: AppThemes().blueAccentSwatch,
          primarySwatch: AppThemes().bluePrimarySwatch,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0),
        ),
        AppThemes.green: ThemeData(
          cardColor: AppThemes().greenAccentSwatch,
          primarySwatch: AppThemes().greenPrimarySwatch,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0),
        ),
        AppThemes.orange: ThemeData(
          cardColor: AppThemes().orangeAccentSwatch,
          primarySwatch: AppThemes().orangePrimarySwatch,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0),
        ),
        AppThemes.grey: ThemeData(
          cardColor: AppThemes().greyAccentSwatch,
          primarySwatch: AppThemes().greyPrimarySwatch,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0),
        ),
      },
    );
    return DynamicTheme(
        themeCollection: themeCollection,
        defaultThemeId: AppThemes.pink, // optional, default id is 0
        builder: (context, theme) {
          return MaterialApp(
            title: 'Planner App',
            theme: theme,
            debugShowCheckedModeBanner: false,
            // theme: ThemeData(
            //   // This is the theme of your application.
            //   //
            //   // Try running your application with "flutter run". You'll see the
            //   // application has a blue toolbar. Then, without quitting the app, try
            //   // changing the primarySwatch below to Colors.green and then invoke
            //   // "hot reload" (press "r" in the console where you ran "flutter run",
            //   // or simply save your changes to "hot reload" in a Flutter IDE).
            //   // Notice that the counter didn't reset back to zero; the application
            //   // is not restarted.
            //   //primaryColor: Colors.pink.shade300,
            //   primarySwatch:
            //       PlannerService.sharedInstance.user.theme.primaryColor,
            //   //primarySwatch: Color(0xFFF06292),
            //   backgroundColor: Colors.white,
            //   scaffoldBackgroundColor: Colors.white,
            //   appBarTheme: AppBarTheme(
            //       backgroundColor: Colors.white,
            //       centerTitle: false,
            //       titleTextStyle: const TextStyle(
            //           color: Colors.black,
            //           fontSize: kToolbarHeight / 2,
            //           fontWeight: FontWeight.bold),
            //       elevation: 0),
            // ),
            home: const WelcomePage(),
            // routes: {
            //   '/login': (context) => const LoginPage(),
            // },
          );
        });
  }
}
