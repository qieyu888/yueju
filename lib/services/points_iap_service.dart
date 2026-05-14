import 'dart:async';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yueplayer/iap/store_products.dart';
import 'package:yueplayer/services/app_storage.dart';

String _friendlyQueryError(IAPError e) {
  if (e.code == 'storekit_no_response') {
    return '暂时无法连接商店，请检查网络后重试';
  }
  return '暂时无法获取充值信息，请稍后再试';
}

/// 积分内购：监听购买流并发放积分（消耗型需在商店配置商品 ID）。
class PointsIapService {
  PointsIapService._();

  static final PointsIapService instance = PointsIapService._();

  InAppPurchase get _iap => InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _listening = false;

  List<ProductDetails> _products = [];
  bool _catalogLoaded = false;
  String? _catalogError;

  VoidCallback? onPointsChanged;

  List<ProductDetails> get products => List.unmodifiable(_products);
  bool get catalogLoaded => _catalogLoaded;
  String? get catalogError => _catalogError;

  Future<void> ensureInitialized() async {
    if (_listening) {
      await refreshCatalog();
      return;
    }
    final available = await _iap.isAvailable();
    if (!available) {
      _catalogLoaded = true;
      _catalogError = '当前设备不支持应用内购买';
      return;
    }
    _listening = true;
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);
    await refreshCatalog();
  }

  Future<void> refreshCatalog() async {
    _catalogError = null;
    var response = await _iap.queryProductDetails(kPointsProductIds);
    for (var attempt = 0; attempt < 2; attempt++) {
      final retry = response.productDetails.isEmpty &&
          (response.error == null ||
              response.error!.code == 'storekit_no_response');
      if (!retry) break;
      await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
      response = await _iap.queryProductDetails(kPointsProductIds);
    }
    if (response.error != null) {
      _catalogLoaded = true;
      _catalogError = _friendlyQueryError(response.error!);
      _products = [];
      return;
    }
    _products = response.productDetails.toList()
      ..sort((a, b) {
        int order(String id) {
          final i = kPointsPacks.indexWhere((p) => p.productId == id);
          return i < 0 ? 99 : i;
        }
        return order(a.id).compareTo(order(b.id));
      });
    if (response.notFoundIDs.isNotEmpty && _products.isEmpty) {
      _catalogError = '暂时无法获取充值价格，请检查网络后稍后再试';
    } else if (response.notFoundIDs.isNotEmpty) {
      _catalogError = '部分充值档位暂不可用，请稍后再试';
    }
    _catalogLoaded = true;
  }

  /// 是否已成功向商店提交购买请求；成交结果仍通过 [purchaseStream] 异步到达。
  Future<bool> buyPack(ProductDetails details) {
    final param = PurchaseParam(productDetails: details);
    return _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> _safeCompletePurchase(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(purchase);
    } catch (_) {}
  }

  String _dedupeKey(PurchaseDetails p) {
    final pid = p.purchaseID;
    if (pid != null && pid.isNotEmpty) {
      return pid;
    }
    final svd = p.verificationData.serverVerificationData;
    if (svd.isNotEmpty) {
      return '${p.productID}_${svd.hashCode}';
    }
    return '';
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        await _safeCompletePurchase(purchase);
        continue;
      }
      if (purchase.status == PurchaseStatus.canceled) {
        await _safeCompletePurchase(purchase);
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased) {
        final bonus = bonusPointsForProductId(purchase.productID);
        final key = _dedupeKey(purchase);
        var grantedPoints = false;
        if (bonus > 0) {
          final firstTime = await AppStorage.instance.claimIapGrantIfNew(key.isEmpty ? null : key);
          if (firstTime) {
            await AppStorage.instance.addUserPoints(bonus);
            grantedPoints = true;
          }
        }
        if (grantedPoints) {
          onPointsChanged?.call();
        }
        await _safeCompletePurchase(purchase);
        continue;
      }
      if (purchase.status == PurchaseStatus.restored) {
        await _safeCompletePurchase(purchase);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _listening = false;
  }
}
