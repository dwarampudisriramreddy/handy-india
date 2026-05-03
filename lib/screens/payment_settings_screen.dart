import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/firestore_service.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  bool _isLoading = true;
  late TextEditingController _keyController;
  bool _isLiveMode = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _firestoreService.getAppConfig();
    setState(() {
      _keyController = TextEditingController(text: config.razorpayKey);
      _isLiveMode = config.isLiveMode;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newConfig = AppConfig(
        razorpayKey: _keyController.text.trim(),
        isLiveMode: _isLiveMode,
      );
      
      try {
        await _firestoreService.updateAppConfig(newConfig);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment settings updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving settings: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Settings'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Razorpay Configuration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your API keys and payment environment here. Changes apply to all users instantly.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Razorpay API Key ID',
                      border: OutlineInputBorder(),
                      hintText: 'rzp_test_...',
                    ),
                    validator: (val) => val!.isEmpty ? 'Please enter the API Key' : null,
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Live Mode'),
                    subtitle: Text(_isLiveMode ? 'App is using PRODUCTION keys' : 'App is using TEST keys'),
                    value: _isLiveMode,
                    onChanged: (val) => setState(() => _isLiveMode = val),
                    activeColor: Colors.green,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: const Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
