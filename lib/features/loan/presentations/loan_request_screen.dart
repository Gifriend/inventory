import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';

class LoanRequestScreen extends ConsumerStatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  ConsumerState<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends ConsumerState<LoanRequestScreen> {
  DateTime? _startTime;
  DateTime? _endTime;
  PlatformFile? _pdfFile;

  @override
  Widget build(BuildContext context) {
    final selectedDesk = ref.watch(selectedDeskProvider);
    final actionState = ref.watch(loanActionControllerProvider);

    ref.listen<AsyncValue<void>>(loanActionControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loan request submitted')),
          );
          Navigator.of(context).pop();
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mapDioErrorToMessage(error))));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Request')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            selectedDesk == null
                ? 'No desk selected'
                : 'Desk: ${selectedDesk.deskNumber}',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _startTime == null
                  ? 'Pick start time'
                  : 'Start: ${_startTime.toString()}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 30)),
              );
              if (pickedDate == null) return;
              if (!context.mounted) return;
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime == null) return;
              setState(() {
                _startTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _endTime == null
                  ? 'Pick end time'
                  : 'End: ${_endTime.toString()}',
            ),
            trailing: const Icon(Icons.access_time_filled),
            onTap: () async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 30)),
              );
              if (pickedDate == null) return;
              if (!context.mounted) return;
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime == null) return;
              setState(() {
                _endTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const ['pdf'],
              );
              if (result == null || result.files.isEmpty) {
                return;
              }
              setState(() => _pdfFile = result.files.single);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(_pdfFile == null ? 'Choose PDF' : _pdfFile!.name),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: actionState.isLoading
                ? null
                : () async {
                    final start = _startTime;
                    final end = _endTime;
                    final file = _pdfFile;
                    if (start == null || end == null || file == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fill all required fields'),
                        ),
                      );
                      return;
                    }

                    await ref
                        .read(loanActionControllerProvider.notifier)
                        .createLoan(
                          pdfFile: file,
                          startTime: start,
                          endTime: end,
                        );
                  },
            child: actionState.isLoading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
