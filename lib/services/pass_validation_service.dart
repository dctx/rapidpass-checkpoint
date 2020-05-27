import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:rapidpass_checkpoint/models/app_secrets.dart';
import 'package:rapidpass_checkpoint/models/qr_data.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/repository/api_repository.dart';
import 'package:rapidpass_checkpoint/utils/hmac_sha256.dart';
import 'package:rapidpass_checkpoint/utils/qr_code_decoder.dart';

class PassValidationService {
  final ApiRepository apiRepository;

  PassValidationService(this.apiRepository);

  static ScanResults deserializeAndValidate(
      final AppSecrets appSecrets, final String base64Encoded) {
    try {
      final decodedFromBase64 = base64.decode(base64Encoded);
      final asHex = hex.encode(decodedFromBase64);
      print('QR Code as hex => $asHex (${asHex.length} codes)');
      final buffer = decodedFromBase64 is Uint8List
          ? decodedFromBase64.buffer
          : Uint8List.fromList(decodedFromBase64).buffer;
      final byteData = ByteData.view(buffer);
      final Uint8List encryptionKey = hex.decode(appSecrets.encryptionKey);
      final qrData = QrCodeDecoder(encryptionKey).convert(byteData);
      final scanResults = validate(qrData);
      final Uint8List signingKey = hex.decode(appSecrets.signingKey);
      final signatureIsValid =
          HmacShac256.validateSignature(signingKey, decodedFromBase64);
      if (signatureIsValid) {
        scanResults.inputData = base64Encoded;
        scanResults.mode = ScanMode.QR_CODE;
        return scanResults;
      } else {
        final sr = ScanResults(null,
            resultMessage: 'ENTRY DENIED',
            allRed: true,
            status: ScanResultStatus.INVALID_RAPIDPASS_SIGNATURE,
            inputData: base64Encoded,
            mode: ScanMode.QR_CODE);
        sr.resultSubMessage = 'Invalid RapidPass';
        sr.addError('Invalid QR Data');
        return sr;
      }
    } on FormatException catch (fe) {
      print(fe.toString());
      final sr = ScanResults(null,
          resultMessage: 'NOT A VALID RAPIDPASS QR CODE',
          allRed: true,
          status: ScanResultStatus.INVALID_RAPIDPASS_QRDATA,
          inputData: base64Encoded,
          mode: ScanMode.QR_CODE);
      sr.resultSubMessage = 'Please try again';
      sr.addError('Invalid QR Data');
      return sr;
    } catch (e) {
      print(e.toString());
      final sr = ScanResults(null,
          resultMessage: 'ENTRY DENIED',
          allRed: true,
          status: ScanResultStatus.INVALID_QRCODE,
          inputData: base64Encoded,
          mode: ScanMode.QR_CODE);
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
      results.status = ScanResultStatus.INVALID_START_DATE;
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS IS INVALID';
      results.addError(
          'Pass is only valid starting on ${qrData.validFromDisplayDate()}',
          source: RapidPassField.validFrom);
    }
    if (now.isAfter(qrData.validUntilDateTime())) {
      results.status = ScanResultStatus.INVALID_END_DATE;
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS HAS EXPIRED';
      results.addError('Pass expired on ${qrData.validUntilDisplayTimestamp()}',
          source: RapidPassField.validUntil);
    }
    if (qrData.passType == PassType.Vehicle &&
        (qrData.idOrPlate == null || qrData.idOrPlate.isEmpty)) {
      results.status = ScanResultStatus.INVALID_PLATE_NUMBER;
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS IS INVALID';
      results.addError('Invalid Plate Number',
          source: RapidPassField.idOrPlate);
    }
    if (qrData.status == 'REVOKED') {
      results.status = ScanResultStatus.RAPIDPASS_REVOKED;
      results.resultMessage = 'ENTRY DENIED';
      results.resultSubMessage = 'RAPIDPASS IS REVOKED';
      results.addError('Revoked status.', source: RapidPassField.status);
    }
    return results;
  }

  static String normalizePlateNumber(final String plateNumber) {
    return plateNumber.toUpperCase().split('\\s').join();
  }

  Future<ScanResults> checkPlateNumber(final String plateNumber) async {
    final normalizedPlateNumber = normalizePlateNumber(plateNumber);
    final validPass = await apiRepository.localDatabaseService
        .getValidPassByIdOrPlate(normalizedPlateNumber);
    ScanResults sr;
    if (validPass != null) {
      final QrData qrData = QrData(
          passType:
              validPass.passType == 1 ? PassType.Vehicle : PassType.Individual,
          apor: validPass.apor,
          controlCode: validPass.controlCode,
          validFrom: validPass.validFrom,
          validUntil: validPass.validUntil,
          idOrPlate: validPass.idOrPlate,
          status: validPass.status);
      sr = validate(qrData);
    } else {
      sr = ScanResults(null,
              resultMessage: 'ENTRY DENIED',
              allRed: true,
              status: ScanResultStatus.PLATE_NUMBER_NOT_FOUND)
          .addError('ENTRY DENIED');
    }
    sr.mode = ScanMode.PLATE_NUMBER;
    sr.inputData = normalizedPlateNumber;
    return sr;
  }

  Future<ScanResults> checkControlCode(final String controlCode) async {
    final String normalizedControlCode = controlCode.toUpperCase();
    final validPass = await apiRepository.localDatabaseService
        .getValidPassByStringControlCode(normalizedControlCode);
    ScanResults sr;
    if (validPass != null) {
      final QrData qrData = QrData(
          passType:
              validPass.passType == 1 ? PassType.Vehicle : PassType.Individual,
          apor: validPass.apor,
          controlCode: validPass.controlCode,
          validFrom: validPass.validFrom,
          validUntil: validPass.validUntil,
          idOrPlate: validPass.idOrPlate,
          status: validPass.status,
          name: sr.qrData.name);
      sr = validate(qrData);
    } else {
      sr = ScanResults(null,
              resultMessage: 'ENTRY DENIED',
              allRed: true,
              status: ScanResultStatus.CONTROL_CODE_NOT_FOUND)
          .addError('ENTRY DENIED');
    }
    sr.mode = ScanMode.CONTROL_CODE;
    sr.inputData = normalizedControlCode;
    return sr;
  }

  Future<ScanResults> checkControlNumber(final int controlNumber) async {
    final validPass = await apiRepository.localDatabaseService
        .getValidPassByIntegerControlCode(controlNumber);
    ScanResults sr;
    if (validPass != null) {
      final QrData qrData = QrData(
          passType:
              validPass.passType == 1 ? PassType.Vehicle : PassType.Individual,
          apor: validPass.apor,
          controlCode: validPass.controlCode,
          validFrom: validPass.validFrom,
          validUntil: validPass.validUntil,
          idOrPlate: validPass.idOrPlate,
          status: validPass.status,
          name: sr.qrData.name);
      sr = validate(qrData);
    } else {
      sr = ScanResults(null,
              resultMessage: 'ENTRY DENIED',
              allRed: true,
              status: ScanResultStatus.CONTROL_NUMBER_NOT_FOUND)
          .addError('ENTRY DENIED');
    }
    sr.mode = ScanMode.CONTROL_NUMBER;
    sr.inputData = controlNumber.toString();
    return sr;
  }

  Future<ScanResults> checkRevokePass(final ScanResults sr) async {
    final String normalizedControlCode =
        sr.qrData.controlCodeAsString().toUpperCase();
    final revokePass = await apiRepository.localDatabaseService
        .getRevokePass(normalizedControlCode);
    ScanResults result;
    if (revokePass != null) {
      // This RapidPass is in the Revocation list,
      // so mark it as REVOKED, then re-validate.
      final QrData qrData = QrData(
          passType: sr.qrData.passType,
          apor: sr.qrData.apor,
          controlCode: sr.qrData.controlCode,
          validFrom: sr.qrData.validFrom,
          validUntil: sr.qrData.validUntil,
          idOrPlate: sr.qrData.idOrPlate,
          status: 'REVOKED',
          name: sr.qrData.name);
      result = validate(qrData);
      result.mode = sr.mode;
      result.inputData = sr.inputData;
    } else {
      result = sr;
    }
    return result;
  }
}
