class AppConfig {
  final String razorpayKey;
  final bool isLiveMode;

  AppConfig({
    required this.razorpayKey,
    this.isLiveMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'razorpayKey': razorpayKey,
      'isLiveMode': isLiveMode,
    };
  }

  factory AppConfig.fromFirestore(Map<String, dynamic> data) {
    return AppConfig(
      razorpayKey: data['razorpayKey'] ?? 'rzp_test_Sjh2VmcaT2ndLx',
      isLiveMode: data['isLiveMode'] ?? false,
    );
  }
}
