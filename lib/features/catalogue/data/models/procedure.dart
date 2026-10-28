class Procedure {
  const Procedure({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.priceMinor,
  });
  final String id, nameAr, nameEn;
  final int priceMinor;
  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  Map<String, dynamic> toJson() => {
    'id': id,
    'ar': nameAr,
    'en': nameEn,
    'price': priceMinor,
  };
  factory Procedure.fromJson(Map<String, dynamic> j) => Procedure(
    id: j['id'] as String,
    nameAr: j['ar'] as String,
    nameEn: j['en'] as String,
    priceMinor: j['price'] as int,
  );
}
