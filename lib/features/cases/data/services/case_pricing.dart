import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../models/case_line_item.dart';

abstract final class CasePricing {
  static List<CaseLineItem> lines(
    WorkspaceSnapshot data,
    Set<String> procedures,
    Set<String> supplies, {
    List<CaseLineItem> previous = const [],
  }) {
    final result = <CaseLineItem>[];
    for (final id in procedures) {
      final old = previous
          .where((i) => i.kind == CaseItemKind.procedure && i.catalogueId == id)
          .firstOrNull;
      if (old != null) {
        result.add(old);
        continue;
      }
      final p = data.procedures
          .where((p) => p.id == id && p.active)
          .firstOrNull;
      if (p == null) throw const WorkspaceException('invalidProcedure');
      result.add(
        CaseLineItem(
          catalogueId: p.id,
          nameAr: p.nameAr,
          nameEn: p.nameEn,
          kind: CaseItemKind.procedure,
          priceMinor: p.priceMinor,
        ),
      );
    }
    for (final id in supplies) {
      final old = previous
          .where((i) => i.kind == CaseItemKind.supply && i.catalogueId == id)
          .firstOrNull;
      if (old != null) {
        result.add(old);
        continue;
      }
      final s = data.supplies.where((s) => s.id == id).firstOrNull;
      if (s == null) throw const WorkspaceException('recordNotFound');
      result.add(
        CaseLineItem(
          catalogueId: s.id,
          nameAr: s.nameAr,
          nameEn: s.nameEn,
          kind: CaseItemKind.supply,
          priceMinor: s.priceMinor,
        ),
      );
    }
    return List.unmodifiable(result);
  }
}
