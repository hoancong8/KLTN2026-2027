// lib/domain/utils/vietqr_helper.dart

class VietQrHelper {
  static String generatePayload({
    required String bankBin,
    required String accountNumber,
    required int amount,
    required String message,
  }) {
    String formatLength(String s) => s.length < 10 ? '0${s.length}' : '${s.length}';

    final cleanBin = bankBin.trim();
    final cleanAcc = accountNumber.trim();
    final acquier = '00${formatLength(cleanBin)}$cleanBin';
    final consumer = '01${formatLength(cleanAcc)}$cleanAcc';
    final beneficiaryContent = '$acquier$consumer';
    final beneficiaryTag = '01${formatLength(beneficiaryContent)}$beneficiaryContent';
    final full38 = '0010A000000727${beneficiaryTag}0208QRIBFTTA';
    final tag38 = '38${formatLength(full38)}$full38';

    final tag53 = '5303704';
    final amountStr = amount.toString();
    final tag54 = amount > 0 ? '54${formatLength(amountStr)}$amountStr' : '';
    final tag58 = '5802VN';

    final msgClean = message.length > 98 ? message.substring(0, 98) : message;
    final tag08 = '08${formatLength(msgClean)}$msgClean';
    final tag62 = message.isNotEmpty ? '62${formatLength(tag08)}$tag08' : '';

    final raw = '000201010212$tag38$tag53$tag54$tag58$tag62' '6304';
    final crc = _crc16(raw);
    return '$raw$crc';
  }

  static String _crc16(String input) {
    const polynomial = 0x1021;
    int crc = 0xFFFF;
    for (int b in input.codeUnits) {
      crc ^= (b << 8) & 0xFFFF;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ polynomial) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
