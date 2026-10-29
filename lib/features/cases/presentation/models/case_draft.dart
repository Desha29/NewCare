import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../data/models/case_record.dart';
import '../../data/models/case_line_item.dart';
import '../../data/services/case_pricing.dart';

class CaseDraft {
  CaseDraft({required this.outside, this.initial}) {
    final c = initial;
    if (c == null) {
      amount.text = '0';
      return;
    }
    title.text = c.title;
    agreedTotal.text = (c.invoiceMinor / 100).toStringAsFixed(2);
    address.text = c.address;
    phone.text = c.phone;
    amount.text = (c.amountMinor / 100).toStringAsFixed(2);
    staff = c.staffId;
    payment = c.payment;
    procedures.addAll(c.effectiveProcedureIds);
    supplies.addAll(
      c.lineItems
          .where((i) => i.kind == CaseItemKind.supply)
          .map((i) => i.catalogueId),
    );
    if (c.lineItems.isEmpty) notes.text = c.supplies.join('\n');
  }
  final CaseRecord? initial;
  final String id = const Uuid().v4();
  final title = TextEditingController(),
      address = TextEditingController(),
      phone = TextEditingController(),
      notes = TextEditingController(),
      amount = TextEditingController(),
      agreedTotal = TextEditingController();
  bool outside;
  String? staff;
  PaymentMethod payment = PaymentMethod.cash;
  final procedures = <String>{}, supplies = <String>{};
  List<CaseLineItem> items(WorkspaceSnapshot data) {
    final original = initial;
    final previous = original?.lineItems ?? <CaseLineItem>[];
    final legacy = original != null && previous.isEmpty
        ? [
            CaseLineItem(
              catalogueId: original.procedureId,
              nameAr:
                  data.procedures
                      .where((p) => p.id == original.procedureId)
                      .firstOrNull
                      ?.nameAr ??
                  original.title,
              nameEn:
                  data.procedures
                      .where((p) => p.id == original.procedureId)
                      .firstOrNull
                      ?.nameEn ??
                  original.title,
              kind: CaseItemKind.procedure,
              priceMinor: original.amountMinor,
            ),
          ]
        : previous;
    return CasePricing.lines(data, procedures, supplies, previous: legacy)
        .map(
          (i) => CaseLineItem(
            catalogueId: i.catalogueId,
            nameAr: i.nameAr,
            nameEn: i.nameEn,
            kind: i.kind,
            priceMinor: initial == null ? 0 : i.priceMinor,
          ),
        )
        .toList();
  }

  void updateSelectionTitle(WorkspaceSnapshot data, String locale) {
    if (title.text.trim().isEmpty && procedures.isNotEmpty) {
      title.text = items(data).first.name(locale);
    }
  }

  CaseRecord record(WorkspaceSnapshot data, String shiftId) {
    final lines = items(data);
    return CaseRecord(
      id: initial?.id ?? id,
      shiftId: initial?.shiftId ?? shiftId,
      staffId: staff!,
      title: lines
          .where((i) => i.kind == CaseItemKind.procedure)
          .map((i) => i.nameAr)
          .join(' + '),
      procedureId: procedures.first,
      supplies: [
        ...lines
            .where((i) => i.kind == CaseItemKind.supply)
            .map((i) => i.nameAr),
        ...notes.text.split('\n').where((n) => n.trim().isNotEmpty),
      ],
      amountMinor: Money.parse(amount.text),
      agreedTotalMinor: Money.parse(agreedTotal.text),
      payment: payment,
      location: outside ? CaseLocation.outside : CaseLocation.inside,
      createdAt: initial?.createdAt ?? CenterClock.now(),
      address: outside ? address.text.trim() : '',
      phone: outside ? phone.text.trim() : '',
      lineItems: lines,
    );
  }

  void dispose() {
    for (final c in [title, address, phone, notes, amount, agreedTotal]) {
      c.dispose();
    }
  }
}
