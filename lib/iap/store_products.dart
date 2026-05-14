/// App Store / Google Play 内购商品 ID 与赠送积分（需在商店后台创建同名消耗型商品）。
const int kPublishActivityPointsCost = 20;

const int kDefaultUserPoints = 60;

/// 金额（元）→ 积分：6→60、18→180、28→280（10 倍）。商品 ID 须与 App Store Connect / Play 控制台一致。
const List<({String productId, int yuan, int bonusPoints})> kPointsPacks = [
  (productId: 'com.jiuyu.m6', yuan: 6, bonusPoints: 60),
  (productId: 'com.jiuyu.m18', yuan: 18, bonusPoints: 180),
  (productId: 'com.jiuyu.m28', yuan: 28, bonusPoints: 280),
];

Set<String> get kPointsProductIds => {for (final p in kPointsPacks) p.productId};

int bonusPointsForProductId(String productId) {
  for (final p in kPointsPacks) {
    if (p.productId == productId) return p.bonusPoints;
  }
  return 0;
}
