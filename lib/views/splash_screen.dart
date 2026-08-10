import 'package:thinkdiecast/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  late SplashController _splashController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _splashController = Get.put(SplashController());
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/splash-video.mp4');

      await _videoController.initialize();

      // Set video to loop and play
      _videoController.setLooping(true);
      _videoController.setVolume(0.0); // Mute the video
      _videoController.play();

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (error) {
      print('Video initialization error: $error');
      // If video fails, just show black screen instead of fallback
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetBuilder<SplashController>(
      init: _splashController,
      builder: (controller) {
        return Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black, // Background color while video loads
            child: _isVideoInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
                : const SizedBox(), // Empty widget if video not initialized
          ),
        );
      },
    );
  }
}


// class SplashScreen extends StatelessWidget {
//   SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//
//     return GetBuilder(
//       init: SplashController(),
//       builder: (controller) {
//         return Container(
//             height: MediaQuery.of(context).size.height,
//             decoration:  BoxDecoration(
//               color: Colors.black.withOpacity(0.4),
//                 image: DecorationImage(
//                     image: AssetImage('assets/splash-bg.png'),
//                 fit: BoxFit.fill)
//                 // gradient: LinearGradient(colors: [
//                 //   AppColors.primary3,
//                 //   AppColors.primary5,
//                 // ], begin: Alignment.topCenter),
//                 ),
//             child: Container(
//               color: Colors.black.withOpacity(0.4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/logo.png'),
//                   const SizedBox(height: 22,),
//                  const  DefaultTextStyle(
//                     style:  TextStyle(
//                         color: AppColors.bright,
//                         fontWeight: FontWeight.w400,
//                         fontSize: 13
//                     ),
//                     child:   Text('A COMPLETE INVENTORY SYSTEM' ),
//                   )
//                 ],
//               ),
//             )
//
//             // SvgPicture.asset(
//             //   'assets/svgs/logo.svgs',
//             // )
//             );
//       },
//     );
//   }
// }
