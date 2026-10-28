import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/features/analytics/data/models/report_summary.dart';
import 'package:newcare/features/analytics/data/services/csv_exporter.dart';
import 'package:newcare/features/workspace/data/models/workspace_snapshot.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
void main(){
  test('custom range includes end-date cases and excludes next midnight',(){
    CaseRecord c(String id,DateTime date)=>CaseRecord(id:id,shiftId:'s',staffId:'n',title:'Case',procedureId:'p',supplies:const [],amountMinor:1000,payment:PaymentMethod.cash,location:CaseLocation.inside,createdAt:date);
    final data=WorkspaceSnapshot(cases:[c('a',DateTime(2026,10,1)),c('b',DateTime(2026,10,28,23,59)),c('c',DateTime(2026,10,29))]);
    final summary=ReportSummary.forRange(data,DateTime(2026,10,1),DateTime(2026,10,28));
    expect(summary.cases.length,2);expect(summary.revenueMinor,2000);
  });
  test('CSV escapes quotes and prevents spreadsheet formula injection',(){
    expect(CsvExporter.cell('=SUM(A1)'),contains("'=SUM(A1)"));
    expect(CsvExporter.cell('a"b'),'"a""b"');
  });
}

