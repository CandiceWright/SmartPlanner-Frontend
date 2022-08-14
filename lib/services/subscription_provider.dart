import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionsProvider extends ChangeNotifier {
  // save the stream to cancel it onDone
  late StreamSubscription _streamSubscription;
  ValueNotifier purchasePending = ValueNotifier(false);
  ValueNotifier purchaseSuccess = ValueNotifier(false);
  ValueNotifier purchaseError = ValueNotifier(false);
  ValueNotifier purchaseRestored = ValueNotifier(false);
  List<String> purchases = [];

  SubscriptionsProvider() {
    print("I am initializing subscription provider");
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;

    _streamSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      // Handle the purchased subscriptions
      _purchaseUpdate(purchaseDetailsList);
    }, onDone: () {
      _streamSubscription.cancel();
    }, onError: (error) {
      // handle the error
    });
  }

  _purchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    // check each item in the provider list
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      // Sometimes the purchase is not completely done yet, in this case, show the pending UI again.
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("purchase is pending");
        purchasePending.value = true;
        //_showPendingUI();

      } else {
        // The status is NOT pending, lets check for an error
        if (purchaseDetails.status == PurchaseStatus.error) {
          // This happens if you close the app or dismiss the purchase dialog.
          //_handleError(purchaseDetails.error!);
          print("there was an error");
          purchaseError.value = true;
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print("item purchased or restored");
          // Huge SUCCESS! This case handles the happy case whenever the user purchased or restored the purchase
          _verifyPurchaseAndEnablePremium(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          print("item purchased or restored");
          // Huge SUCCESS! This case handles the happy case whenever the user purchased or restored the purchase
          _verifyRestoredPurchase(purchaseDetails);
        }

        // Whenever the purchase is done, complete it by calling complete.
        if (purchaseDetails.pendingCompletePurchase) {
          print("purchase complete");
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

  _verifyPurchaseAndEnablePremium(PurchaseDetails purchaseDetails) async {
    // check if the purchase is valid by calling your server including the receipt data.
    // bool valid = await _verifyPurchase(purchaseDetails);
    // if (valid) {
    //   // Purchase is valid, time to enable all subscription features.
    //   //_enablePremiumFeatures(purchaseDetails);

    // } else {
    //   // The receipt is not valid. Don't enable any subscription features.
    //   // _handleInvalidPurchase(purchaseDetails);
    // }

    purchaseSuccess.value = true;
    purchases.add(purchaseDetails.productID);
  }

  _verifyRestoredPurchase(PurchaseDetails pd) {}

  _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // check if the purchase is valid by calling your server including the receipt data.
  }

  restorePurchases() {
    InAppPurchase.instance.restorePurchases();
  }

  listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // Purchased Subscriptions
  }
}
