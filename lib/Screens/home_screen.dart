import 'package:flutter/material.dart';
import 'package:fomodoro/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController controller;

  int defaultMinutes = 2;
  int defaultSeconds = 0;
  bool isCounting = false;

  double progress = 1.0;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(minutes: defaultMinutes, seconds: defaultSeconds));
    controller.addListener(() {
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
        });
      }
    });
    Provider.of<ThemeProvider>(context, listen: false).initSharedPreferences();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String get countText {
    Duration count = controller.duration! * controller.value;
    return '${(count.inMinutes % 60 == 0 ? defaultMinutes : count.inMinutes % 60).toString().padLeft(2, '0')} : ${(count.inSeconds % 60 == 0 ? defaultSeconds : count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          color: Colors.white,
          child: Consumer<ThemeProvider>(
            builder: (context, theme, child) => IconButton(
              onPressed: () {
                ThemeProvider().readData('themeMode').then((value) {
                  value == 'light' ? theme.setDarkMode() : theme.setLightMode();
                });
              },
              icon: Icon(
                Icons.dark_mode,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: SizedBox(
                    width: size.width / 1.2,
                    height: size.height / 2,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade300,
                      //backgroundColor: Colors.red,
                      strokeWidth: 8,
                      value: progress,
                    )),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) => Text(
                  '$countText',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (controller.isAnimating) {
                      controller.stop();
                      setState(() {
                        isCounting = false;
                      });
                    } else {
                      controller.reverse(
                          from: controller.value == 0 ? 1.0 : controller.value);
                      setState(() {
                        isCounting = true;
                      });
                    }
                  },
                  child: Icon(
                      isCounting == true ? Icons.pause : Icons.play_arrow)),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    controller.reset();
                    setState(() {
                      isCounting = false;
                    });
                  },
                  child: Icon(Icons.stop)),
            ],
          ),
        )
      ],
    ));
  }
}
