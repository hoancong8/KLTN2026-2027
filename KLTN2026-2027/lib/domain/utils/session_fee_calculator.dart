// lib/domain/utils/session_fee_calculator.dart

class SessionFeeCalculationResult {
  final int maleFee;
  final int femaleFee;
  final int totalCost;
  final int totalPlayers;
  final int maleCount;
  final int femaleCount;
  final int totalExpectedCollection;

  const SessionFeeCalculationResult({
    required this.maleFee,
    required this.femaleFee,
    required this.totalCost,
    required this.totalPlayers,
    required this.maleCount,
    required this.femaleCount,
    required this.totalExpectedCollection,
  });
}

class SessionFeeCalculator {
  static SessionFeeCalculationResult calculate({
    required int totalCost,
    required int totalPlayers,
    required int femaleCount,
    required int femaleDiscount,
    int roundRule = 1000,
  }) {
    if (totalPlayers <= 0 || totalCost <= 0) {
      return SessionFeeCalculationResult(
        maleFee: 0,
        femaleFee: 0,
        totalCost: totalCost,
        totalPlayers: totalPlayers,
        maleCount: 0,
        femaleCount: 0,
        totalExpectedCollection: 0,
      );
    }

    final safeFemale = femaleCount.clamp(0, totalPlayers);
    final maleCount = totalPlayers - safeFemale;

    int maleFee = 0;
    int femaleFee = 0;

    int roundUp(double amount) {
      if (roundRule <= 1) return amount.round();
      return ((amount / roundRule).ceil() * roundRule);
    }

    if (safeFemale > 0 && maleCount > 0) {
      // Công thức bù chéo bảo toàn tổng chi phí:
      // (maleCount * maleFee) + (femaleCount * (maleFee - discount)) = totalCost
      // => totalPlayers * maleFee = totalCost + (femaleCount * discount)
      final rawMale = (totalCost + (safeFemale * femaleDiscount)) / totalPlayers;
      maleFee = roundUp(rawMale);
      femaleFee = (maleFee - femaleDiscount).clamp(0, maleFee);
    } else if (safeFemale > 0 && maleCount == 0) {
      // 100% người chơi là Nữ -> Không có Nam gánh bù, chia đều cho Nữ để bảo toàn quỹ
      femaleFee = roundUp(totalCost / totalPlayers);
      maleFee = femaleFee;
    } else {
      // 100% người chơi là Nam -> Chia đều bình thường
      maleFee = roundUp(totalCost / totalPlayers);
      femaleFee = (maleFee - femaleDiscount).clamp(0, maleFee);
    }

    final totalCollection = (maleCount * maleFee) + (safeFemale * femaleFee);

    return SessionFeeCalculationResult(
      maleFee: maleFee,
      femaleFee: femaleFee,
      totalCost: totalCost,
      totalPlayers: totalPlayers,
      maleCount: maleCount,
      femaleCount: safeFemale,
      totalExpectedCollection: totalCollection,
    );
  }
}
