import 'package:equatable/equatable.dart';

class SepayProviderAccount extends Equatable {
  final int id;
  final String accountNumber;
  final String accountHolder;
  final String bankBin;
  final String gateway;
  final bool active;
  final bool matchesClubBank;

  const SepayProviderAccount({
    required this.id,
    required this.accountNumber,
    required this.accountHolder,
    required this.bankBin,
    required this.gateway,
    required this.active,
    required this.matchesClubBank,
  });

  bool get isEligibleToSelect => active && matchesClubBank;

  @override
  List<Object?> get props => [
        id,
        accountNumber,
        accountHolder,
        bankBin,
        gateway,
        active,
        matchesClubBank,
      ];
}
