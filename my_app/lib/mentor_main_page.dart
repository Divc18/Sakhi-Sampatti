import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'shared_chat_page.dart';
import 'data_user.dart';
import 'login_choice.dart';

class MentorController {
  static bool mentorActive = true;
  static DateTime lastActive = DateTime.now();

  static List<Map<String, String>> chatHistory = [];
  static List<double> ratings = [];

  static DateTime? chatStart;

  static void startChat() {
    chatStart = DateTime.now();
  }

  static void endChat() {
    if (chatStart == null) return;

    final end = DateTime.now();
    lastActive = end;
    chatStart = null;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),

      // ✅ START FROM ROLE SELECTION
      home: RoleSelectionPage(),
    );
  }
}

class MentorAppEnhanced extends StatefulWidget {
  const MentorAppEnhanced({Key? key}) : super(key: key);

  @override
  State<MentorAppEnhanced> createState() => _MentorAppEnhancedState();
}

class _MentorAppEnhancedState extends State<MentorAppEnhanced> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakhi Sampatti - Mentor (Enhanced)',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      )
          : ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MentorDashboardEnhanced(onToggleTheme: _toggleTheme),
    );
  }
}

class MentorDashboardEnhanced extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MentorDashboardEnhanced({Key? key, required this.onToggleTheme})
      : super(key: key);

  @override
  State<MentorDashboardEnhanced> createState() =>
      _MentorDashboardEnhancedState();
}

class _MentorDashboardEnhancedState extends State<MentorDashboardEnhanced> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const SessionsEnhancedPage(),
    const ProfileEnhancedPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Animated floating action to contact support

  Widget _floatingAction() {
    return Stack(
      children: [
        FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(user: "Mentor"),
              ),
            );
          },
          label: const Text('Support'),
          icon: const Icon(Icons.headset_mic),
          backgroundColor: Colors.deepPurple,
        ),

        // 🟢🔴 STATUS DOT
        Positioned(
          right: 0,
          top: 0,
          child: CircleAvatar(
            radius: 6,
            backgroundColor: MentorController.mentorActive
                ? Colors.green
                : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sakhi Sampatti"), // Title as requested
        actions: [
          IconButton(
            tooltip: 'Dark/Light Mode',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6),
          ),


        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _floatingAction(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

/* ---------------------- SESSIONS (Enhanced) ---------------------- */

class SessionsEnhancedPage extends StatefulWidget {
  const SessionsEnhancedPage({Key? key}) : super(key: key);

  @override
  State<SessionsEnhancedPage> createState() => _SessionsEnhancedPageState();
}

class _SessionsEnhancedPageState extends State<SessionsEnhancedPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final List<Map<String, String>> history = [
    {"user": "Anita", "field": "Handicrafts", "date": "Sep 10, 5:00 PM"},
    {"user": "Sunita", "field": "Dairy", "date": "Sep 8, 11:00 AM"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: MentorController.mentorActive
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(
                MentorController.mentorActive
                    ? "Active"
                    : "Last seen ${DateTime.now().difference(MentorController.lastActive).inMinutes} min ago",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(text: "Scheduled 1:1"),
            Tab(text: "History"),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [

              /// Scheduled 1:1
              ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  ScheduledCard(
                    date: 'Sep 13, 4:00 PM',
                    user: 'Ramesh',
                    mentorName: 'Rameshwar',
                    field: 'Agriculture',

                  ),

                  ScheduledCard(
                    date: 'Sep 14, 2:00 PM',
                    user: 'Suresh',
                    mentorName: 'sarthak',
                    field: 'Dairy',

                  ),

                ],
              ),

              /// History
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final h = history[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.history,
                        color: Colors.deepPurple,
                      ),
                      title: Text('${h['user']} (${h['field']})'),
                      subtitle: Text('Completed on ${h['date']}'),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ],
    );
  }
}
/* ---------------------- SessionRequestCard ---------------------- */

class SessionRequestCard extends StatelessWidget {
  final String user;
  final String time;
  final String field;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const SessionRequestCard({
    Key? key,
    required this.user,
    required this.time,
    required this.field,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Text(
                    user[0],
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$field • $time',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Short description: Needs help improving farmer yields with low-cost feed & storage tips.',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- ScheduledCard ---------------------- */
class ScheduledCard extends StatelessWidget {
  final String date;
  final String user;
  final String mentorName;
  final String field;
  final VoidCallback? onJoin;

  const ScheduledCard({
    Key? key,
    required this.date,
    required this.user,
    required this.mentorName,
    required this.field,
    this.onJoin,
  }) : super(key: key);

  void _onMentorJoin(BuildContext context) {
    if (onJoin != null) {
      onJoin!();
      return;
    }

    final parts = date.split(',');
    final sessionDate = parts.isNotEmpty ? parts[0].trim() : date;
    final sessionTime = parts.length > 1 ? parts[1].trim() : '';

    final session =
    SessionBridge.getSession(mentorName, sessionDate, sessionTime);

    if (session != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SharedChatPage(
            sessionId: session.sessionId,
            displayName: user,
            isUser: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for user to join the session...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(date),
        subtitle: Text('User: $user\nField: $field'),
        trailing: ElevatedButton(
          onPressed: () => _onMentorJoin(context),
          child: const Text('Join'),
        ),
      ),
    );
  }
}

/* ---------------------- PROFILE (Enhanced) ---------------------- */

class ProfileEnhancedPage extends StatefulWidget {
  const ProfileEnhancedPage({Key? key}) : super(key: key);

  @override
  State<ProfileEnhancedPage> createState() => _ProfileEnhancedPageState();
}

class _ProfileEnhancedPageState extends State<ProfileEnhancedPage> {
  String _status = "Available";

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        t,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {



    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with verification badge (circle top-right)
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF512DA8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // small plus icon on avatar (preserved from original)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.add,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rameshwar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mentor • Agriculture & Dairy',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // verification badge circle top-right (explicit)
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ID and contact row (kept from original)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ID: MTR-100412',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'rameshwar@sakhisampatti.com',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // My Stats & Working hours tracker
          _sectionTitle('My Stats & Availability'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.access_time, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Working Hours This Week',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Logged: 18.5 / 30 hrs',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: 18.5 / 30, minHeight: 8),
                  const SizedBox(height: 10),
                  // small weekly bar chart (approx)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      // dummy data
                      final values = [2.5, 3.0, 3.5, 2.0, 4.0, 2.0, 1.5];
                      double v = values[i];
                      return Column(
                        children: [
                          Text(
                            '${v.toStringAsFixed(1)}h',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 18,
                            height: v * 10,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Mentor Details, Feedback, Problems Solved
          _sectionTitle('Profile Sections'),


          _settingsTile(
            icon: Icons.account_box,
            title: 'My Account',
            subtitle: 'Personal details, payout, documents',
          ),

          _settingsTile(
            icon: Icons.star_border,
            title: 'Feedback & Ratings',
            subtitle: '4.8 (based on 124 ratings)',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const RatingsDialog(),
              );
            },
          ),
          _settingsTile(
            icon: Icons.lightbulb_outline,
            title: 'Problems Solved',
            subtitle: 'Summary of mentees helped & business outcomes',
          ),



          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoleSelectionPage(

                    ),
                  ),
                      (route) => false,
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}

/* ---------------------- RATINGS DIALOG ---------------------- */

class RatingsDialog extends StatefulWidget {
  const RatingsDialog({Key? key}) : super(key: key);

  @override
  State<RatingsDialog> createState() => _RatingsDialogState();
}

class _RatingsDialogState extends State<RatingsDialog> {
  double _rating = 4.8;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Feedback & Ratings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Average Rating: ${_rating.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating.round();
              return Icon(
                filled ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Recent feedback:'),
          const SizedBox(height: 6),
          const Text(
            '“Super helpful and practical — improved our yields!” — A. Kumar',
          ),
          const SizedBox(height: 6),
          const Text('“Quick and patient mentor.” — S. Verma'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/* ---------------------- CHAT PAGE (Enhanced) ---------------------- */

class ChatPage extends StatefulWidget {
  final String user;

  const ChatPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<_Message> _messages = [
    _Message(
      text: "Welcome to Mentor Support. How can we help you today?",
      fromUser: false,
      time: "Now",
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();

    MentorController.startChat();
    MentorController.mentorActive = true;

    _speech = stt.SpeechToText();
  }

  /* ---------------- Voice ---------------- */

  void _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: "en_IN",
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  /* ---------------- Send Message ---------------- */

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentTime = _timeNow();

    setState(() {
      _messages.add(
        _Message(
          text: text,
          fromUser: true,
          time: currentTime,
        ),
      );
    });

    _controller.clear();

    _autoScroll();

    Future.delayed(const Duration(milliseconds: 500), () {
      String userText = text.toLowerCase();
      String reply = "";

      // HELLO
      if (userText.contains("hello") || userText.contains("hi")) {
        reply =
        "Hi, I'm here to help you. You can ask me about salary, increments, payments, working hours and policies.";
      }

      // SALARY
      else if (userText.contains("salary")) {
        reply =
        "Mentor salary is performance-based. You will earn based on completed sessions, ratings and mentoring hours. Payments are processed monthly.";
      }

      // INCREMENT
      else if (userText.contains("increment") ||
          userText.contains("raise") ||
          userText.contains("growth")) {
        reply =
        "Mentor increments are reviewed every 3 months based on:\n\n• Session completion\n• Ratings\n• Active hours\n• Feedback";
      }

      // PAYMENT
      else if (userText.contains("payment") ||
          userText.contains("paid") ||
          userText.contains("when")) {
        reply =
        "Payments are processed between 5th-10th of every month directly to your registered bank account.";
      }

      // REMOTE
      else if (userText.contains("remote")) {
        reply =
        "Yes, mentors work remotely. You can conduct sessions from anywhere using chat or video.";
      }

      // WORKING HOURS
      else if (userText.contains("working hours") ||
          userText.contains("timing")) {
        reply =
        "Mentors can choose flexible working hours. Minimum 15 hours per week is recommended.";
      }

      // LEAVE
      else if (userText.contains("leave") ||
          userText.contains("holiday")) {
        reply =
        "Mentors can take flexible leave. Just update availability in advance.";
      }

      // SUPPORT
      else if (userText.contains("support") ||
          userText.contains("help")) {
        reply =
        "Company support is available 24/7 for mentors. We're always here to help.";
      }

      // DEFAULT
      else {
        reply =
        "I'm here to assist you. Ask about salary, increments, payments, working hours or policies.";
      }

      setState(() {
        _messages.add(
          _Message(
            text: reply,
            fromUser: false,
            time: _timeNow(),
          ),
        );
      });

      _autoScroll();
    });
  }

  /* ---------------- Auto Scroll ---------------- */

  void _autoScroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /* ---------------- Time ---------------- */

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ap = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  @override
  void dispose() {
    MentorController.endChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => FeedbackDialog(),
      );
    });

    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /* ---------------- Chat Bubble ---------------- */

  Widget _buildBubble(_Message m) {
    final alignment =
    m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final bg = m.fromUser
        ? Colors.deepPurple[100]
        : Colors.grey[200];

    final radius = m.fromUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.text),
                const SizedBox(height: 4),
                Text(
                  m.time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company Support"),
            Text(
              "Mentor Help Desk",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildBubble(_messages[index]),
            ),
          ),

          /* ---------------- Input ---------------- */

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isListening
                          ? Icons.mic
                          : Icons.mic_none,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask company...",
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/* ---------------------- Message Model ---------------------- */

class _Message {
  final String text;
  final bool fromUser;
  final String time;
  _Message({required this.text, required this.fromUser, required this.time});
}

class FeedbackDialog extends StatefulWidget {
  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  double rating = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("How did we do?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: rating.toString(),
            onChanged: (value) {
              setState(() => rating = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            MentorController.ratings.add(rating);
            Navigator.pop(context);
          },
          child: Text("Submit"),
        )
      ],
    );
  }
}





/// ================= Mentor CREDENTIALS =================
const String mentorId = "Mentor123";
const String mentorPassword = "Rameshwar@123";
const String mentorMobile = "+919876543210";
const String mentorEmail = "rameshwar@sakhisampatti.com";


class MentorLoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MentorLoginPage({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<MentorLoginPage> createState() => _MentorLoginPageState();
}

class _MentorLoginPageState extends State<MentorLoginPage> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  String? error;
  bool isLoading = false;
  bool _obscurePassword = true;

  bool _isPasswordValid(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    return password.length >= 12 && hasUpper && hasSpecial && hasNumber;
  }

  void _login() async {
    setState(() {
      error = null;
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (userIdController.text
        .trim()
        .isEmpty) {
      setState(() {
        error = "User ID is required";
        isLoading = false;
      });
      return;
    }


    if (userIdController.text != mentorId ||
        passwordController.text != mentorPassword) {
      setState(() {
        error = "Invalid User ID or Password";
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = false);

    // Navigate to Mentor Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MentorAppEnhanced(),
      ),
    );
  }
  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("A password reset link has been sent to:"),
            const SizedBox(height: 8),
            Text(mentorMobile,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            const Text("Also sent to registered email:",
                style: TextStyle(fontSize: 12)),
            Text(mentorEmail,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Mentor Login",
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: "Mentor User ID",
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() =>
                        _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text("Forgot Password?"),
                  ),
                ),

                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(error!,
                        style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 16),

                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: const Text("LOGIN"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
