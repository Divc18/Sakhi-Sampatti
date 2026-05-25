import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_main_page.dart';
import 'onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OtpPage(),
    );
  }
}

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  int _seconds = 30;
  Timer? _timer;
  bool _canResend = false;

  String _message = "";

  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "OTP :",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Focus(
                  onKeyEvent: (node, event) {
                    // backspace to previous box
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _controllers[index].text.isEmpty &&
                        index > 0) {
                      _controllers[index - 1].clear();
                      FocusScope.of(context).previousFocus();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 1,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      // only keep one digit
                      if (value.length > 1) {
                        _controllers[index].text = value[0];
                        _controllers[index].selection =
                        const TextSelection.collapsed(offset: 1);
                      }
                      // move to next box automatically
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // Resend Code
          GestureDetector(
            onTap: _canResend ? _startTimer : null,
            child: Text(
              _canResend ? "Resend Code" : "Resend Code in $_seconds s",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _canResend ? Colors.blue : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Continue Button (navigates to next page)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingScreen(
                        userName: 'user',
                        onFinished: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainPage(userName: 'erica'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },


                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // OTP Status Message (not used anymore but kept as is)
          Text(
            _message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _message.contains("Incorrect") ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
