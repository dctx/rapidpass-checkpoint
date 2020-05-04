import 'package:flutter/material.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _showLoading = true;

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: Scaffold(
          appBar: AppBar(title: Text('Feedback')),
          body: Builder(
            builder: (BuildContext context) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  WebView(
                    initialUrl: 'https://rapidpass.ph/qcp-feedback',
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (value) {
                      setState(() {
                        _showLoading = false;
                      });
                    },
                  ),
                  _showLoading
                      ? Container(
                          color: Colors.white,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              );
            },
          )),
    );
  }
}
