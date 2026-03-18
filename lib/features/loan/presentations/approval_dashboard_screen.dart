import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/loan/presentations/dialogs/approve_assignment_dialog.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';

class ApprovalDashboardScreen extends ConsumerWidget {
  const ApprovalDashboardScreen({super.key});

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
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mapDioErrorToMessage(error))));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Dashboard')),
      body: loansAsync.when(
        data: (loans) {
          final pending = loans
              .where((loan) => loan.status == 'pending')
              .toList();
          if (pending.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, separatorIndex) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final loan = pending[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request #${loan.id}'),
                      const SizedBox(height: 6),
                      Text('User: ${loan.user?.name ?? '-'}'),
                      Text(
                        'Schedule: ${loan.startTime ?? '-'} - ${loan.endTime ?? '-'}',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: actionState.isLoading
                                  ? null
                                  : () async {
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
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: actionState.isLoading
                                  ? null
                                  : () async {
                                      final notesController =
                                          TextEditingController();
                                      if (!context.mounted) return;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Reject Request'),
                                          content: TextField(
                                            controller: notesController,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'Reason for rejection (optional)',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 3,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Reject'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true &&
                                          context.mounted) {
                                        await ref
                                            .read(
                                              loanActionControllerProvider
                                                  .notifier,
                                            )
                                            .rejectLoan(
                                              loanId: loan.id,
                                              notes:
                                                  notesController.text.isEmpty
                                                  ? 'Rejected by admin'
                                                  : notesController.text,
                                            );
                                      }
                                      notesController.dispose();
                                    },
                              child: const Text('Reject'),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(mapDioErrorToMessage(error))),
      ),
    );
  }
}
