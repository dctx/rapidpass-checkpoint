import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rapidpass_checkpoint/models/check_plate_or_control_args.dart';
import 'package:rapidpass_checkpoint/models/scan_results.dart';
import 'package:rapidpass_checkpoint/screens/check_plate_or_control_results_screen.dart';
import 'package:rapidpass_checkpoint/services/pass_validation_service.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class CheckPlateOrControlScreen extends StatefulWidget {
  static const routeNamePlateNumber = '/checkPlateNumber';
  static const routeNameControlCode = '/checkControlCode';

  final CheckPlateOrControlScreenModeType screenModeType;

  const CheckPlateOrControlScreen(this.screenModeType);

  @override
  State<StatefulWidget> createState() {
    return _CheckPlateOrControlScreenState();
  }
}

class _CheckPlateOrControlScreenState extends State<CheckPlateOrControlScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _formFieldTextEditingController;

  CheckPlateOrControlScreenModeType get _screenModeType =>
      widget.screenModeType;

  bool _formHasErrors = false;

  // TODO: Remove this soon
  String _hardCodedValue = '123456';

  @override
  void initState() {
    super.initState();
    _formFieldTextEditingController = TextEditingController()
      ..addListener(() {
        if (_formHasErrors) {
          setState(() {
            _formHasErrors = false;
          });
        }
      });
  }

  String _getAppBarText() {
    if (_screenModeType == CheckPlateOrControlScreenModeType.plate) {
      return "Check Plate Number";
    } else {
      return "Check Control Number";
    }
  }

  String _getHelpText() {
    if (_screenModeType == CheckPlateOrControlScreenModeType.plate) {
      return "Type the vehicle's plate number or conduction sticker below:";
    } else {
      return "Type the person's control number receive via SMS below:";
    }
  }

  String _getFormFieldLabel() {
    if (_screenModeType == CheckPlateOrControlScreenModeType.plate) {
      return "Plate Number / Conduction Sticker";
    } else {
      return "Control Number";
    }
  }

  String _getSubmitCtaText() {
    if (_screenModeType == CheckPlateOrControlScreenModeType.plate) {
      return "Check Plate Number";
    } else {
      return "Check Control Number";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final CheckPlateOrControlScreenArgs args =
        ModalRoute.of(context).settings.arguments;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_getAppBarText()),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Text(_getHelpText()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 48.0),
                      child: Text(_getFormFieldLabel()),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        height: 80.0,
                        child: TextFormField(
                          controller: _formFieldTextEditingController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLength: _screenModeType ==
                                  CheckPlateOrControlScreenModeType.plate
                              ? 11
                              : 10,
                          maxLengthEnforced: true,
                          inputFormatters: [
                            WhitelistingTextInputFormatter(
                                RegExp("[a-zA-Z0-9]"))
                          ],
                          autofocus: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              setState(() {
                                _formHasErrors = true;
                              });
                              return 'This field is required.';
                            } else if (value.isNotEmpty) {
                              setState(() {
                                _formHasErrors = false;
                              });
                              final ScanResults scanResults =
                                  (_screenModeType ==
                                          CheckPlateOrControlScreenModeType
                                              .plate)
                                      ? PassValidationService.checkPlateNumber(
                                          value)
                                      : PassValidationService.checkControlCode(
                                          value);
                              final CheckPlateOrControlScreenResults
                                  checkResults =
                                  CheckPlateOrControlScreenResults(
                                      _screenModeType, scanResults);
                              Navigator.pushNamed(
                                  context, CheckPlateOrControlCodeResultsScreen.routeName,
                                  arguments: checkResults);
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(26.0),
                child: FlatButton(
                  child: Text(
                    _getSubmitCtaText(),
                    style: TextStyle(fontSize: 16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  color: green300,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16.0),
                  onPressed: () {
                    _formKey.currentState.validate();

                    if (_formFieldTextEditingController.text ==
                            _hardCodedValue &&
                        !_formHasErrors) {
                      // TODO: Add route to the success / invalid screen
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
