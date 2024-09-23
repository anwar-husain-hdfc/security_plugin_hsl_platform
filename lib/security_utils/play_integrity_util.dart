class PlayIntegrityUtil {
  // Private constructor
  PlayIntegrityUtil._internal();

  // Singleton instance
  static final PlayIntegrityUtil _instance = PlayIntegrityUtil._internal();

  // Factory constructor to return the same instance
  factory PlayIntegrityUtil() {
    return _instance;
  }

  // Variable to track the Play Integrity check status
  bool isPlayIntegrityChecked = false;
}
