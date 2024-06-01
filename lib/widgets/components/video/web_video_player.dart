// import 'dart:async';
// import 'dart:html';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class WebVideoPlayer extends StatefulWidget {
//   final String url;
//   const WebVideoPlayer(this.url, {super.key});

//   @override
//   State<WebVideoPlayer> createState() => _WebVideoPlayerState();
// }

// class _WebVideoPlayerState extends State<WebVideoPlayer> {
//   bool showVideoControl = false, isFullScreen = false;
//   late VideoPlayerController _controller;
//   Timer? _timer;
//   late double videoPlayerSize;
//   final Duration _duration = const Duration(milliseconds: 550); // Set the duration for pointer stop

//   // Create a stream controller
//   final StreamController<MouseEvent> controller = StreamController<MouseEvent>();

//   // Create a stream subscription
//   StreamSubscription<MouseEvent>? subscription;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(
//       Uri.parse(widget.url),
//       // closedCaptionFile: _loadCaptions(),
//       videoPlayerOptions: VideoPlayerOptions(
//         mixWithOthers: true,
//       ),
//     );

//     _controller.addListener(() {
//       setState(() {});
//     });
//     _controller.setLooping(true);
//     _controller.initialize();

//     _timer = Timer.periodic(_duration, (Timer timer) {});
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     videoPlayerSize = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(),
//       body: SizedBox(
//         width: videoPlayerSize,
//         child: AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           // prevent right click on video player only
//           child: MouseRegion(
//             onEnter: (event) => subscription = document.onContextMenu.listen(
//               (MouseEvent data) {
//                 data.preventDefault();
//               },
//             ),
//             onExit: (event) => subscription?.cancel(),
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: <Widget>[
//                 Listener(
//                   onPointerHover: (event) {
//                     showVideoControl = true;
//                     setState(() {});
//                     _timer?.cancel();
//                     _timer = Timer(_duration, () {
//                       showVideoControl = false;
//                       setState(() {});
//                     });
//                   },
//                   child: GestureDetector(
//                     onSecondaryTapDown: (_) async {
//                       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//                     },
//                     onDoubleTap: isFullScreen
//                         ? () => setState(() {
//                               document.documentElement?.requestFullscreen();
//                               isFullScreen = false;
//                             })
//                         : () => setState(() {
//                               document.exitFullscreen();
//                               isFullScreen = true;
//                             }),
//                     child: VideoPlayer(
//                       _controller,
//                     ),
//                   ),
//                 ),
//                 ClosedCaption(
//                   text: _controller.value.caption.text,
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   child: AnimatedOpacity(
//                     opacity: showVideoControl ? 1 : 0,
//                     curve: Curves.decelerate,
//                     duration: const Duration(
//                       milliseconds: 180,
//                     ),
//                     child: MouseRegion(
//                       onEnter: (event) => setState(() {
//                         _timer?.cancel();
//                         showVideoControl = true;
//                       }),
//                       child: _ControlsOverlay(
//                         videoPlayerSize: videoPlayerSize,
//                         controller: _controller,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ControlsOverlay extends StatelessWidget {
//   final double videoPlayerSize;
//   const _ControlsOverlay({required this.videoPlayerSize, required this.controller});

//   final VideoPlayerController controller;

//   @override
//   Widget build(BuildContext context) {
//     final double controlsOverlaySize = videoPlayerSize * 0.45;

//     return Container(
//       constraints: const BoxConstraints(maxWidth: 420),
//       width: controlsOverlaySize,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: const Color.fromARGB(217, 239, 239, 239),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: controlsOverlaySize,
//               height: 40,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: IconButton(
//                         onPressed: () => controller.value.isPlaying ? controller.pause() : controller.play(),
//                         alignment: Alignment.center,
//                         iconSize: 42,
//                         padding: EdgeInsets.zero,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         splashColor: Colors.transparent,
//                         icon: Icon(
//                           controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Positioned(
//                     top: 13,
//                     left: 0,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(right: 10),
//                           child: Icon(
//                             Icons.volume_up,
//                             size: 20,
//                           ),
//                         ),
//                         SizedBox(
//                           width: 55,
//                           child: VolumeSlider(),
//                         )
//                       ],
//                     ),
//                   ),
//                   const Positioned(
//                     top: 13,
//                     right: 0,
//                     child: Icon(
//                       Icons.playlist_play_rounded,
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10, right: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     durationToStringWithoutMilliseconds(controller.value.position),
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
//                       child: VideoProgressIndicator(
//                         controller,
//                         allowScrubbing: true,
//                         colors: const VideoProgressColors(
//                           backgroundColor: Color.fromARGB(174, 158, 158, 158),
//                           playedColor: Color.fromARGB(176, 76, 78, 81),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Text(
//                     durationToStringWithoutMilliseconds(controller.value.duration),
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// String durationToStringWithoutMilliseconds(Duration duration) {
//   String twoDigits(int n) => n.toString().padLeft(2, '0');

//   String hours = twoDigits(duration.inHours);
//   String minutes = twoDigits(duration.inMinutes.remainder(60));
//   String seconds = twoDigits(duration.inSeconds.remainder(60));

//   return '$hours:$minutes:$seconds';
// }

// class VolumeSlider extends StatefulWidget {
//   const VolumeSlider({super.key});

//   @override
//   State<VolumeSlider> createState() => _VolumeSliderState();
// }

// class _VolumeSliderState extends State<VolumeSlider> {
//   double _volume = 1.0;
//   @override
//   Widget build(BuildContext context) {
//     return SliderTheme(
//       data: SliderThemeData(
//         overlayShape: SliderComponentShape.noOverlay,
//         thumbShape: SliderComponentShape.noThumb,
//       ),
//       child: Slider(
//         value: _volume,
//         onChanged: (value) => setState(() {
//           _volume = value;
//         }),
//         activeColor: Colors.blueAccent,
//         inactiveColor: const Color.fromARGB(229, 199, 198, 198),
//       ),
//     );
//   }
// }
