import 'package:kltn2026_2027/app/paging/paging_cursor.dart';

abstract class UseCase<Output> {
  Future<Output> execute();
}

abstract class PagingUseCase<Output> {
  Future<Output> execute({
    PagingCursor? cursor,
    int limit,
  });
}

abstract class UseCaseWithParams<Output, Params> {
  Future<Output> execute(Params params);
}
