enum CaseItemKind { procedure, supply }

class CaseLineItem {
  const CaseLineItem({
    required this.catalogueId,
    required this.nameAr,
    required this.nameEn,
    required this.kind,
    required this.priceMinor,
  });
  final String catalogueId, nameAr, nameEn;
  final CaseItemKind kind;
  final int priceMinor;
  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  Map<String, dynamic> toJson() => {
    'id': catalogueId,
    'ar': nameAr,
    'en': nameEn,
    'kind': kind.name,
    'price': priceMinor,
  };
  factory CaseLineItem.fromJson(Map<String, dynamic> j) => CaseLineItem(
    catalogueId: j['id'] as String,
    nameAr: j['ar'] as String,
    nameEn: j['en'] as String,
    kind: CaseItemKind.values.byName(j['kind'] as String),
    priceMinor: j['price'] as int,
  );
}
