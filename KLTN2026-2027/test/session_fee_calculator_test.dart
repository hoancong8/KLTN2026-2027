import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/domain/utils/session_fee_calculator.dart';

void main() {
  group('SessionFeeCalculator Tests', () {
    test('Calculates equal fee when no female players', () {
      final res = SessionFeeCalculator.calculate(
        totalCost: 440000,
        totalPlayers: 4,
        femaleCount: 0,
        femaleDiscount: 10000,
      );

      expect(res.maleFee, 110000);
      expect(res.femaleFee, 100000);
      expect(res.maleCount, 4);
      expect(res.femaleCount, 0);
      expect(res.totalExpectedCollection, 440000);
      expect(res.totalExpectedCollection >= res.totalCost, isTrue);
    });

    test('Ensures total collection covers total cost when female discount applies', () {
      // 6 players: 4 males, 2 females
      // Total: 440,000 VND
      // Female discount: 10,000 VND
      // Formula: (440000 + 2*10000)/6 = 76666.67 -> ceil 1000 -> 77000
      // Female fee: 77000 - 10000 = 67000
      // Total collection: 4*77000 + 2*67000 = 308000 + 134000 = 442000 >= 440000
      final res = SessionFeeCalculator.calculate(
        totalCost: 440000,
        totalPlayers: 6,
        femaleCount: 2,
        femaleDiscount: 10000,
      );

      expect(res.maleFee, 77000);
      expect(res.femaleFee, 67000);
      expect(res.maleCount, 4);
      expect(res.femaleCount, 2);
      expect(res.totalExpectedCollection, 442000);
      expect(res.totalExpectedCollection >= res.totalCost, isTrue);
      // Verify difference between male and female is exactly the discount
      expect(res.maleFee - res.femaleFee, 10000);
    });

    test('All players are female divides cost equally without deficit', () {
      final res = SessionFeeCalculator.calculate(
        totalCost: 300000,
        totalPlayers: 3,
        femaleCount: 3,
        femaleDiscount: 10000,
      );

      expect(res.femaleFee, 100000);
      expect(res.totalExpectedCollection, 300000);
      expect(res.totalExpectedCollection >= res.totalCost, isTrue);
    });

    test('Discount larger than cost clamps female fee to zero and male covers remainder', () {
      final res = SessionFeeCalculator.calculate(
        totalCost: 100000,
        totalPlayers: 2,
        femaleCount: 1,
        femaleDiscount: 200000,
      );

      expect(res.femaleFee, 0);
      expect(res.maleFee, 150000);
      expect(res.totalExpectedCollection >= res.totalCost, isTrue);
    });
  });
}
