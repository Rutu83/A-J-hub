import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Fram3 extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String emailAddress;
  final String address;

  const Fram3({
    Key? key,
    required this.businessName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.address,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator Group1Widget - GROUP
    return Stack(
        children: <Widget>[
          Positioned(
              top: 0,
              left: 0,
              child: Container(
                  width: 1620,
                  height: 1620,
                  decoration: BoxDecoration(
                    image : DecorationImage(
                        image: AssetImage('assets/frames/fr2.jpg'),
                        fit: BoxFit.fitWidth
                    ),
                  )
              )
          ),Positioned(
              top: 1463,
              left: 91,
              child: Text(emailAddress, textAlign: TextAlign.left, style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Inter',
                  fontSize: 42,
                  letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.normal,
                  height: 1
              ),)
          ),Positioned(
              top: 1462,
              left: 832,
              child: Text('www.alinone.com', textAlign: TextAlign.left, style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Inter',
                  fontSize: 42,
                  letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.normal,
                  height: 1
              ),)
          ),Positioned(
              top: 1368,
              left: 732,
              child: Text(phoneNumber, textAlign: TextAlign.left, style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Inter',
                  fontSize: 42,
                  letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.normal,
                  height: 1
              ),)
          ),Positioned(
              top: 1553,
              left: 91,
              child: Text(address, textAlign: TextAlign.left, style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontFamily: 'Inter',
                  fontSize: 42,
                  letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.normal,
                  height: 1
              ),)
          ),
        ]
    );
  }

}

