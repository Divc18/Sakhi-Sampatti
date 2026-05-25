import 'dart:async';

class ChatSession {
  final String sessionId;   // unique key: mentorName + date + time
  final String userName;
  final String mentorName;
  final String date;
  final String time;

  ChatSession({
    required this.sessionId,
    required this.userName,
    required this.mentorName,
    required this.date,
    required this.time,
  });
}

class SessionBridge {
  // Active sessions: sessionId → list of message strings
  static final Map<String, List<String>> messages = {};

  // Stream that fires whenever a new session is created
  static final StreamController<ChatSession> _sessionController =
  StreamController<ChatSession>.broadcast();

  static Stream<ChatSession> get sessionStream => _sessionController.stream;

  /// Called by the USER when they tap Join on a mentor card
  static ChatSession createSession({
    required String userName,
    required String mentorName,
    required String date,
    required String time,
  }) {
    final id = '${mentorName}_${date}_$time'.replaceAll(' ', '_');
    messages.putIfAbsent(id, () => []);

    final session = ChatSession(
      sessionId: id,
      userName: userName,
      mentorName: mentorName,
      date: date,
      time: time,
    );

    _sessionController.add(session); // notifies mentor page
    return session;
  }

  /// Called by the MENTOR when they tap Join — checks for an active session
  static ChatSession? getSession(String mentorName, String date, String time) {
    final id = '${mentorName}_${date}_$time'.replaceAll(' ', '_');
    if (messages.containsKey(id)) {
      return ChatSession(
        sessionId: id,
        userName: '',       // mentor side doesn't need userName
        mentorName: mentorName,
        date: date,
        time: time,
      );
    }
    return null;            // session not started by user yet
  }

  static void addMessage(String sessionId, String msg) {
    messages[sessionId]?.add(msg);
  }

  static List<String> getMessages(String sessionId) {
    return messages[sessionId] ?? [];
  }

  static void clearSession(String sessionId) {
    messages.remove(sessionId);
  }
}
