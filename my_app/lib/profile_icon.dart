import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_main_page.dart';
import 'login_choice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'data_user.dart';
import 'shared_chat_page.dart';
import 'shg.dart';

/* ---------------- GLOBAL STATE ---------------- */

ValueNotifier<double> walletBalance = ValueNotifier(0.0);
ValueNotifier<List<String>> notifications = ValueNotifier<List<String>>([]);

class ProfilePage extends StatelessWidget {
  final String username;

  ProfilePage({super.key, required this.username});

  final String email = "ramesh@gmail.com";
  final String phone = "9876543210";

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainPage(userName: 'Ramesh',),
                ),
                    (route) => false,
              );
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.green,
                          child: Text(
                            username[0],
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CREDIT
                  ValueListenableBuilder<double>(
                    valueListenable: walletBalance,
                    builder: (_, balance, __) {
                      return ListTile(
                        leading:
                        const Icon(Icons.account_balance_wallet),
                        title: Text(
                          "Credit: ₹${balance.toStringAsFixed(2)}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalletPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("My Account"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyAccountPage(
                            username: username,
                            email: email,
                            phone: phone,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text("Chatbot"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatbotPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),


                  ListTile(
                    leading: const Icon(Icons.support_agent),
                    title: const Text("Mentor Support"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const MentorSupportPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text("Report"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportPage(userName: username),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.groups),
                    title: const Text("SHG Connect"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SHGApp(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionPage(),
                          ),
                              (route) => false,
                        );
                      },

                    ),
                  ),
                ],
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const NotificationsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* ---------------- WALLET ---------------- */

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String amount = "0";

  void add(String v) {
    setState(() {
      amount = amount == "0" ? v : amount + v;
    });
  }

  void backspace() {
    setState(() {
      amount = amount.length > 1
          ? amount.substring(0, amount.length - 1)
          : "0";
    });
  }

  void quickAdd(int v) {
    setState(() {
      amount = v.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Add money",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "₹ $amount",
            style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              quick("+ ₹1,000", 1000),
              quick("+ ₹5,000", 5000),
              quick("+ ₹10,000", 10000),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Column(
              children: [
                dialRow(["1", "2", "3"]),
                dialRow(["4", "5", "6"]),
                dialRow(["7", "8", "9"]),
                dialRow([".", "0", "⌫"]),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: amount == "0"
                    ? null
                    : () {
                  final v = double.parse(amount);
                  walletBalance.value += v;
                  notifications.value = [
                    "You added ₹$v to your wallet",
                    ...notifications.value
                  ];
                  Navigator.pop(context);
                },
                child: const Text(
                  "Add money",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quick(String t, int v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: OutlinedButton(
        onPressed: () => quickAdd(v),
        child: Text(t),
      ),
    );
  }

  Widget dialRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) {
          return Expanded(
            child: GestureDetector(
              onTap: () => k == "⌫" ? backspace() : add(k),
              child: Center(
                child: k == "⌫"
                    ? const Icon(Icons.backspace_outlined)
                    : Text(
                  k,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* ---------------- NOTIFICATIONS ---------------- */

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: notifications,
        builder: (_, list, __) {
          if (list.isEmpty) {
            return const Center(child: Text("No notifications"));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Text(list[i]),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- PLACEHOLDER PAGES ---------------- */
class MyAccountPage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;

  const MyAccountPage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
  });

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late TextEditingController usernameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;

  bool editUsername = false;
  bool editEmail = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    usernameCtrl = TextEditingController(text: widget.username);
    emailCtrl = TextEditingController(text: widget.email);
    phoneCtrl = TextEditingController(text: widget.phone);
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void showDeleteDialog() {
    final deleteCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(32), // outer padding (all sides)
          child: Center(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: StatefulBuilder(
                  builder: (context, setLocalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// TOP ROW WITH TITLE + CLOSE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            const Text(
                              "Delete Account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "If you are sure that you want to delete this account,\nplease type DELETE below.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: deleteCtrl,
                          textAlign: TextAlign.center,
                          onChanged: (_) => setLocalState(() {}),
                          decoration: InputDecoration(
                            hintText: "DELETE",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: deleteCtrl.text == "DELETE"
                                ? () {
                              // delete logic later
                              Navigator.pop(context);
                            }
                                : null,
                            child: const Text("OK"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget accountRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onEdit,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26),
          title: TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() => hasChanges = true),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            accountRow(
              icon: Icons.person,
              label: "Username",
              controller: usernameCtrl,
              enabled: editUsername,
              onEdit: () => setState(() => editUsername = true),
            ),

            accountRow(
              icon: Icons.phone,
              label: "Phone Number",
              controller: phoneCtrl,
              enabled: false,
              onEdit: () {},
            ),

            accountRow(
              icon: Icons.email,
              label: "Email",
              controller: emailCtrl,
              enabled: editEmail,
              onEdit: () => setState(() => editEmail = true),
            ),

            ListTile(
              leading: const Icon(Icons.lock, size: 26),
              title: const Text(
                "Change Password",
                style: TextStyle(fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
            const Divider(thickness: 1),

            /// DELETE ACCOUNT
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  size: 26, color: Colors.red),
              title: const Text(
                "Delete this account",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              onTap: showDeleteDialog,
            ),
            const Divider(thickness: 1),

            if (hasChanges)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isValidEmail(emailCtrl.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid email"),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        editUsername = false;
                        editEmail = false;
                        hasChanges = false;
                      });
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update your password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// CURRENT PASSWORD
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: "Current Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// NEW PASSWORD
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // logic can be added later
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _voiceMode = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  void _initTTS() async {
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  String detectLanguage(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text) ? "hi" : "en";
  }

  Future<void> _speak(String text, String lang) async {
    await _tts.stop();
    await _tts.setLanguage(lang == "hi" ? "hi-IN" : "en-US");
    await _tts.speak(text);
  }

  // ================= API CALL =================
  Future<String> getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/chat/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
          "user_id": "user1"
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No response";
      } else {
        return "Server error ${response.statusCode}";
      }
    } catch (e) {
      print("ERROR: $e");
      return "⚠️ Unable to connect to server.\nMake sure Django is running.";
    }
  }

  // ================= TEXT =================
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
    });

    _controller.clear();

    String reply = await getAIResponse(text);

    if (!mounted) return;

    setState(() {
      _messages.add({"text": reply, "isUser": false});
    });
  }

  // ================= VOICE =================
  Future<void> _startVoiceMode() async {
    setState(() => _voiceMode = true);

    await _speak("Hi, I am your Sakhi AI, how may I help you?", "en");
    await Future.delayed(const Duration(milliseconds: 500));

    _listen();
  }

  Future<void> _listen() async {
    if (_isListening) return; // ✅ prevent duplicate calls

    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");

        if ((status == "done" || status == "notListening") &&
            _voiceMode &&
            !_isProcessing) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _isListening = false;
            _listen();
          });
        }
      },
      onError: (error) {
        print("Speech error: $error");

        if (_voiceMode) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _isListening = false;
            _listen();
          });
        }
      },
    );

    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      localeId: "en_IN",
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 10),
      onResult: (result) {
        if (!_isProcessing && result.finalResult) {
          final text = result.recognizedWords.trim();

          if (text.isEmpty) {
            _isProcessing = false;
            return;
          }

          _isProcessing = true;
          _handleVoiceInput(text);
        }
      },
    );
  }

  Future<void> _handleVoiceInput(String text) async {
    _speech.stop();
    setState(() => _isListening = false);

    setState(() {
      _messages.add({"text": text, "isUser": true});
    });

    String reply = await getAIResponse(text);

    if (!mounted) return;

    setState(() {
      _messages.add({"text": reply, "isUser": false});
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _speak(reply, detectLanguage(text));

    _isProcessing = false;
    // ❌ removed extra _listen() (handled automatically)
  }

  void _stopVoiceMode() {
    _speech.stop();
    _tts.stop();

    setState(() {
      _voiceMode = false;
      _isListening = false;
    });
  }

  // ================= UI =================
  Widget _chatBubble(String text, bool isUser) {
    return Align(
      alignment:
      isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_voiceMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isListening ? 120 : 90,
                height: _isListening ? 120 : 90,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic,
                    size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                _isListening ? "Listening..." : "Tap mic",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _stopVoiceMode,
                child: const Text("Stop"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sakhi AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _chatBubble(msg["text"], msg["isUser"]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: _startVoiceMode,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () =>
                      _sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MentorAssignment {
  final String mentorName;
  final String meetingDay;
  final String meetingTime;

  MentorAssignment({
    required this.mentorName,
    required this.meetingDay,
    required this.meetingTime,
  });
}

class MentorSupportPage extends StatefulWidget {
  const MentorSupportPage({Key? key}) : super(key: key);

  @override
  State<MentorSupportPage> createState() => _MentorSupportPageState();
}

class _MentorSupportPageState extends State<MentorSupportPage> {
  String? selectedCategory;

  final TextEditingController otherBusinessController =
  TextEditingController();

  final TextEditingController enquiryController = TextEditingController();

  int userCounter = 0;

  final List<MentorAssignment> mentors = [
    MentorAssignment(
      mentorName: "Rameshwar",
      meetingDay: "Sep 13",
      meetingTime: "4:00 PM",
    ),
    MentorAssignment(
      mentorName: "Sarthak",
      meetingDay: "Sep 14",
      meetingTime: "2:00 PM",
    ),
    MentorAssignment(
      mentorName: "Mahesh",
      meetingDay: "Friday",
      meetingTime: "3:30 PM",
    ),
  ];

  List<MentorAssignment> history = [];
  List<MentorAssignment> activeCalls = [];

  Map<String, List<String>> chatHistory = {};

  @override
  void dispose() {
    otherBusinessController.dispose();
    enquiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Mentor Support",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Select Your Profession"),
            const SizedBox(height: 12),

            _premiumDropdown(),

            if (selectedCategory == "Other") ...[
              const SizedBox(height: 20),
              _sectionTitle("Which Business?"),
              const SizedBox(height: 10),
              _premiumTextField(
                controller: otherBusinessController,
                hint: "Enter your business type",
              ),
            ],

            const SizedBox(height: 30),

            _sectionTitle("Additional Enquiry (Optional)"),
            const SizedBox(height: 10),

            _premiumTextArea(),

            const SizedBox(height: 40),

            _sendRequestButton(),

            const SizedBox(height: 30),

            if (activeCalls.isNotEmpty) ...[
              const Text(
                "Your Calls",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeCalls.length,
                  itemBuilder: (context, index) {
                    return _callCard(activeCalls[index]);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            if (history.isNotEmpty) ...[
              const Text(
                "History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _historyCard(history[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _premiumDropdown() {
    return Container(
      decoration: _premiumBoxDecoration(),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        hint: const Text("Choose category"),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: const [
          DropdownMenuItem(
            value: "Agriculture",
            child: Text("Agriculture"),
          ),
          DropdownMenuItem(
            value: "Dairy",
            child: Text("Dairy"),
          ),
          DropdownMenuItem(
            value: "Other",
            child: Text("Other"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        },
      ),
    );
  }

  Widget _premiumTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: _premiumBoxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _premiumTextArea() {
    return Container(
      height: 150,
      decoration: _premiumBoxDecoration(),
      child: TextField(
        controller: enquiryController,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          hintText: "Write your query...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _sendRequestButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _showSuccessDialog,
        child: const Text("Send Request"),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Request Sent"),
          content: const Text("You will be notified within 15 minutes"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _assignMentor();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _assignMentor() async {
    await Future.delayed(const Duration(seconds: 5));

    final mentor = mentors[userCounter % mentors.length];

    userCounter++;

    if (!mounted) return;

    setState(() {
      activeCalls.add(mentor);
    });

    _showMentorAssignedDialog(mentor);
  }

  void _showMentorAssignedDialog(MentorAssignment mentor) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Mentor Assigned"),
          content: Text(
            "${mentor.mentorName}\n${mentor.meetingDay}\n${mentor.meetingTime}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _callCard(MentorAssignment mentor) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: _premiumBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mentor.mentorName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(mentor.meetingDay),
          Text(mentor.meetingTime),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _openChat(mentor);
            },
            child: const Text("Join"),
          )
        ],
      ),
    );
  }

  Widget _historyCard(MentorAssignment mentor) {
    return GestureDetector(
      onTap: () => _openChat(mentor),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: _premiumBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mentor.mentorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(mentor.meetingDay),
            Text(mentor.meetingTime),
          ],
        ),
      ),
    );
  }

  void _openChat(MentorAssignment mentor) {
    final session = SessionBridge.createSession(
      userName: 'Ramesh',
      mentorName: mentor.mentorName,
      date: mentor.meetingDay,
      time: mentor.meetingTime,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SharedChatPage(
          sessionId: session.sessionId,
          displayName: mentor.mentorName,
          isUser: true,
        ),
      ),
    );
  }

  BoxDecoration _premiumBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class ChatPage extends StatefulWidget {
  final MentorAssignment mentor;
  final Map<String, List<String>> chatHistory;
  final VoidCallback onEndCall;

  const ChatPage({
    Key? key,
    required this.mentor,
    required this.chatHistory,
    required this.onEndCall,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.mentor.mentorName;
    widget.chatHistory.putIfAbsent(key, () => []);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mentor.mentorName),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () {
              widget.onEndCall();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: widget.chatHistory[key]!
                  .map(
                    (msg) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg,
                    softWrap: true,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    setState(() {
                      widget.chatHistory[key]!.add(controller.text.trim());
                      controller.clear();
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportPage extends StatefulWidget {
  final String userName;

  const ReportPage({super.key, required this.userName});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _reportCtrl = TextEditingController();

  @override
  void dispose() {
    _reportCtrl.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_reportCtrl.text.trim().isEmpty) return;

    _reportCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Report Registered",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your complaint has been submitted successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Report an Issue"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reported by: ${widget.userName}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _reportCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Describe your issue in detail...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Submit Report",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
