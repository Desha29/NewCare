import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/app_cubit.dart';
import '../navigation/app_page.dart';
import '../navigation/navigation_label.dart';

class CaseBookNavigationEntry extends StatelessWidget {
  const CaseBookNavigationEntry({super.key, this.onSelected});
  final VoidCallback? onSelected;
  @override
  Widget build(BuildContext context) {
    final page = context.watch<AppCubit>().state.page;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          key: ValueKey(page.isCaseBook),
          initiallyExpanded: page.isCaseBook,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsetsDirectional.only(
            start: 14,
            bottom: 6,
          ),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          leading: const Icon(
            Icons.folder_open_outlined,
            color: Colors.white70,
            size: 18,
          ),
          title: Text(
            context.pageLabel(AppPage.shiftCases),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            for (final destination in [
              AppPage.insideCaseBook,
              AppPage.outsideCaseBook,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color:
                      page == destination ||
                          page == AppPage.shiftCases &&
                              destination == AppPage.insideCaseBook
                      ? Colors.white.withValues(alpha: .13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    dense: true,
                    minTileHeight: 44,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    leading: Icon(
                      destination == AppPage.insideCaseBook
                          ? Icons.local_hospital_outlined
                          : Icons.home_outlined,
                      size: 17,
                      color: destination == AppPage.insideCaseBook
                          ? const Color(0xFF80D0DB)
                          : const Color(0xFFFFC68A),
                    ),
                    title: Text(
                      context.pageLabel(destination),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: page == destination,
                    onTap: () {
                      context.read<AppCubit>().navigate(destination);
                      onSelected?.call();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
