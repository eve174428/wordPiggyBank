import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const String storeConsumableProductID = 'support';

enum StoreState {
  loading,
  available,
  notAvailable,
}

//must match in_app_purchase_platform_interface/src/types/purchase_status.dart
enum StoreProductStatus {
  pending,
  purchased,
  purchasable,
}

class StorePurchasableProduct {
  ProductDetails productDetails;
  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;
  String get price => productDetails.price;
  StoreProductStatus status;
  StorePurchasableProduct(this.productDetails)
      : status = StoreProductStatus.purchasable;
}

class DashPurchases extends ChangeNotifier {
  final iapConnection = InAppPurchase.instance;
  StoreState storeState = StoreState.loading;
  List<StorePurchasableProduct> products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  //init
  DashPurchases() {
    //instance.purchaseStream  (listen purchases)
    final purchaseUpdate = iapConnection.purchaseStream;
    _subscription = purchaseUpdate.listen(
      _onUpdate,
      onError: (error) => print(error),
      onDone: () => _subscription.cancel(),
    );
    //import available products
    load();
  }
  void _onUpdate(List<PurchaseDetails> purchaseDetailsList) {
    void _counting(PurchaseDetails purchaseDetails) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        switch (purchaseDetails.productID) {
          case storeConsumableProductID:
            break;
        }
      }
    }

    purchaseDetailsList.forEach((e) => _counting(e));
    notifyListeners();
  }

  //import products which match Product ID
  Future<void> load() async {
    final available = await iapConnection.isAvailable();
    if (!available) {
      storeState = StoreState.notAvailable;
      print(available);
      notifyListeners();
      return;
    }
    //Set (a unordered collection of unique items) Product IDs
    const identifiers = <String>{storeConsumableProductID};
    //filtering; search product which match $identifiers Set.
    final response = await iapConnection.queryProductDetails(identifiers);
    //print which is not matches
    response.notFoundIDs
        .forEach((element) => print('Purchase $element not found'));
    //import
    products =
        response.productDetails.map((e) => StorePurchasableProduct(e)).toList();
    storeState = StoreState.available;
    print(storeState);
    notifyListeners();
  }

  Future<void> buy(StorePurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    switch (product.id) {
      case storeConsumableProductID:
        await iapConnection.buyConsumable(purchaseParam: purchaseParam);
        break;
      default:
        throw ArgumentError.value('${product.productDetails} is not');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
