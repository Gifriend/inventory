import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';
import 'package:inventory/core/constants/constants.dart';


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
        error: (error, stack) {
          // Log full error info to console so it appears in debugger logs
          debugPrint('LoanRequestScreen error (${error.runtimeType}): ${error.toString()}');
          debugPrint(mapDioErrorToMessage(error));
          // print stack trace (if available)
          debugPrintStack(stackTrace: stack as StackTrace?);
          // also report to Flutter error handler so it shows in IDE consoles
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
        title: 'Ajukan Peminjaman',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => Navigator.of(context).pop(),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h16,
        ),
        children: [
          Text(
            selectedDesk == null
                ? 'Tidak ada desk yang dipilih'
                : 'Desk: ${selectedDesk.deskNumber}',
            style: BaseTypography.titleMedium,
          ),
          Gap.h16,
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _startTime == null
                  ? 'Pilih waktu mulai'
                  : 'Start: ${_startTime.toString()}',
              style: BaseTypography.titleSmall,
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
                  ? 'Pilih waktu selesai'
                  : 'End: ${_endTime.toString()}',
              style: BaseTypography.titleSmall,
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
          Gap.h12,
          ButtonWidget.outlined(
            text: _pdfFile == null ? 'Pilih PDF' : _pdfFile!.name,
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const ['pdf'],
              );
              if (result == null || result.files.isEmpty) {
                return;
              }
              setState(() => _pdfFile = result.files.single);
            },
          ),
          Gap.h20,
          ButtonWidget.primary(
            color: BaseColor.primaryinventory,
            text: actionState.isLoading ? 'Loading...' : 'Kirim Permintaan',
            onTap: actionState.isLoading
                ? null
                : () async {
                    final start = _startTime;
                    final end = _endTime;
                    final file = _pdfFile;
                    if (start == null || end == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lengkapi semua field wajib'),
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
          ),
        ],
      ),
    );
  }
}
