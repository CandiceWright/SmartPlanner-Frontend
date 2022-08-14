import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
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

  SubscriptionService() {
    purchasesUpdated();
    getProducts();
  }

  purchasesUpdated() {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    }) as StreamSubscription<List<PurchaseDetails>>;
  }

  getProducts() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    products = response.productDetails;
  }

  void _listenToPurchaseUpdated(purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //_showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //_handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //bool valid = await _verifyPurchase(purchaseDetails);
          // await InAppPurchase.instance.completePurchase(purchaseDetails);
          // if (valid) {
          //   //_deliverProduct(purchaseDetails);
          // } else {
          //   //_handleInvalidPurchase(purchaseDetails);
          // }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void _verifyPurchases() {
    // PurchaseDetails purchase = _hasUserPurchased(testID);
    // if (purchase != null && purchase.status == PurchaseStatus.purchased) {
    //   _credits = 10;
    // }
  }

  PurchaseDetails _hasUserPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID);
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    InAppPurchase.instance
        .buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }
}
