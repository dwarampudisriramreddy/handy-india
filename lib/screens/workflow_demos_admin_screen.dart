import 'package:flutter/material.dart';
import '../models/workflow_demo.dart';
import '../services/firestore_service.dart';

class WorkflowDemosAdminScreen extends StatefulWidget {
  const WorkflowDemosAdminScreen({super.key});

  @override
  State<WorkflowDemosAdminScreen> createState() => _WorkflowDemosAdminScreenState();
}

class _WorkflowDemosAdminScreenState extends State<WorkflowDemosAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  void _addDemo() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _firestoreService.addWorkflowDemo(
        _titleController.text,
        _urlController.text,
      );
      _titleController.clear();
      _urlController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow demo added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding demo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workflow Demos'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Add New Workflow Demo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Demo Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'YouTube URL',
                        border: OutlineInputBorder(),
                        hintText: 'https://www.youtube.com/watch?v=...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addDemo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Add Demo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<WorkflowDemo>>(
              stream: _firestoreService.getWorkflowDemos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No workflow demos yet.'));
                }

                final demos = snapshot.data!;
                return ListView.builder(
                  itemCount: demos.length,
                  itemBuilder: (context, index) {
                    final demo = demos[index];
                    return ListTile(
                      title: Text(demo.title),
                      subtitle: Text(demo.videoUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deleteWorkflowDemo(demo.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
