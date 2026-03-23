import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';

class DeskSelectionScreen extends ConsumerWidget {
  const DeskSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final desksAsync = ref.watch(roomDesksProvider);
    final selectedRoomId = ref.watch(selectedRoomIdProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Pilih Meja',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: Column(
        children: [
          // Room Selector
          Container(
            padding: EdgeInsets.all(BaseSize.w16),
            margin: EdgeInsets.only(top: BaseSize.h16),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: BaseShadow.shadow,
            ),
            child: roomsAsync.when(
              data: (rooms) {
                return DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('Pilih ruangan', style: BaseTypography.titleSmall),
                  value: selectedRoomId,
                  items: rooms.map((room) {
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text(room.name, style: BaseTypography.titleMedium),
                    );
                  }).toList(),
                  onChanged: (roomId) {
                    if (roomId != null) {
                      ref
                          .read(selectedRoomIdProvider.notifier)
                          .setRoomId(roomId);
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Text('Error loading rooms: ${mapDioErrorToMessage(error)}'),
            ),
          ),
          // Desk Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: desksAsync.when(
                data: (desks) {
                  if (desks.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada desk di ruangan ini',
                        style: BaseTypography.titleMedium,
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: BaseSize.w8,
                      mainAxisSpacing: BaseSize.h8,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: desks.length,
                    itemBuilder: (context, index) {
                      final desk = desks[index];
                        final isAvailable = desk.status == 'available';
                        final tileColor = isAvailable
                          ? BaseColor.primaryinventory
                          : BaseColor.grey.shade300;

                      return InkWell(
                        onTap: !isAvailable
                            ? null
                            : () {
                                ref
                                    .read(selectedDeskProvider.notifier)
                                    .setDesk(desk);
                                context.pushNamed(AppRoute.loanRequest);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(
                              BaseSize.radiusMd,
                            ),
                            boxShadow: isAvailable ? BaseShadow.shadow : [],
                          ),
                          child: Center(
                            child: Text(
                              desk.deskNumber,
                              style: BaseTypography.titleMedium.copyWith(
                                color: isAvailable ? BaseColor.white : BaseColor.grey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text(mapDioErrorToMessage(error))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
