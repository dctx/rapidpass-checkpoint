import 'package:rapidpass_checkpoint/models/qr_data.dart';

enum RapidPassField {
  passType,
  controlCode,
  apor,
  validFrom,
  validUntil,
  idOrPlate,
  status,
  name,
  signature
}

final fieldNames = {
  RapidPassField.passType: 'Pass Type',
  RapidPassField.controlCode: 'Control Number',
  RapidPassField.apor: 'APOR',
  RapidPassField.validFrom: 'Valid From',
  RapidPassField.validUntil: 'Valid Until',
  RapidPassField.name: 'Name',
  RapidPassField.signature: 'Signature'
};

String getFieldName(final RapidPassField field) {
  return fieldNames[field];
}

class ValidationError {
  final RapidPassField source;
  final String errorMessage;

  ValidationError(this.errorMessage, {this.source});
}

class ScanMode {
  final int value;
  final String name;

  const ScanMode._internal(this.value, this.name);

  @override
  String toString() {
    return 'value: $value, name: $name';
  }

  static const QR_CODE = const ScanMode._internal(0, 'QR Code');
  static const CONTROL_NUMBER = const ScanMode._internal(1, 'Control Number');
  static const CONTROL_CODE = const ScanMode._internal(2, 'Control Code');
  static const PLATE_NUMBER = const ScanMode._internal(3, 'Plate Number');
}

class ScanResultStatus {
  final int value;
  final String mainMessage;
  final String subMessage;

  const ScanResultStatus._internal(this.value,
      {this.mainMessage = '', this.subMessage = ''});

  @override
  String toString() {
    return 'value: $value, mainMessage: $mainMessage, subMessage: $subMessage';
  }

  static const _statusList = [
    ENTRY_APPROVED,
    INVALID_RAPIDPASS_SIGNATURE,
    INVALID_RAPIDPASS_QRDATA,
    INVALID_QRCODE,
    INVALID_START_DATE,
    INVALID_END_DATE,
    INVALID_PLATE_NUMBER,
    RAPIDPASS_REVOKED,
    PLATE_NUMBER_NOT_FOUND,
    CONTROL_CODE_NOT_FOUND,
    CONTROL_NUMBER_NOT_FOUND,
  ];

  static const ENTRY_APPROVED = const ScanResultStatus._internal(0,
      mainMessage: 'ENTRY APPROVED', subMessage: '');
  static const INVALID_RAPIDPASS_SIGNATURE = const ScanResultStatus._internal(1,
      mainMessage: 'ENTRY DENIED', subMessage: 'Invalid RapidPass');
  static const INVALID_RAPIDPASS_QRDATA = const ScanResultStatus._internal(2,
      mainMessage: 'NOT A VALID RAPIDPASS QR CODE',
      subMessage: 'Please try again');
  static const INVALID_QRCODE = const ScanResultStatus._internal(3,
      mainMessage: 'ENTRY DENIED', subMessage: 'QR CODE INVALID');
  static const INVALID_START_DATE = const ScanResultStatus._internal(4,
      mainMessage: 'ENTRY DENIED', subMessage: 'RAPIDPASS IS INVALID');
  static const INVALID_END_DATE = const ScanResultStatus._internal(5,
      mainMessage: 'ENTRY DENIED', subMessage: 'RAPIDPASS HAS EXPIRED');
  static const INVALID_PLATE_NUMBER = const ScanResultStatus._internal(6,
      mainMessage: 'ENTRY DENIED', subMessage: 'RAPIDPASS IS INVALID');
  static const RAPIDPASS_REVOKED = const ScanResultStatus._internal(7,
      mainMessage: 'ENTRY DENIED', subMessage: 'RAPIDPASS IS REVOKED');
  static const PLATE_NUMBER_NOT_FOUND = const ScanResultStatus._internal(8,
      mainMessage: 'ENTRY DENIED', subMessage: 'PLATE NUMBER NOT FOUND');
  static const CONTROL_CODE_NOT_FOUND = const ScanResultStatus._internal(9,
      mainMessage: 'ENTRY DENIED', subMessage: 'CONTROL CODE NOT FOUND');
  static const CONTROL_NUMBER_NOT_FOUND = const ScanResultStatus._internal(10,
      mainMessage: 'ENTRY DENIED', subMessage: 'CONTROL NUMBER NOT FOUND');
  static const UNKNOWN_STATUS = const ScanResultStatus._internal(null,
      mainMessage: 'UNKNOWN STATUS', subMessage: 'Unknown status.');

  static ScanResultStatus getStatusFromValue(int value) {
    for (var status in _statusList) {
      if (value == status.value) {
        return status;
      }
    }
    return UNKNOWN_STATUS;
  }
}

class ScanResults {
  final QrData qrData;
  final List<ValidationError> errors = List();
  String resultMessage;
  String resultSubMessage;
  bool allRed = false;
  String inputData;
  ScanMode mode;
  ScanResultStatus status;

  ScanResults(this.qrData,
      {this.resultMessage = 'ENTRY APPROVED',
      this.allRed = false,
      String resultSubMessage,
      this.status = ScanResultStatus.ENTRY_APPROVED,
      this.inputData,
      this.mode});

  ScanResults addError(String errorMessage, {RapidPassField source}) {
    this.errors.add(ValidationError(errorMessage, source: source));
    return this;
  }

  ValidationError findErrorForSource(final RapidPassField source) {
    for (final error in this.errors) {
      if (error.source == source) {
        return error;
      }
    }
    return null;
  }

  bool get isValid => this.errors.isEmpty;
}
