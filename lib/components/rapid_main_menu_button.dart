import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapidpass_checkpoint/themes/default.dart';

class RapidMainMenuButton extends StatefulWidget {
  final String title;
  final String iconPath;
  final String iconPathInverted;
  final VoidCallback onPressed;
  final Color textColor;
  final Color borderColor;

  RapidMainMenuButton({
    @required this.title,
    @required this.iconPath,
    @required this.iconPathInverted,
    @required this.onPressed,
    this.textColor = deepPurple900,
    this.borderColor = deepPurple900,
  });

  @override
  _RapidMainMenuButtonState createState() => _RapidMainMenuButtonState();
}

class _RapidMainMenuButtonState extends State<RapidMainMenuButton> {
  Color _textColor = Colors.deepPurple, _backgroundColor = Colors.white;
  SvgPicture _svgPicture;
  final double _svgPictureSize = 72.0;

  @override
  void initState() {
    super.initState();
    _textColor = widget.textColor;
    _backgroundColor = Colors.white;
    _svgPicture = SvgPicture.asset(widget.iconPath, width: _svgPictureSize);
  }

  void _changeColor(bool value) {
    setState(() {
      if (value) {
        _textColor = Colors.white;
        _backgroundColor = deepPurple600;
        _svgPicture =
            SvgPicture.asset(widget.iconPathInverted, width: _svgPictureSize);
      } else {
        _textColor = widget.textColor;
        _backgroundColor = Colors.white;
        _svgPicture = SvgPicture.asset(widget.iconPath, width: _svgPictureSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: widget.onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
            ),
            child: SizedBox(
              height: 120.0,
              width: size.width * 0.80,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.0,
                    color: widget.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: _backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _svgPicture,
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.title.copyWith(
                                fontSize: 22,
                                color: _textColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
