import 'dart:async';

import 'package:chewie_audio/src/chewie_progress_colors.dart';
import 'package:chewie_audio/src/models/option_item.dart';
import 'package:chewie_audio/src/models/options_translation.dart';
import 'package:chewie_audio/src/models/subtitle_model.dart';
import 'package:chewie_audio/src/player_with_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

typedef ChewieRoutePageBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  ChewieAudioControllerProvider controllerProvider,
);

/// An Audio Player with Material and Cupertino skins.
///
/// `video_player` is pretty low level. ChewieAudio wraps it in a friendly skin to
/// make it easy to use!
class ChewieAudio extends StatefulWidget {
  const ChewieAudio({
    Key? key,
    required this.controller,
    this.hideSubtitle = false,
    this.onToggleSubtitle,
    this.currentSubtitle,
  }) : super(key: key);

  /// The [ChewieController]
  final ChewieAudioController controller;
  final bool hideSubtitle;
  final Function(Subtitle)? currentSubtitle;
  final Function(bool)? onToggleSubtitle;

  @override
  ChewieAudioState createState() {
    return ChewieAudioState();
  }
}

class ChewieAudioState extends State<ChewieAudio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChewieAudioControllerProvider(
      controller: widget.controller,
      child: PlayerWithControls(
          currentSubtitle: widget.currentSubtitle,
          onToggleSubtitle: widget.onToggleSubtitle,
          hideSubtitle: widget.hideSubtitle,
          borderRadius: widget.controller.borderRadius,
          iconColor: widget.controller.iconColor,
          progressBarHeight: widget.controller.progressBarHeight,
          barBackGroundColorSpeedDialog:
              widget.controller.barBackGroundColorSpeedDialog,
          dividerColorSpeedDialog: widget.controller.dividerColorSpeedDialog,
          textColorSpeedDialog: widget.controller.textColorSpeedDialog,
          barBackGroundColor: widget.controller.barBackGroundColor,
          ccIconSize: widget.controller.ccIconSize,
          muteIconSize: widget.controller.muteIconSize,
          pauseIconSize: widget.controller.pauseIconSize,
          playIconSize: widget.controller.playIconSize,
          seekTimeFontSize: widget.controller.seekTimeFontSize,
          skipBackwardSize: widget.controller.skipBackwardSize,
          skipForwardSize: widget.controller.skipForwardSize,
          indicatorSpeedDialog: widget.controller.indicatorSpeedDialog,
          speedIconSize: widget.controller.speedIconSize,
          volumeIconSize: widget.controller.volumeIconSize,
          barHeight: widget.controller.barHeight),
    );
  }
}

/// The ChewieAudioController is used to configure and drive the Chewie Audio Player
/// Widgets. It provides methods to control playback, such as [pause] and
/// [play], as well as methods that control the visual appearance of the player.
///
/// To listen for changes to the playback, such as a change to the seek position of the
/// player, please use the standard information provided by the
/// `VideoPlayerController`.
class ChewieAudioController extends ChangeNotifier {
  ChewieAudioController(
      {required this.videoPlayerController,
      this.optionsTranslation,
      this.autoInitialize = false,
      this.autoPlay = false,
      this.draggableProgressBar = true,
      this.startAt,
      this.looping = false,
      this.cupertinoProgressColors,
      this.materialProgressColors,
      this.showControlsOnInitialize = true,
      this.showOptions = true,
      this.optionsBuilder,
      this.additionalOptions,
      this.showControls = true,
      this.borderRadius,
      this.transformationController,
      this.zoomAndPan = false,
      this.maxScale = 2.5,
      this.subtitle,
      this.subtitleBuilder,
      this.customControls,
      this.errorBuilder,
      this.isLive = false,
      this.iconColor,
      this.barBackGroundColor,
      this.barHeight,
      this.progressBarHeight,
      this.allowMuting = true,
      this.barBackGroundColorSpeedDialog,
      this.dividerColorSpeedDialog,
      this.textColorSpeedDialog,
      this.allowPlaybackSpeedChanging = true,
      this.playbackSpeeds = const [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2],
      this.progressIndicatorDelay,
      this.controlsSafeAreaMinimum = EdgeInsets.zero,
      this.ccIconSize,
      this.muteIconSize,
      this.pauseIconSize,
      this.playIconSize,
      this.seekTimeFontSize,
      this.skipBackwardSize,
      this.skipForwardSize,
      this.speedIconSize,
      this.indicatorSpeedDialog,
      this.volumeIconSize})
      : assert(
          playbackSpeeds.every((speed) => speed > 0),
          'The playbackSpeeds values must all be greater than 0',
        ) {
    _initialize();
  }

  ChewieAudioController copyWith({
    VideoPlayerController? videoPlayerController,
    OptionsTranslation? optionsTranslation,
    double? aspectRatio,
    bool? autoInitialize,
    bool? autoPlay,
    bool? draggableProgressBar,
    Duration? startAt,
    bool? looping,
    ChewieProgressColors? cupertinoProgressColors,
    ChewieProgressColors? materialProgressColors,
    Widget? placeholder,
    Widget? overlay,
    bool? showControlsOnInitialize,
    bool? showOptions,
    Future<void> Function(BuildContext, List<OptionItem>)? optionsBuilder,
    List<OptionItem> Function(BuildContext)? additionalOptions,
    bool? showControls,
    TransformationController? transformationController,
    bool? zoomAndPan,
    double? maxScale,
    Subtitles? subtitle,
    Widget Function(BuildContext, dynamic)? subtitleBuilder,
    Widget? customControls,
    Widget Function(BuildContext, String)? errorBuilder,
    bool? allowedScreenSleep,
    bool? isLive,
    bool? allowFullScreen,
    bool? allowMuting,
    bool? allowPlaybackSpeedChanging,
    bool? useRootNavigator,
    Duration? hideControlsTimer,
    EdgeInsets? controlsSafeAreaMinimum,
    List<double>? playbackSpeeds,
    List<SystemUiOverlay>? systemOverlaysOnEnterFullScreen,
    List<DeviceOrientation>? deviceOrientationsOnEnterFullScreen,
    List<SystemUiOverlay>? systemOverlaysAfterFullScreen,
    List<DeviceOrientation>? deviceOrientationsAfterFullScreen,
    Duration? progressIndicatorDelay,
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      ChewieAudioControllerProvider,
    )? routePageBuilder,
    Color? barBackGroundColor,
    double? barHeight,
    Color? iconColor,
    Color? barBackGroundColorSpeedDialog,
    Color? textColorSpeedDialog,
    Color? dividerColorSpeedDialog,
    Color? indicatorSpeedDialog,
    BorderRadiusGeometry? borderRadius,
    double? playIconSize,
    double? pauseIconSize,
    double? skipForwardSize,
    double? skipBackwardSize,
    double? volumeIconSize,
    double? muteIconSize,
    double? ccIconSize,
    double? speedIconSize,
    double? seekTimeFontSize,
    double? progressBarHeight,
  }) {
    return ChewieAudioController(
        draggableProgressBar: draggableProgressBar ?? this.draggableProgressBar,
        videoPlayerController:
            videoPlayerController ?? this.videoPlayerController,
        optionsTranslation: optionsTranslation ?? this.optionsTranslation,
        autoInitialize: autoInitialize ?? this.autoInitialize,
        autoPlay: autoPlay ?? this.autoPlay,
        startAt: startAt ?? this.startAt,
        looping: looping ?? this.looping,
        cupertinoProgressColors:
            cupertinoProgressColors ?? this.cupertinoProgressColors,
        materialProgressColors:
            materialProgressColors ?? this.materialProgressColors,
        showControlsOnInitialize:
            showControlsOnInitialize ?? this.showControlsOnInitialize,
        showOptions: showOptions ?? this.showOptions,
        optionsBuilder: optionsBuilder ?? this.optionsBuilder,
        additionalOptions: additionalOptions ?? this.additionalOptions,
        showControls: showControls ?? this.showControls,
        subtitle: subtitle ?? this.subtitle,
        subtitleBuilder: subtitleBuilder ?? this.subtitleBuilder,
        customControls: customControls ?? this.customControls,
        errorBuilder: errorBuilder ?? this.errorBuilder,
        isLive: isLive ?? this.isLive,
        allowMuting: allowMuting ?? this.allowMuting,
        allowPlaybackSpeedChanging:
            allowPlaybackSpeedChanging ?? this.allowPlaybackSpeedChanging,
        playbackSpeeds: playbackSpeeds ?? this.playbackSpeeds,
        progressIndicatorDelay:
            progressIndicatorDelay ?? this.progressIndicatorDelay,
        barBackGroundColor: barBackGroundColor ?? this.barBackGroundColor,
        barHeight: barHeight ?? this.barHeight,
        borderRadius: borderRadius ?? this.borderRadius,
        barBackGroundColorSpeedDialog:
            barBackGroundColorSpeedDialog ?? this.barBackGroundColorSpeedDialog,
        textColorSpeedDialog: textColorSpeedDialog ?? this.textColorSpeedDialog,
        dividerColorSpeedDialog:
            dividerColorSpeedDialog ?? this.dividerColorSpeedDialog,
        iconColor: iconColor ?? this.iconColor,
        playIconSize: playIconSize ?? this.playIconSize,
        pauseIconSize: pauseIconSize ?? this.pauseIconSize,
        skipForwardSize: skipForwardSize ?? this.skipForwardSize,
        skipBackwardSize: skipBackwardSize ?? this.skipBackwardSize,
        volumeIconSize: volumeIconSize ?? this.volumeIconSize,
        muteIconSize: muteIconSize ?? this.muteIconSize,
        ccIconSize: ccIconSize ?? this.ccIconSize,
        progressBarHeight: progressBarHeight ?? this.progressBarHeight,
        speedIconSize: speedIconSize ?? this.speedIconSize,
        indicatorSpeedDialog: indicatorSpeedDialog ?? this.indicatorSpeedDialog,
        seekTimeFontSize: seekTimeFontSize ?? this.seekTimeFontSize);
  }

  static const defaultHideControlsTimer = Duration(seconds: 3);

  /// If false, the options button in MaterialUI and MaterialDesktopUI
  /// won't be shown.
  final bool showOptions;

  /// Pass your translations for the options like:
  /// - PlaybackSpeed
  /// - Subtitles
  /// - Cancel
  ///
  /// Buttons
  ///
  /// These are required for the default `OptionItem`'s
  final OptionsTranslation? optionsTranslation;

  /// Build your own options with default chewieOptions shiped through
  /// the builder method. Just add your own options to the Widget
  /// you'll build. If you want to hide the chewieOptions, just leave them
  /// out from your Widget.
  final Future<void> Function(
    BuildContext context,
    List<OptionItem> chewieOptions,
  )? optionsBuilder;

  /// Add your own additional options on top of chewie options
  final List<OptionItem> Function(BuildContext context)? additionalOptions;

  /// Define here your own Widget on how your n'th subtitle will look like
  Widget Function(BuildContext context, dynamic subtitle)? subtitleBuilder;

  /// Add a List of Subtitles here in `Subtitles.subtitle`
  Subtitles? subtitle;

  final BorderRadiusGeometry? borderRadius;

  /// The controller for the video you want to play
  final VideoPlayerController videoPlayerController;

  /// Initialize the Audio on Startup. This will prep the audio for playback.
  final bool autoInitialize;

  final Color? iconColor;
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

  /// Play the audio as soon as it's initialized
  final bool autoPlay;

  /// Non-Draggable Progress Bar
  final bool draggableProgressBar;

  /// Start audio at a certain position
  final Duration? startAt;

  /// Whether or not the audio should loop
  final bool looping;

  /// Wether or not to show the controls when initializing the widget.
  final bool showControlsOnInitialize;

  /// Whether or not to show the controls at all
  final bool showControls;

  /// Controller to pass into the [InteractiveViewer] component
  final TransformationController? transformationController;

  /// Whether or not to allow zooming and panning
  final bool zoomAndPan;

  /// Max scale when zooming
  final double maxScale;

  /// Defines customised controls. Check [MaterialControls] or
  /// [CupertinoControls] for reference.
  final Widget? customControls;

  /// When the video playback runs into an error, you can build a custom
  /// error message.
  final Widget Function(BuildContext context, String errorMessage)?
      errorBuilder;

  /// The colors to use for controls on iOS. By default, the iOS player uses
  /// colors sampled from the original iOS 11 designs.
  final ChewieProgressColors? cupertinoProgressColors;

  /// The colors to use for the Material Progress Bar. By default, the Material
  /// player uses the colors from your Theme.
  final ChewieProgressColors? materialProgressColors;

  /// Defines if the controls should be for live stream audio
  final bool isLive;

  /// Defines if the mute control should be shown
  final bool allowMuting;

  /// Defines if the playback speed control should be shown
  final bool allowPlaybackSpeedChanging;

  /// Defines the set of allowed playback speeds user can change
  final List<double> playbackSpeeds;

  /// Defines a delay in milliseconds between entering buffering state and displaying the loading spinner. Set null (default) to disable it.
  final Duration? progressIndicatorDelay;

  /// Adds additional padding to the controls' [SafeArea] as desired.
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsets controlsSafeAreaMinimum;

  final Color? barBackGroundColor;
  final Color? barBackGroundColorSpeedDialog;
  final Color? textColorSpeedDialog;
  final Color? dividerColorSpeedDialog;

  final double? barHeight;

  static ChewieAudioController of(BuildContext context) {
    final chewieControllerProvider = context
        .dependOnInheritedWidgetOfExactType<ChewieAudioControllerProvider>()!;

    return chewieControllerProvider.controller;
  }

  bool get isPlaying => videoPlayerController.value.isPlaying;

  Future<dynamic> _initialize() async {
    await videoPlayerController.setLooping(looping);

    if ((autoInitialize || autoPlay) &&
        !videoPlayerController.value.isInitialized) {
      await videoPlayerController.initialize();
    }

    if (autoPlay) {
      await videoPlayerController.play();
    }

    if (startAt != null) {
      await videoPlayerController.seekTo(startAt!);
    }
  }

  void togglePause() {
    isPlaying ? pause() : play();
  }

  Future<void> play() async {
    await videoPlayerController.play();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setLooping(bool looping) async {
    await videoPlayerController.setLooping(looping);
  }

  Future<void> pause() async {
    await videoPlayerController.pause();
  }

  Future<void> seekTo(Duration moment) async {
    await videoPlayerController.seekTo(moment);
  }

  Future<void> setVolume(double volume) async {
    await videoPlayerController.setVolume(volume);
  }

  void setSubtitle(List<Subtitle> newSubtitle) {
    subtitle = Subtitles(newSubtitle);
  }
}

class ChewieAudioControllerProvider extends InheritedWidget {
  const ChewieAudioControllerProvider({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final ChewieAudioController controller;

  @override
  bool updateShouldNotify(ChewieAudioControllerProvider oldWidget) =>
      controller != oldWidget.controller;
}
