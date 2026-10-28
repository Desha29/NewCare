class SupplyItem {
  const SupplyItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });
  final String id, nameAr, nameEn;
  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  Map<String, dynamic> toJson() => {'id': id, 'ar': nameAr, 'en': nameEn};
  factory SupplyItem.fromJson(Map<String, dynamic> j) => SupplyItem(
    id: j['id'] as String,
    nameAr: j['ar'] as String,
    nameEn: j['en'] as String,
  );
}
