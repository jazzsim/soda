import 'package:flutter/material.dart';

class Device {
  final double width;
  final double height;

  Size get size => Size(width, height);

  double get aspectRatio => width / height;

  bool isHorizontal() {
    return width > height;
  }

  Device(this.width, this.height);
}

class DeviceSizeService {
  static late Device _device;

  static Device get device => _device;

  static DeviceSizeService get instance => DeviceSizeService();

  Future<void> initialize(BuildContext context) async => _device = Device(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
}
