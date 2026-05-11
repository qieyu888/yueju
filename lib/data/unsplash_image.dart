/// Unsplash 配图地址；宽高与首页竖卡、动态栅格比例接近，减少裁切后留白。
/// `photoKey` 为资源 id（不含 `photo-` 前缀）。
String unsplashHero(String photoKey) {
  return 'https://images.unsplash.com/photo-$photoKey?auto=format&fit=crop&w=800&h=1400&q=88';
}

/// 动态列表 / 详情多图。
String unsplashMoment(String photoKey) {
  return 'https://images.unsplash.com/photo-$photoKey?auto=format&fit=crop&w=640&h=480&q=88';
}
