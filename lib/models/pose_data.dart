class Keypoint {
  final double x;
  final double y;
  final double z;
  final double score;

  const Keypoint({
    required this.x,
    required this.y,
    required this.z,
    required this.score,
  });

  factory Keypoint.fromJson(dynamic value) {
    if (value is List && value.length >= 4) {
      return Keypoint(
        x: (value[0] as num).toDouble(),
        y: (value[1] as num).toDouble(),
        z: (value[2] as num).toDouble(),
        score: (value[3] as num).toDouble(),
      );
    }
    if (value is Map<String, dynamic>) {
      return Keypoint(
        x: (value['x'] as num).toDouble(),
        y: (value['y'] as num).toDouble(),
        z: (value['z'] as num?)?.toDouble() ?? 0,
        score: (value['score'] as num?)?.toDouble() ?? 1,
      );
    }
    throw const FormatException('Invalid pose keypoint; expected [x, y, z, score].');
  }
}

class PoseFrame {
  final double t;
  final Map<String, Keypoint> kp;
  final Map<String, double> angles;

  const PoseFrame({required this.t, this.kp = const {}, this.angles = const {}});

  factory PoseFrame.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['kp'];
    final rawAngles = json['angles'];
    return PoseFrame(
      t: (json['t'] as num).toDouble(),
      kp: rawPoints is Map
          ? rawPoints.map((name, value) => MapEntry(
                name.toString(),
                Keypoint.fromJson(value),
              ))
          : const {},
      angles: rawAngles is Map
          ? rawAngles.map((name, value) =>
              MapEntry(name.toString(), (value as num).toDouble()))
          : const {},
    );
  }
}

class PoseData {
  final String? clip;
  final double fps;
  final List<PoseFrame> frames;

  const PoseData({this.clip, this.fps = 0, this.frames = const []});

  factory PoseData.fromJson(Map<String, dynamic> json) => PoseData(
        clip: json['clip'] as String?,
        fps: (json['fps'] as num?)?.toDouble() ?? 0,
        frames: json['frames'] is List
            ? (json['frames'] as List)
                .whereType<Map>()
                .map((frame) => PoseFrame.fromJson(
                    Map<String, dynamic>.from(frame)))
                .toList(growable: false)
            : const [],
      );

  PoseFrame? frameAt(double seconds) {
    if (frames.isEmpty) return null;
    var low = 0;
    var high = frames.length - 1;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (frames[mid].t < seconds) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    if (low > 0 && (frames[low - 1].t - seconds).abs() <
        (frames[low].t - seconds).abs()) {
      return frames[low - 1];
    }
    return frames[low];
  }
}
