import 'package:flutter/cupertino.dart';

class DeviceUtils {
  static double getDeviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getDeviceWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}
