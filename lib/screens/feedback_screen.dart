import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:rapidpass_checkpoint/components/flavor_banner.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

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
                  WebviewScaffold(
                    url: "https://rapidpass.ph/qcp-feedback",
                    withZoom: true,
                    withJavascript: true,
                    hidden: true,
                  ),
                ],
              );
            },
          )),
    );
  }
}
