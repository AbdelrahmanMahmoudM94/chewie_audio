import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chewie_audio/src/animated_play_pause.dart';
import 'package:chewie_audio/src/chewie_player.dart';
import 'package:chewie_audio/src/chewie_progress_colors.dart';
import 'package:chewie_audio/src/cupertino/cupertino_progress_bar.dart';
import 'package:chewie_audio/src/cupertino/widgets/cupertino_options_dialog.dart';
import 'package:chewie_audio/src/helpers/utils.dart';
import 'package:chewie_audio/src/models/option_item.dart';
import 'package:chewie_audio/src/models/subtitle_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({
    required this.backgroundColor,
    required this.iconColor,
    this.barBackGroundColor,
    this.barHeight,
    this.showPlayButton = true,
    this.onToggleSubtitle,
    this.barBackGroundColorSpeedDialog,
    this.textColorSpeedDialog,
    this.dividerColorSpeedDialog,
    this.hideSubtitle = false,
    this.borderRadius,
    this.ccIconSize,
    this.muteIconSize,
    this.pauseIconSize,
    this.playIconSize,
    this.seekTimeFontSize,
    this.skipBackwardSize,
    this.skipForwardSize,
    this.speedIconSize,
    this.indicatorSpeedDialog,
    this.volumeIconSize,
    this.currentSubtitle,
    this.progressBarHeight,
    Key? key,
  }) : super(key: key);

  final Color backgroundColor;
  final Color iconColor;
  final bool showPlayButton;
  final Color? barBackGroundColor;
  final double? barHeight;
  final bool hideSubtitle;
  final Function(Subtitle)? currentSubtitle;
  final Function(bool)? onToggleSubtitle;
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

  final double? progressBarHeight;
  final BorderRadiusGeometry? borderRadius;
  @override
  State<StatefulWidget> createState() {
    return _CupertinoControlsState();
  }
}

class _CupertinoControlsState extends State<CupertinoControls>
    with SingleTickerProviderStateMixin {
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  final marginSize = 5.0;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;
  Duration? _subtitlesPosition;
  bool _subtitleOn = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  late VideoPlayerController controller;

  // We know that _chewieController is set in didChangeDependencies
  ChewieAudioController get chewieController => _chewieController!;
  ChewieAudioController? _chewieController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder!(
              context,
              chewieController.videoPlayerController.value.errorDescription!,
            )
          : const Center(
              child: Icon(
                CupertinoIcons.exclamationmark_circle,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight =
        widget.barHeight ?? (orientation == Orientation.portrait ? 30.0 : 47.0);

    return Stack(
      children: [
        if (_displayBufferingIndicator)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Column(
          children: <Widget>[
            if (_subtitleOn) _buildSubtitles(chewieController.subtitle!),
            _buildBottomBar(backgroundColor, iconColor, barHeight),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieAudioController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  GestureDetector _buildOptionsButton(
    Color iconColor,
    double barHeight,
  ) {
    final options = <OptionItem>[];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return GestureDetector(
      onTap: () async {
        if (chewieController.optionsBuilder != null) {
          await chewieController.optionsBuilder!(context, options);
        } else {
          await showCupertinoModalPopup<OptionItem>(
            context: context,
            semanticsDismissible: true,
            builder: (context) => CupertinoOptionsDialog(
              options: options,
              cancelButtonText:
                  chewieController.optionsTranslation?.cancelButtonText,
            ),
          );
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        margin: const EdgeInsets.only(right: 6.0),
        child: Icon(
          Icons.more_vert,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSubtitles(Subtitles subtitles) {
    if (!_subtitleOn) {
      return const SizedBox();
    }
    if (_subtitlesPosition == null) {
      return const SizedBox();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition!);
    if (currentSubtitle.isEmpty) {
      return const SizedBox();
    }

    if (chewieController.subtitleBuilder != null) {
      widget.currentSubtitle?.call(currentSubtitle.first!);
      return const SizedBox.shrink();
    }

    //
    return Icon(
      Icons.closed_caption,
      color: widget.iconColor,
      size: 90,
    );
  }

  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: widget.barBackGroundColor ?? backgroundColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(10.0),
      ),
      child: chewieController.isLive
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildPlayPause(controller, iconColor, barHeight),
                _buildLive(iconColor),
                if (chewieController.allowMuting)
                  _buildMuteButton(
                    controller,
                    backgroundColor,
                    iconColor,
                    barHeight,
                  ),
              ],
            )
          : Row(
              children: <Widget>[
                _buildSkipBack(iconColor, barHeight),
                _buildPlayPause(controller, iconColor, barHeight),
                _buildSkipForward(iconColor, barHeight),
                _buildPosition(iconColor),
                _buildProgressBar(),
                _buildRemaining(iconColor),
                if (!widget.hideSubtitle)
                  _buildSubtitleToggle(iconColor, barHeight),
                if (chewieController.allowMuting)
                  _buildMuteButton(
                    controller,
                    backgroundColor,
                    iconColor,
                    barHeight,
                  ),
                if (chewieController.allowPlaybackSpeedChanging)
                  _buildSpeedButton(controller, iconColor, barHeight),
                if (chewieController.additionalOptions != null &&
                    chewieController.additionalOptions!(context).isNotEmpty)
                  _buildOptionsButton(iconColor, barHeight),
              ],
            ),
    );
  }

  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: barHeight,
          color: Colors.transparent,
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 6.0,
          ),
          child: Icon(
            _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
            color: iconColor,
            size: widget.volumeIconSize ?? 16,
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
          color: widget.iconColor,
          playing: controller.value.isPlaying,
          size: widget.playIconSize ?? 16.0,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: widget.seekTimeFontSize ?? 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue.duration - _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(
            color: iconColor, fontSize: widget.seekTimeFontSize ?? 12.0),
      ),
    );
  }

  Widget _buildSubtitleToggle(Color? iconColor, double barHeight) {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _subtitleOn = !_subtitleOn;
          widget.onToggleSubtitle?.call(_subtitleOn);
        });
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: SvgPicture.asset(
          "assets/svg/cc.svg",
          width: widget.ccIconSize ?? 16.0,
          colorFilter: iconColor == null
              ? null
              : ColorFilter.mode(
                  _subtitleOn ? iconColor : iconColor.withValues(alpha: 0.3),
                  BlendMode.srcIn),
        ),
      ),
    );
  }

  void _subtitleToggle() {}

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipBack,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_15,
          color: iconColor,
          size: widget.skipBackwardSize ?? 18.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: _skipForward,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_15,
          color: iconColor,
          size: widget.skipForwardSize ?? 18.0,
        ),
      ),
    );
  }

  GestureDetector _buildSpeedButton(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () async {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: true,
          context: context,
          builder: (context) => _PlaybackSpeedDialog(
            indicatorColor: widget.indicatorSpeedDialog,
            onSpeedChanged: (double chosenSpeed) {
              controller.setPlaybackSpeed(chosenSpeed);
            },
            barBackGroundColorSpeedDialog: widget.barBackGroundColorSpeedDialog,
            dividerColorSpeedDialog: widget.dividerColorSpeedDialog,
            iconColor: widget.iconColor,
            textColorSpeedDialog: widget.textColorSpeedDialog,
            speeds: chewieController.playbackSpeeds,
            selected: _latestValue.playbackSpeed,
          ),
        );
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(Icons.speed,
            size: widget.speedIconSize ?? 16.0, color: iconColor),
      ),
    );
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);

    _updateState();
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          barProgressHeight: widget.progressBarHeight,
          colors: chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _skipBack() {
    final beginning = Duration.zero.inMilliseconds;
    final skip =
        (_latestValue.position - const Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
  }

  void _skipForward() {
    final end = _latestValue.duration.inMilliseconds;
    final skip =
        (_latestValue.position + const Duration(seconds: 15)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }
}

class _PlaybackSpeedDialog extends StatelessWidget {
  const _PlaybackSpeedDialog(
      {Key? key,
      required List<double> speeds,
      required double selected,
      Color? barBackGroundColorSpeedDialog,
      Color? textColorSpeedDialog,
      Color? dividerColorSpeedDialog,
      Function(double)? onSpeedChanged,
      Color? indicatorColor,
      Color? iconColor})
      : _speeds = speeds,
        _selected = selected,
        _barBackGroundColorSpeedDialog = barBackGroundColorSpeedDialog,
        _textColorSpeedDialog = textColorSpeedDialog,
        _dividerColorSpeedDialog = dividerColorSpeedDialog,
        _iconColor = iconColor,
        _onSpeedChanged = onSpeedChanged,
        _indicatorColor = indicatorColor,
        super(key: key);

  final List<double> _speeds;
  final double _selected;
  final Color? _barBackGroundColorSpeedDialog;
  final Color? _textColorSpeedDialog;
  final Color? _dividerColorSpeedDialog;
  final Color? _iconColor;
  final Color? _indicatorColor;
  final Function(double)? _onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final selectedColor = CupertinoTheme.of(context).primaryColor;

    return Container(
        decoration: BoxDecoration(
            color: _barBackGroundColorSpeedDialog ?? Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r))),
        height: 0.54.sh,
        child: Column(
          children: [
            buildIndicator(color: _indicatorColor ?? selectedColor),
            SizedBox(
              height: 10.h,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _speeds.length,
              itemBuilder: (context, index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      _onSpeedChanged!(_speeds[index]);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_speeds[index] == _selected)
                          Icon(
                            Icons.check,
                            size: 20.0,
                            color: _iconColor ?? selectedColor,
                          ),
                        Text(
                          _speeds[index].toString(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _textColorSpeedDialog ??
                                CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  if (_speeds[index] != _speeds.last)
                    Divider(
                      color: _dividerColorSpeedDialog ?? Colors.grey[300],
                      height: 1,
                      thickness: 1,
                    ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Container buildIndicator({Color? color}) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      width: 70.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.w),
      ),
    );
  }
}
