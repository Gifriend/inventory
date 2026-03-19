import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';
import 'package:inventory/core/constants/constants.dart';


class MyLoansScreen extends ConsumerWidget {
  const MyLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Riwayat Peminjaman',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => Navigator.of(context).pop(),
      ),
      child: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat peminjaman',
                style: BaseTypography.titleMedium,
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w16,
              vertical: BaseSize.h16,
            ),
            itemCount: loans.length,
            separatorBuilder: (_, _) => Gap.h12,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final statusColor = switch (loan.status) {
                'pending' => BaseColor.grey,
                'approved' => BaseColor.green,
                'rejected' => BaseColor.red,
                'completed' => BaseColor.blue,
                _ => BaseColor.grey,
              };

              return Container(
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: BaseShadow.shadow,
                ),
                child: Padding(
                  padding: EdgeInsets.all(BaseSize.w12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Request #${loan.id}',
                            style: BaseTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: BaseSize.w8,
                              vertical: BaseSize.h4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                            ),
                            child: Text(
                              loan.status.toUpperCase(),
                              style: BaseTypography.bodyMedium.copyWith(
                                color: BaseColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.h4,
                      if (loan.room != null) Text('Room: ${loan.room!.name}'),
                      if (loan.desk != null)
                        Text('Desk: ${loan.desk!.deskNumber}'),
                      Text(
                        'Requested: ${loan.startTime ?? '-'} to ${loan.endTime ?? '-'}',
                        style: BaseTypography.titleSmall,
                      ),
                      if (loan.checkInTime != null)
                        Text(
                          'Checked In: ${loan.checkInTime}',
                          style: BaseTypography.titleSmall,
                        ),
                      if (loan.checkOutTime != null)
                        Text(
                          'Checked Out: ${loan.checkOutTime}',
                          style: BaseTypography.titleSmall,
                        ),
                      if (loan.adminNotes != null &&
                          loan.adminNotes!.isNotEmpty) ...[
                        Gap.h4,
                        Container(
                          padding: EdgeInsets.all(BaseSize.w8),
                          decoration: BoxDecoration(
                            color: BaseColor.grey[200],
                            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Notes:',
                                style: BaseTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                loan.adminNotes!,
                                style: BaseTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error: ${mapDioErrorToMessage(error)}')),
      ),
    );
  }
}
