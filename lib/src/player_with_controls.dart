// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';

import 'package:chewie_audio/src/chewie_player.dart';
import 'package:chewie_audio/src/helpers/adaptive_controls.dart';

class PlayerWithControls extends StatelessWidget {
  const PlayerWithControls(
      {Key? key,
      this.barBackGroundColor,
      this.barHeight,
      this.borderRadius,
      this.currentSubtitle,
      this.hideSubtitle = false,
      this.barBackGroundColorSpeedDialog,
      this.dividerColorSpeedDialog,
      this.textColorSpeedDialog,
      this.iconColor,
      this.onToggleSubtitle,
      this.ccIconSize,
      this.muteIconSize,
      this.pauseIconSize,
      this.progressBarHeight,
      this.playIconSize,
      this.seekTimeFontSize,
      this.skipBackwardSize,
      this.skipForwardSize,
      this.speedIconSize,
      this.indicatorSpeedDialog,
      this.volumeIconSize})
      : super(key: key);
  final Color? barBackGroundColor;
  final double? barHeight;
  final Color? iconColor;
  final bool hideSubtitle;
  final Function(Subtitle)? currentSubtitle;

  final BorderRadiusGeometry? borderRadius;
  final Color? barBackGroundColorSpeedDialog;
  final Color? textColorSpeedDialog;
  final Color? dividerColorSpeedDialog;
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
  final Function(bool)? onToggleSubtitle;
    final double? progressBarHeight;
  @override
  Widget build(BuildContext context) {
    final ChewieAudioController chewieController =
        ChewieAudioController.of(context);

    Widget buildControls(
      BuildContext context,
      ChewieAudioController chewieController,
    ) {
      return chewieController.showControls
          ? chewieController.customControls ??
              AdaptiveControls(
                  barBackGroundColor: barBackGroundColor,
                  barHeight: barHeight,
                  iconColor: iconColor,
                  progressBarHeight: progressBarHeight,
                  barBackGroundColorSpeedDialog: barBackGroundColorSpeedDialog,
                  dividerColorSpeedDialog: dividerColorSpeedDialog,
                  textColorSpeedDialog: textColorSpeedDialog,
                  hideSubtitle: hideSubtitle,
                  borderRadius: borderRadius,
                  currentSubtitle: currentSubtitle,
                  onToggleSubtitle: onToggleSubtitle,
                  ccIconSize: ccIconSize,
                  muteIconSize: muteIconSize,
                  pauseIconSize: pauseIconSize,
                  playIconSize: playIconSize,
                  seekTimeFontSize: seekTimeFontSize,
                  skipBackwardSize: skipBackwardSize,
                  skipForwardSize: skipForwardSize,
                  speedIconSize: speedIconSize,
                  indicatorSpeedDialog: indicatorSpeedDialog,
                  volumeIconSize: volumeIconSize)
          : const SizedBox();
    }

    Widget buildPlayerWithControls(
      ChewieAudioController chewieController,
      BuildContext context,
    ) {
      return buildControls(context, chewieController);
    }

    return SizedBox(
      // width: MediaQuery.of(context).size.width,
      child: buildPlayerWithControls(chewieController, context),
    );
  }
}
