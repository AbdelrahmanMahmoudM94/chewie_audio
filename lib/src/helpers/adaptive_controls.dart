// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:chewie_audio/chewie_audio.dart';

class AdaptiveControls extends StatelessWidget {
  const AdaptiveControls({
    Key? key,
    this.barBackGroundColor,
    this.barHeight,
    this.iconColor,
    this.hideSubtitle = false,
    this.onToggleSubtitle,
    this.borderRadius,
    this.ccIconSize,
    this.muteIconSize,
    this.pauseIconSize,
    this.playIconSize,
    this.seekTimeFontSize,
    this.skipBackwardSize,
    this.skipForwardSize,
    this.speedIconSize,
    this.volumeIconSize,
    this.barBackGroundColorSpeedDialog,
    this.textColorSpeedDialog,
    this.indicatorSpeedDialog,
    this.dividerColorSpeedDialog,
    this.progressBarHeight,
    this.currentSubtitle,
  }) : super(key: key);
  final Color? barBackGroundColor;
  final Color? iconColor;
  final double? barHeight;
  final Function(Subtitle)? currentSubtitle;
  final Function(bool)? onToggleSubtitle;
  final Color? barBackGroundColorSpeedDialog;
  final Color? textColorSpeedDialog;
  final Color? dividerColorSpeedDialog;
  final bool hideSubtitle;
  final BorderRadiusGeometry? borderRadius;
  final double? playIconSize;
  final double? pauseIconSize;
  final double? skipForwardSize;
  final double? skipBackwardSize;
  final double? volumeIconSize;
  final double? muteIconSize;
  final double? ccIconSize;
  final double? speedIconSize;
  final double? seekTimeFontSize;
  final Color? indicatorSpeedDialog;
    final double? progressBarHeight;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.fuchsia:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const MaterialDesktopControls();

      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return CupertinoControls(
          barBackGroundColor: barBackGroundColor,
          barHeight: barHeight,
          onToggleSubtitle: onToggleSubtitle,
          hideSubtitle: hideSubtitle,
          barBackGroundColorSpeedDialog: barBackGroundColorSpeedDialog,
          dividerColorSpeedDialog: dividerColorSpeedDialog,
          textColorSpeedDialog: textColorSpeedDialog,
          borderRadius: borderRadius,
          progressBarHeight: progressBarHeight,
          ccIconSize: ccIconSize,
          muteIconSize: muteIconSize,
          pauseIconSize: pauseIconSize,
          playIconSize: playIconSize,
          seekTimeFontSize: seekTimeFontSize,
          skipBackwardSize: skipBackwardSize,
          skipForwardSize: skipForwardSize,
          speedIconSize: speedIconSize,
          volumeIconSize: volumeIconSize,
          indicatorSpeedDialog: indicatorSpeedDialog,
          currentSubtitle: currentSubtitle,
          backgroundColor: const Color.fromRGBO(41, 41, 41, 0.7),
          iconColor: iconColor ?? const Color.fromARGB(255, 200, 200, 200),
        );
      default:
        return const MaterialDesktopControls();
    }
  }
}
