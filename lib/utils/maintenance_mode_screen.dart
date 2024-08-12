

import 'package:allinone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';


class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
           'assets/lottie/maintenance_mode_light.json',
            height: 300,
          ),
          Text(language.lblUnderMaintenance, style: boldTextStyle(size: 18), textAlign: TextAlign.center).center(),
          8.height,
          Text(language.lblCatchUpAfterAWhile, style: secondaryTextStyle(), textAlign: TextAlign.center).center(),
          16.height,
          TextButton(
            onPressed: () async {
             // await setupFirebaseRemoteConfig();
              RestartAppWidget.init(context);
            },
            child: Text(language.lblRecheck),
          ),
        ],
      ),
    );
  }
}
