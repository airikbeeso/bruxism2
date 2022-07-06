import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

late String likes, gotpoints, popularity, totalPoints, details, pac, date;

Widget glassCard(var context) {
  double textScaleFactor = MediaQuery.textScaleFactorOf(context);
  return GlassmorphicFlexContainer(
      flex: 2,
      borderRadius: 35,
      padding: const EdgeInsets.all(25),
      blur: 14,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0FFFFF).withOpacity(0.2),
          const Color(0xFF0FFFFF).withOpacity(0.2),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0FFFFF).withOpacity(1),
          const Color(0xFFFFFFFF),
          const Color(0xFF0FFFFF).withOpacity(1),
        ],
      ),
      child: Column(
        key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                Image.network(
                  "https://pub.dev/static/img/pub-dev-logo-2x.png?hash=umitaheu8hl7gd3mineshk2koqfngugi",
                  scale: 1.7,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.003),
                InkWell(
                  onTap: () {
                    // launchPubDev();
                  },
                  child: Text(
                    pac,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 24.0 / textScaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  "Published on $date",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16.0 / textScaleFactor,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Published by Ritick Saha\n(The Flutter Foundry)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontStyle: FontStyle.italic,
                    fontSize: 16.0 / textScaleFactor,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(
                    text:
                        '${int.parse(likes) > 1000 ? int.parse(likes).toStringAsExponential() : int.parse(likes)}',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 26.0 / textScaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\nLikes',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 15.0 / textScaleFactor,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '$gotpoints',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 26.0 / textScaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '/$totalPoints',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 15.0 / textScaleFactor,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: '\n    Pub Point',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 15.0 / textScaleFactor,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: ' $popularity%',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 26.0 / textScaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\nPopularity',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 15.0 / textScaleFactor,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Small Package Discription:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontStyle: FontStyle.italic,
                    fontSize: 18.0 / textScaleFactor,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "$details",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0 / textScaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.001),
              ],
            ),
          ),
        ],
      ));
}
