class WorkflowDemo {
  final String id;
  final String title;
  final String videoUrl;

  WorkflowDemo({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoUrl': videoUrl,
    };
  }

  factory WorkflowDemo.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkflowDemo(
      id: id,
      title: data['title'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}
