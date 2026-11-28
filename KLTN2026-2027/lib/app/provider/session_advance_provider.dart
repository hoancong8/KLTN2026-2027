import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/session_advance_repository_impl.dart';
import '../../domain/entities/payment/session_advance.dart';
import '../../domain/repositories/session_advance_repository.dart';
import '../provider.dart';

final sessionAdvanceRepositoryProvider = Provider<SessionAdvanceRepository>((
  ref,
) {
  return SessionAdvanceRepositoryImpl(ref.watch(dioProvider));
});

final sessionAdvanceQuoteProvider = FutureProvider.autoDispose
    .family<SessionAdvance?, String>((ref, id) async {
      if (ref.watch(authTokenProvider) == null) return null;
      return ref.watch(sessionAdvanceRepositoryProvider).quote(id);
    });

final mySessionAdvancesProvider =
    FutureProvider.autoDispose<List<SessionAdvance>>((ref) async {
      if (ref.watch(authTokenProvider) == null) return [];
      return ref.watch(sessionAdvanceRepositoryProvider).listMine();
    });

final clubSessionAdvancesProvider = FutureProvider.autoDispose
    .family<List<SessionAdvance>, String>((ref, id) async {
      if (ref.watch(authTokenProvider) == null) return [];
      return ref.watch(sessionAdvanceRepositoryProvider).listClub(id);
    });
