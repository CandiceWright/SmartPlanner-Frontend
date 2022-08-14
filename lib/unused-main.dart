import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'views/Login/welcome_page.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import '/Themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //const MyApp({Key? key}) : super(key: key);

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Set<String> _kIds = <String>{
    'monthly_subscription',
    'yearly_subscription'
  };
  // checks if the API is available on this device
  bool _isAvailable = false;
  // List of users past purchases
  List<PurchaseDetails> _purchases = [];
  late List<ProductDetails> products;
  bool isSubscribed = false;

  @override
  void initState() {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _purchases.addAll(purchaseDetailsList);
      if (_purchases.isNotEmpty) {
        //user is subscribed
        print("I just populatted purchases and here is the size");
        print(_purchases.length);
        bool allPurchasesValid = true;
        for (int i = 0; i < _purchases.length; i++) {
          bool isValid = _verifyPurchases(_purchases[i]);
          if (!isValid) {
            allPurchasesValid = false;
          }
        }
        if (allPurchasesValid) {
          isSubscribed = true;
          _listenToPurchaseUpdated(purchaseDetailsList);
        } else {
          //show error
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      'It looks like there was an issue validating your ssubscription. Please try again.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      }
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  'Oops. It looks like an error occurred. Please try again.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }) as StreamSubscription<List<PurchaseDetails>>;
    //purchasesUpdated();
    initStoreInfo();

    super.initState();
  }

  initStoreInfo() async {
    _isAvailable = await InAppPurchase.instance.isAvailable();
    if (!_isAvailable) {
      //show error
    } else {
      getProducts();
      //getPurchasesAndVerify();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // purchasesUpdated() {
  //   final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
  //   _subscription = purchaseUpdated.listen((purchaseDetailsList) {
  //     _listenToPurchaseUpdated(purchaseDetailsList);
  //   }, onDone: () {
  //     _subscription.cancel();
  //   }, onError: (error) {
  //     // handle error here.
  //   }) as StreamSubscription<List<PurchaseDetails>>;
  // }

  void _listenToPurchaseUpdated(purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //_showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //_handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchases(purchaseDetails);

          if (valid) {
            //_deliverProduct(purchaseDetails);
            await InAppPurchase.instance.completePurchase(purchaseDetails);
          } else {
            //_handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  bool _verifyPurchases(PurchaseDetails purchaseDetails) {
    //PurchaseDetails purchase = _hasUserPurchased(testID);
    if (purchaseDetails != null &&
        purchaseDetails.status == PurchaseStatus.purchased) {
      return true;
    }
    return false;
  }

  getProducts() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    setState(() {
      products = response.productDetails;
    });
  }

  // getPurchasesAndVerify() {
  //   InAppPurchase.instance.
  // }

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
          );
        });
  }
}
