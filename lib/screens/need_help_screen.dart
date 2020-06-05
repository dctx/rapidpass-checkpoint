import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rapidpass_checkpoint/common/constants/rapid_asset_constants.dart';
import 'package:rapidpass_checkpoint/helpers/url_launcher_helper.dart';

class NeedHelp extends StatelessWidget {
  static final String routeName = "/need_help";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(
                        RapidAssetConstants.rapidPassLogoPurple,
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'RapidPass.ph',
                      style: TextStyle(
                        fontSize: 22.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "If you are having trouble with the Checkpoint App, see training manual provided.\n\n" +
                    "If you can't find the answer in the training manual, please text your concerns to 09611071047 and we will get back to you as soon as we can.\n\n" +
                    "Please indicate all the issues that you are having via text.\n\n" +
                    "For example: Cannot update database even mobile data is open; all scans are invalid; cannot update new APK\n\n" +
                    "Thank you.",
              ),
              SizedBox(height: 25),
              InkWell(
                onTap: () => URLLauncherHelper.launchMail(
                  'rapidpass-dctx@devcon.ph',
                ),
                child: _buildSocial(
                  ctx: context,
                  socialname: 'rapidpass-dctx@devcon.ph',
                  socialIcon: FontAwesomeIcons.envelope,
                ),
              ),
              SizedBox(height: 15),
              InkWell(
                onTap: () => URLLauncherHelper.launchFacebook(
                    '114422283533958', 'rapidpassph'),
                child: _buildSocial(
                  ctx: context,
                  socialname: 'facebook.com/rapidpassph',
                  socialIcon: FontAwesomeIcons.facebookF,
                ),
              ),
              SizedBox(height: 15),
              InkWell(
                onTap: () => URLLauncherHelper.launchUrl(
                    'https://twitter.com/rapidpassph'),
                child: _buildSocial(
                  ctx: context,
                  socialname: 'twitter.com/rapidpassph',
                  socialIcon: FontAwesomeIcons.twitter,
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocial(
      {String socialname, IconData socialIcon, BuildContext ctx}) {
    return Row(
      children: <Widget>[
        Icon(
          socialIcon,
          color: Theme.of(ctx).primaryColor,
          size: 20,
        ),
        SizedBox(width: 10),
        Text(
          socialname,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
