import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/loan/presentations/dialogs/approve_assignment_dialog.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';
import 'package:inventory/core/constants/constants.dart';

class ApprovalDashboardScreen extends ConsumerWidget {
  const ApprovalDashboardScreen({super.key});

  Future<bool> _confirmApprove(BuildContext context, int loanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Approve'),
        content: Text(
          'Lanjutkan proses persetujuan untuk request #$loanId?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);
    final actionState = ref.watch(loanActionControllerProvider);

    ref.listen<AsyncValue<void>>(loanActionControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Action completed')));
          // Refresh loans list after action
          ref.invalidate(loansProvider);
        },
        error: (error, stack) {
          debugPrint('ApprovalDashboardScreen action error (${error.runtimeType}): ${error.toString()}');
          debugPrint(mapDioErrorToMessage(error));
          debugPrintStack(stackTrace: stack as StackTrace?);
          FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack as StackTrace?));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mapDioErrorToMessage(error))));
        },
      );
    });

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Approval Dashboard',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => Navigator.of(context).pop(),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          final fetchedLoans = await ref.refresh(loansProvider.future);
          if (fetchedLoans.isEmpty) {
            // no-op on empty, this avoids unused variable lint
          }
        },
        child: loansAsync.when(
          data: (loans) {
            final pending = loans
                .where((loan) => loan.status == 'pending')
                .toList();
            if (pending.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  EmptyStateWidget(
                    icon: Icons.hourglass_empty,
                    title: 'Tidak ada permintaan pending',
                    subtitle: 'Semua peminjaman telah diproses.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.h16,
              ),
              itemCount: pending.length,
              separatorBuilder: (_, separatorIndex) => Gap.h16,
              itemBuilder: (context, index) {
                final loan = pending[index];

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
                        Text(
                          'Request #${loan.id}',
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap.h8,
                        Text(
                          'User: ${loan.user?.name ?? '-'}',
                          style: BaseTypography.titleSmall,
                        ),
                        Text(
                          'Schedule: ${loan.startTime ?? '-'} - ${loan.endTime ?? '-'}',
                          style: BaseTypography.titleSmall,
                        ),
                        Gap.h16,
                        Row(
                          children: [
                            Expanded(
                              child: ButtonWidget.primary(
                                text: 'Approve',
                                onTap: actionState.isLoading
                                    ? null
                                    : () async {
                                        final approveConfirmed =
                                            await _confirmApprove(
                                          context,
                                          loan.id,
                                        );
                                        if (!context.mounted || !approveConfirmed) {
                                          return;
                                        }

                                        final result =
                                            await showDialog<Map<String, int>>(
                                          context: context,
                                          builder: (context) =>
                                              ApproveAssignmentDialog(
                                            loanId: loan.id,
                                            onAssignmentSelected: () {},
                                          ),
                                        );

                                        if (result != null && context.mounted) {
                                          await ref
                                              .read(
                                                loanActionControllerProvider
                                                    .notifier,
                                              )
                                              .approveLoan(
                                                loanId: loan.id,
                                                roomId: result['roomId']!,
                                                deskId: result['deskId']!,
                                              );
                                        }
                                      },
                              ),
                            ),
                            Gap.w12,
                            Expanded(
                              child: ButtonWidget.outlined(
                                text: 'Reject',
                                onTap: actionState.isLoading
                                    ? null
                                    : () async {
                                        final notesController =
                                            TextEditingController();
                                        if (!context.mounted) return;

                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Konfirmasi Reject'),
                                            content: TextField(
                                              controller: notesController,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Alasan penolakan (opsional)',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 3,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: const Text('Tolak'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true && context.mounted) {
                                          await ref
                                              .read(
                                                loanActionControllerProvider
                                                    .notifier,
                                              )
                                              .rejectLoan(
                                                loanId: loan.id,
                                                notes: notesController
                                                        .text.isEmpty
                                                    ? 'Rejected by admin'
                                                    : notesController.text,
                                              );
                                        }
                                        notesController.dispose();
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 220),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: BaseSize.customHeight(160)),
              Center(child: Text(mapDioErrorToMessage(error))),
              Gap.h16,
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final refreshed = await ref.refresh(loansProvider.future);
                    if (refreshed.isEmpty) {
                      // no-op to satisfy unused variable lint
                    }
                  },
                  child: const Text('Coba lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
