import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../widgets/case_location_heading.dart';
import '../widgets/case_ledger_section.dart' show CaseBookColumns;
import '../../data/models/case_record.dart';
import 'case_form_screen.dart';

class CaseRegisterScreen extends StatefulWidget {
  const CaseRegisterScreen({super.key, this.availableHeight = 0});
  final double availableHeight;
  @override
  State<CaseRegisterScreen> createState() => _CaseRegisterScreenState();
}

class _CaseRegisterScreenState extends State<CaseRegisterScreen> {
  GlobalKey insideForm = GlobalKey(), outsideForm = GlobalKey();
  int selectedLocation = 0;

  void reset(bool outside, {bool saved = false}) {
    setState(() {
      if (outside) {
        outsideForm = GlobalKey();
      } else {
        insideForm = GlobalKey();
      }
    });
    if (saved) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t('savedNote'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget section(CaseLocation location, {bool fillHeight = false}) {
      final outside = location == CaseLocation.outside;
      return NcCard(
        padding: 12,
        children: [
          CaseFormScreen(
            key: outside ? outsideForm : insideForm,
            outside: outside,
            compact: true,
            header: CaseLocationHeading(location: location),
            minHeight: fillHeight
                ? (widget.availableHeight - 24).clamp(0, double.infinity)
                : 0,
            onCancel: () => reset(outside),
            onSaved: () => reset(outside, saved: true),
          ),
        ],
      );
    }

    return NcPageColumn(
      spacing: 10,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return CaseBookColumns(
                inside: section(CaseLocation.inside, fillHeight: true),
                outside: section(CaseLocation.outside, fillHeight: true),
              );
            }
            return Column(
              children: [
                DefaultTabController(
                  length: 2,
                  initialIndex: selectedLocation,
                  child: TabBar(
                    onTap: (value) => setState(() => selectedLocation = value),
                    tabs: [
                      Tab(text: context.t('inside')),
                      Tab(text: context.t('outside')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Offstage(
                  offstage: selectedLocation != 0,
                  child: section(CaseLocation.inside),
                ),
                Offstage(
                  offstage: selectedLocation != 1,
                  child: section(CaseLocation.outside),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
