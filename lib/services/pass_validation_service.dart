import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:rapidpass_checkpoint/models/qr_data.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/utils/hmac_sha256.dart';
import 'package:rapidpass_checkpoint/utils/qr_code_decoder.dart';

class PassValidationService {
  final ApiRepository apiRepository;

  PassValidationService(this.apiRepository);

  static ScanResults deserializeAndValidate(final String base64Encoded) {
    try {
      final decodedFromBase64 = base64.decode(base64Encoded);
      final asHex = hex.encode(decodedFromBase64);
      print('QR Code as hex => $asHex (${asHex.length} codes)');
      final buffer = decodedFromBase64 is Uint8List
          ? decodedFromBase64.buffer
          : Uint8List.fromList(decodedFromBase64).buffer;
      final byteData = ByteData.view(buffer);
      final qrData = QrCodeDecoder().convert(byteData);
      final scanResults = validate(qrData);
      final signatureIsValid = HmacShac256.validateSignature(decodedFromBase64);
      if (signatureIsValid) {
        return scanResults;
      } else {
        final sr =
            ScanResults(null, resultMessage: 'ENTRY DENIED', allRed: true);
        sr.addError('Invalid QR Data');
        return sr;
      }
    } catch (e) {
      print(e.toString());
      final sr = ScanResults(null, resultMessage: 'ENTRY DENIED', allRed: true);
      sr.resultSubMessage = 'QR CODE INVALID';
      sr.addError('Invalid QR Data');
      print(sr.resultSubMessage);
      return sr;
    }
  }

  static ScanResults validate(final QrData qrData) {
    final results = ScanResults(qrData);
    final DateTime now = DateTime.now();

    if (now.isBefore(qrData.validFromDateTime())) {
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS IS INVALID';
      results.addError(
          'Pass is only valid starting on ${qrData.validFromDisplayDate()}',
          source: RapidPassField.validFrom);
    }
    if (now.isAfter(qrData.validUntilDateTime())) {
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS HAS EXPIRED';
      results.addError('Pass expired on ${qrData.validUntilDisplayTimestamp()}',
          source: RapidPassField.validUntil);
    }
    if (qrData.idOrPlate.isEmpty) {
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS IS INVALID';
      results.addError('Invalid Plate Number',
          source: RapidPassField.idOrPlate);
    }
    return results;
  }

  static final skip32key = AsciiEncoder().convert('SKIP32_SECRET_KEY');

  static final knownPlateNumbers = {
    'NAZ2070': QrData(
        passType: PassType.Vehicle,
        apor: 'PI',
        controlCode: 329882482,
        validFrom: 1582992000,
        validUntil: 1588262400,
        idOrPlate: 'NAZ2070')
  };

  static String normalizePlateNumber(final String plateNumber) {
    return plateNumber.toUpperCase().split('\\s').join();
  }

  static ScanResults checkPlateNumber(final String plateNumber) {
    final normalizedPlateNumber = normalizePlateNumber(plateNumber);
    if (knownPlateNumbers.containsKey(normalizedPlateNumber)) {
      return ScanResults(knownPlateNumbers[normalizedPlateNumber]);
    } else {
      return ScanResults.invalidPass;
    }
  }

  Future<ScanResults> checkControlCode(final String controlCode) async {
    final String normalizedControlCode = controlCode.toUpperCase();
    final validPass = await apiRepository.localDatabaseService
        .getValidPassByStringControlCode(normalizedControlCode);
    if (validPass != null) {
      final QrData qrData = QrData(
          passType:
              validPass.passType == 1 ? PassType.Vehicle : PassType.Individual,
          apor: validPass.apor,
          controlCode: validPass.controlCode,
          validFrom: validPass.validFrom,
          validUntil: validPass.validUntil,
          idOrPlate: validPass.idOrPlate);
      return ScanResults(qrData);
    } else {
      return ScanResults.invalidPass;
    }
  }
}
