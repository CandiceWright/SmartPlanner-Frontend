import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:http/http.dart' as http;

class SubscriptionsProvider extends ChangeNotifier {
  // save the stream to cancel it onDone
  late StreamSubscription _streamSubscription;
  ValueNotifier purchasePending = ValueNotifier(false);
  ValueNotifier purchaseSuccess = ValueNotifier(false);
  ValueNotifier purchaseError = ValueNotifier(false);
  ValueNotifier purchaseExpired = ValueNotifier(false);
  ValueNotifier purchaseRestored = ValueNotifier(false);
  ValueNotifier showPurchaseRestored = ValueNotifier(false);
  ValueNotifier receipt = ValueNotifier("");
  bool purchaseInProgress = false;
  List<PurchaseDetails> purchases = [];

  SubscriptionsProvider() {
    //print("I am initializing subscription provider");
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;

    _streamSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      //print("I am listening for purchase details");
      // Handle the purchased subscriptions
      _purchaseUpdate(purchaseDetailsList);
    }, onDone: () {
      _streamSubscription.cancel();
    }, onError: (error) {
      // handle the error
    });
    //should not show restored purchase dialog
    //spurchases = [];
    //InAppPurchase.instance.restorePurchases();
  }

  _purchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    // check each item in the provider list
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      // Sometimes the purchase is not completely done yet, in this case, show the pending UI again.
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //print("purchase is pending");
        purchasePending.value = true;
        purchaseError.value = false;
        purchaseExpired.value = false;
        purchaseSuccess.value = false;
        purchaseRestored.value = false;

        //_showPendingUI();

      } else {
        // The status is NOT pending, lets check for an error
        if (purchaseDetails.status == PurchaseStatus.error) {
          // This happens if you close the app or dismiss the purchase dialog.
          //_handleError(purchaseDetails.error!);
          //print("there was an error");
          purchaseError.value = true;
          purchasePending.value = false;
          purchaseExpired.value = false;
          purchaseSuccess.value = false;
          purchaseRestored.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          //print("item purchased");
          // Huge SUCCESS! This case handles the happy case whenever the user purchased or restored the purchase
          if (purchaseInProgress) {
            _verifyPurchaseAndEnablePremium(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          //print("item restored");
          // Huge SUCCESS! This case handles the happy case whenever the user purchased or restored the purchase
          _verifyRestoredAndEnablePremium(purchaseDetails);
        }

        // Whenever the purchase is done, complete it by calling complete.
        if (purchaseDetails.pendingCompletePurchase) {
          //print("purchase complete");
          purchasePending.value = false;
          purchaseError.value = false;
          purchaseExpired.value = false;
          purchaseSuccess.value = false;
          purchaseRestored.value = false;
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  fetchSubscriptions() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed.
      // This could also be the case if you run the app on emulator.
      // Please use a physical device for testing.
      return;
    }

    // Hardcode subscriptionIds you want to offer.
    const Set<String> _subscriptionIds = <String>{
      'monthly_subscription',
      'yearly_subscription'
    };
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_subscriptionIds);

    if (response.notFoundIDs.isNotEmpty) {
      // IDs that does not exist on the underlying store.
    }

    // all existing product are inside the productDetails.
    List<ProductDetails> products = response.productDetails;

    return products;

    // Store the subscription and notify all listeners
    //notifyListeners();
  }

  purchaseProduct(ProductDetails productDetails) {
    // prepare the PurchaseParam
    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

// Purchase the Subscription
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  //used to check purchase when user goes out of app and comes back in. also during login
  Future<String> verifyPurchase(String receipt) async {
    //String receipt = purchaseDetails.verificationData.serverVerificationData;

    var body = {
      'receipt': receipt,
    };
    var bodyF = jsonEncode(body);
    ////print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/subscription');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    ////print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      ////print(decodedBody);
      int status = decodedBody["status"];
      //print("printing status of subscription veriification");
      //print(status);
      if (status == 0) {
        int expiresDate =
            int.parse(decodedBody["latest_receipt_info"][0]["expires_date_ms"]);
        //print("printing expires date");
        //print(expiresDate);
        int currentDate = DateTime.now().millisecondsSinceEpoch;
        //print(currentDate);
        if (expiresDate < currentDate) {
          //expired
          //purchaseExpired.value = true;
          //print("purchase is expired");
          //return false;
          return "expired";
        } else {
          //print("purchase is good");
          //return true;
          return ("valid");
        }
      } else {
        //error
        //return false;
        return "error";
      }
    } else {
      //500 error, show an alert
      //purchaseError.value = true;
      return "error";
    }
  }

  _verifyPurchaseAndEnablePremium(PurchaseDetails purchaseDetails) async {
    //String receipt = purchaseDetails.verificationData.serverVerificationData;

    var body = {
      'receipt': purchaseDetails.verificationData.serverVerificationData,
    };
    var bodyF = jsonEncode(body);
    ////print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/subscription');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    ////print('Response body: ${response.body}');
    purchaseInProgress = false;

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      ////print(decodedBody);
      int status = decodedBody["status"];
      //print("printing status of subscription veriification");
      //print(status);
      if (status == 0) {
        int expiresDate =
            int.parse(decodedBody["latest_receipt_info"][0]["expires_date_ms"]);
        //print("printing expires date");
        //print(expiresDate);
        int currentDate = DateTime.now().millisecondsSinceEpoch;
        //print(currentDate);
        if (expiresDate < currentDate) {
          //expired
          purchaseExpired.value = true;
          purchaseError.value = false;
          purchasePending.value = false;
          purchaseSuccess.value = false;
          purchaseRestored.value = false;
        } else {
          //purchase is good
          purchaseSuccess.value = true;
          purchaseExpired.value = false;
          purchaseError.value = false;
          purchasePending.value = false;
          purchaseRestored.value = false;
          purchases.add(purchaseDetails);
          receipt.value =
              purchaseDetails.verificationData.serverVerificationData;
        }
      } else if (status == 21006) {
        //expired
        purchaseExpired.value = true;
        purchaseError.value = false;
        purchasePending.value = false;
        purchaseSuccess.value = false;
        purchaseRestored.value = false;
      } else {
        purchaseError.value = true;
        purchaseExpired.value = false;
        purchasePending.value = false;
        purchaseSuccess.value = false;
        purchaseRestored.value = false;
      }
    } else {
      //500 error, show an alert
      purchaseError.value = true;
      purchaseExpired.value = false;
      purchasePending.value = false;
      purchaseSuccess.value = false;
      purchaseRestored.value = false;
    }
  }

  _verifyRestoredAndEnablePremium(PurchaseDetails purchaseDetails) async {
    // check if the purchase is valid by calling your server including the receipt data.
    // bool valid = await _verifyPurchase(purchaseDetails);
    // if (valid) {
    //   // Purchase is valid, time to enable all subscription features.
    //   //_enablePremiumFeatures(purchaseDetails);

    // } else {
    //   // The receipt is not valid. Don't enable any subscription features.
    //   // _handleInvalidPurchase(purchaseDetails);
    // }
    //String receipt = purchaseDetails.verificationData.serverVerificationData;

    var body = {
      'receipt': purchaseDetails.verificationData.serverVerificationData,
    };
    var bodyF = jsonEncode(body);
    ////print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/subscription');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    ////print('Response body: ${response.body}');
    purchaseInProgress = false;

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      ////print(decodedBody);
      int status = decodedBody["status"];
      //print("printing status of subscription veriification");
      //print(status);
      if (status == 0) {
        int expiresDate =
            int.parse(decodedBody["latest_receipt_info"][0]["expires_date_ms"]);
        //print("printing expires date");
        //print(expiresDate);
        int currentDate = DateTime.now().millisecondsSinceEpoch;
        //print(currentDate);
        if (expiresDate < currentDate) {
          //expired
          purchaseExpired.value = true;
          purchaseError.value = false;
          purchasePending.value = false;
          purchaseSuccess.value = false;
          purchaseRestored.value = false;
        } else {
          //good
          purchaseExpired.value = false;
          purchaseError.value = false;
          purchasePending.value = false;
          purchaseSuccess.value = false;
          purchaseRestored.value = true;
          purchases.add(purchaseDetails);
          receipt.value =
              purchaseDetails.verificationData.serverVerificationData;
        }
      } else if (status == 21006) {
        //expired
        purchaseExpired.value = true;
        purchaseError.value = false;
        purchasePending.value = false;
        purchaseSuccess.value = false;
        purchaseRestored.value = false;
      } else {
        //error
        purchaseError.value = true;
        purchaseExpired.value = false;
        purchasePending.value = false;
        purchaseSuccess.value = false;
        purchaseRestored.value = false;
      }
    } else {
      //500 error, show an alert
      purchaseError.value = true;
      purchaseExpired.value = false;
      purchasePending.value = false;
      purchaseSuccess.value = false;
      purchaseRestored.value = false;
    }
  }

  restorePurchases() {
    purchases = [];
    InAppPurchase.instance.restorePurchases();
    //InAppPurchase.instance.();
  }

  listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // Purchased Subscriptions
  }
}

class ReceiptVerificationResponse {
  bool isValid;
  String error;

  ReceiptVerificationResponse(this.isValid, this.error);
}
