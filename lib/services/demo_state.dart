import 'package:flutter/material.dart';

enum ReviewStatus { idle, pending, published }

class DemoState extends ChangeNotifier {
  static final DemoState _instance = DemoState._internal();
  factory DemoState() => _instance;
  DemoState._internal();

  String playerName = 'Arjun Kumar';
  String coachId = 'madhu';
  String activeCoachName = 'Coach Madhu';
  String activeCoachHandle = '@coach.madhu';

  int allowance = 3;
  ReviewStatus status = ReviewStatus.published;

  Map<String, String>? draft;
  Map<String, String>? published = {
    'strength': 'High elbow alignment on front foot drive with stable body posture.',
    'focus': 'Maintain brace leg firmness on release to avoid falling over to off-side.',
    'note': '• Focus on elbow extension: Keep leading elbow pointed high towards mid-off.\n• Head position: Ensure head stays over the line of the ball upon impact.',
    'drill': '6 Slow Shadow Drives with High Elbow Focus',
  };

  void publishFeedback({
    required String strength,
    required String focus,
    required String note,
    required String drill,
  }) {
    published = {
      'strength': strength,
      'focus': focus,
      'note': note,
      'drill': drill,
    };
    status = ReviewStatus.published;
    notifyListeners();
  }

  final List<Map<String, dynamic>> verifiedCoaches = [
    {
      'id': 'madhu',
      'name': 'Coach Madhu',
      'handle': '@coach.madhu',
      'role': 'Batting Biomechanics Expert',
      'rating': '★ 4.9 (184)',
      'status': 'ONLINE NOW',
      'statusColor': const Color(0xFF00E676),
      'experience': '12+ Yrs Coaching',
      'image': 'assets/coach.png',
      'spec': 'Batting & Power Hitting',
    },
    {
      'id': 'rahul',
      'name': 'Coach Rahul Menon',
      'handle': '@coach.rahul',
      'role': 'Pace Bowling Specialist',
      'rating': '★ 4.8 (142)',
      'status': 'AVAILABLE',
      'statusColor': const Color(0xFF3B82F6),
      'experience': '10+ Yrs Coaching',
      'image': 'assets/coach.png',
      'spec': 'Pace Bowling & Seam',
    },
    {
      'id': 'priya',
      'name': 'Coach Priya Sharma',
      'handle': '@coach.priya',
      'role': 'Spin & Technical Analyst',
      'rating': '★ 4.9 (96)',
      'status': 'AVAILABLE',
      'statusColor': const Color(0xFF3B82F6),
      'experience': '8+ Yrs Coaching',
      'image': 'assets/coach.png',
      'spec': 'Spin Bowling & Flight',
    },
  ];

  final List<Map<String, String>> assignedCustomDrills = [
    {
      'title': '6 Slow Shadow Drives',
      'reps': '3 Sets • 12 Reps',
      'coach': 'Coach Madhu',
    },
    {
      'title': 'Brace Leg Stability Hold',
      'reps': '4 Sets • 10 Reps',
      'coach': 'Coach Madhu',
    },
  ];

  final List<Map<String, dynamic>> allReviews = [
    {
      'coachName': 'Coach Madhu',
      'coachHandle': '@coach.madhu',
      'date': 'TODAY • 15 SEP 2023',
      'session': 'SESSION U15S125',
      'status': 'PUBLISHED',
      'focus': 'Maintain leading elbow elevation towards mid-off during drive completion.',
      'drill': '6 Slow Shadow Drives with High Elbow Focus',
    },
    {
      'coachName': 'Coach Rahul Menon',
      'coachHandle': '@coach.rahul',
      'date': '12 SEP 2023',
      'session': 'SESSION U15S121',
      'status': 'PUBLISHED',
      'focus': 'Keep front wrist firm on impact to control swing direction.',
      'drill': 'Cone Target In-Swing Drives',
    },
    {
      'coachName': 'Coach Priya Sharma',
      'coachHandle': '@coach.priya',
      'date': '10 SEP 2023',
      'session': 'SESSION U15S120',
      'status': 'PUBLISHED',
      'focus': 'Settle starting routine and balance trigger movement.',
      'drill': 'Stationary Tee Striking',
    },
  ];

  Future<void> load() async {
    notifyListeners();
  }

  Future<void> save() async {
    notifyListeners();
  }

  void submitReview(String notes, {required String targetCoach, required String targetCoachHandle}) {
    status = ReviewStatus.pending;
    activeCoachName = targetCoach;
    activeCoachHandle = targetCoachHandle;
    draft = {
      'strength': 'Session clip submitted to $targetCoach. Awaiting biomechanical analysis.',
      'focus': 'Pose telemetry data uploaded successfully. Awaiting coach notes.',
      'note': '• Session Video: Uploaded (HD Pose Stream)\n• Status: In queue with $targetCoach',
      'drill': 'Shadow Practice & Stance Hold',
    };
    notifyListeners();
  }

  void reset() {
    status = ReviewStatus.published;
    draft = null;
    notifyListeners();
  }
}
