import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/data/dto/notification/notification_dto.dart';
import 'package:kltn2026_2027/data/mapper/notification_mapper.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/club/active_club_context.dart';
import 'package:kltn2026_2027/domain/enums/club_role.dart';
import 'package:kltn2026_2027/ui/screen/club/club_vm/club_context_vm.dart';
import 'package:kltn2026_2027/ui/screen/notification/widgets/ledger_notification_navigation.dart';

class _ClubContext extends ClubContextViewModel {
  _ClubContext(Ref ref)
      : super(
          ref: ref,
          getMyClubsUseCase: ref.read(getMyClubsUseCaseProvider),
          createClubUseCase: ref.read(createClubUseCaseProvider),
          joinClubUseCase: ref.read(joinClubUseCaseProvider),
          removeClubMemberUseCase: ref.read(removeClubMemberUseCaseProvider),
          switchClubContextUseCase: ref.read(switchClubContextUseCaseProvider),
        );

  @override
  Future<void> loadMyClubs() async {}

  @override
  Future<bool> switchClub(String clubId) async {
    ref.read(activeClubContextProvider.notifier).state = _club(clubId);
    return true;
  }
}

ActiveClubContext _club(String id) => ActiveClubContext(
      clubId: id,
      clubName: id,
      role: ClubRole.member,
      permissions: const [],
    );

void main() {
  test('ledger notification retains its transaction and club identifiers', () {
    final notification = NotificationMapper.toEntity(NotificationDto.fromJson({
      'id': 'notification-id',
      'title': 'Sổ quỹ được cập nhật',
      'content': 'Nhóm vừa ghi nhận một khoản thu hoặc chi.',
      'type': 'PAYMENT',
      'referenceType': 'GroupLedger',
      'referenceId': 'ledger-id',
      'groupId': 'club-id',
      'isRead': false,
      'createdAt': '2026-11-23T00:00:00Z',
    }));

    expect(notification.referenceId, 'ledger-id');
    expect(notification.groupId, 'club-id');
    expect(AppConfig.clubLedgerScreenPath(notification.groupId!), '/club/club-id/ledger?switchClub=1');
  });

  testWidgets('returning from another club ledger restores the previous club', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => Consumer(
        builder: (context, ref, _) => Scaffold(
          body: TextButton(
            onPressed: () => openLedgerFromNotification(context, ref, 'club-b'),
            child: const Text('Open'),
          ),
        ),
      )),
      GoRoute(path: '/club/:clubId/ledger', builder: (context, state) => Consumer(
        builder: (context, ref, _) => Scaffold(
          body: TextButton(
            onPressed: () {
              ref.read(activeClubContextProvider.notifier).state = _club('club-b');
              context.pop();
            },
            child: const Text('Back'),
          ),
        ),
      )),
    ]);
    addTearDown(router.dispose);
    final container = ProviderContainer(overrides: [
      activeClubContextProvider.overrideWith((ref) => _club('club-a')),
      clubContextViewModelProvider.overrideWith((ref) => _ClubContext(ref)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(container.read(activeClubContextProvider)?.clubId, 'club-a');
  });
}
