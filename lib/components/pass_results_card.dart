import 'package:flutter/material.dart';

const borderRadius = 12.0;

class PassResultsData {
  final String label;
  final String value;
  final String errorMessage;

  PassResultsData({this.label, this.value, String errorMessage})
      : this.errorMessage = errorMessage;
}

/// This is used to display the "pass" or "fail" card
class PassResultsCard extends StatelessWidget {
  final String iconName;
  final String headerText;
  final List<PassResultsData> data;
  final Color color;
  PassResultsCard({this.iconName, this.headerText, this.data, this.color});

  @override
  Widget build(BuildContext context) {
    final tableChildren = this.data.map((row) {
      debugPrint('row: $row');
      debugPrint('row.errorMessage: ${row.errorMessage}');
      // TODO: Replace Colors.black with some theme color
      final textColor = row.errorMessage != null ? this.color : Colors.black;
      final tableTextStyle = TextStyle(fontSize: 18.0, color: textColor);
      return TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            row.label,
            style: tableTextStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            row.value,
            textAlign: TextAlign.right,
            style: tableTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        )
      ]);
    }).toList();
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: this.color, width: 1.0),
            borderRadius: BorderRadius.circular(borderRadius)),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius)),
                  color: this.color,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image(
                          width: 80.0,
                          image: AssetImage('assets/${this.iconName}.png'),
                        ),
                      ),
                      Text(
                        this.headerText,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Table(children: tableChildren)),
              )
            ])));
  }
}
