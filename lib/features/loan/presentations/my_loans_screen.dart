import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';

class MyLoansScreen extends ConsumerWidget {
  const MyLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Loan Requests')),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return const Center(child: Text('No loan requests yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final loan = loans[index];
              final statusColor = switch (loan.status) {
                'pending' => Colors.orange,
                'approved' => Colors.green,
                'rejected' => Colors.red,
                'completed' => Colors.blue,
                _ => Colors.grey,
              };

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Request #${loan.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              loan.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (loan.room != null) Text('Room: ${loan.room!.name}'),
                      if (loan.desk != null)
                        Text('Desk: ${loan.desk!.deskNumber}'),
                      Text(
                        'Requested: ${loan.startTime ?? '-'} to ${loan.endTime ?? '-'}',
                      ),
                      if (loan.checkInTime != null)
                        Text('Checked In: ${loan.checkInTime}'),
                      if (loan.checkOutTime != null)
                        Text('Checked Out: ${loan.checkOutTime}'),
                      if (loan.adminNotes != null &&
                          loan.adminNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin Notes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                loan.adminNotes!,
                                style: const TextStyle(fontSize: 12),
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
