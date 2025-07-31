import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key}); // Fixed constructor

  @override
  _ApiKeyScreenState createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureText = true;
  bool _useEnvKey = false;

  @override
  void initState() {
    super.initState();
    // Check if API key exists in environment
    final envKey = dotenv.env['OPENROUTER_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      setState(() {
        _useEnvKey = true;
        _apiKeyController.text = envKey;
      });
    }
  }

  void _connectToChat() {
    String apiKey =
        _useEnvKey
            ? (dotenv.env['OPENROUTER_API_KEY'] ?? '')
            : _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your OpenRouter API key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debug print to check if API key contains any unexpected characters
    print('API Key length: ${apiKey.length}');
    print('API Key starts with: ${apiKey.substring(0, 10)}...');

    Navigator.of(context).pushNamed('/ai-chat', arguments: apiKey);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeData.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShieldAi Setup'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [Colors.grey[900]!, Colors.blue[900]!, Colors.grey[900]!]
                    : [Colors.blue[50]!, Colors.white, Colors.blue[50]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 64, color: Colors.blue[600]),
                    const SizedBox(height: 24),
                    const Text(
                      'ShieldAi Assistant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your intelligent cybersecurity companion in ShieldUp',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Environment key option
                    if (dotenv.env['OPENROUTER_API_KEY'] != null) ...[
                      CheckboxListTile(
                        title: const Text('Use configured API key'),
                        subtitle: const Text(
                          'Use the API key from app configuration',
                        ),
                        value: _useEnvKey,
                        onChanged: (value) {
                          setState(() {
                            _useEnvKey = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Manual API key input
                    if (!_useEnvKey) ...[
                      TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'OpenRouter API Key',
                          hintText: 'sk-or-v1-...',
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _connectToChat(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _connectToChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Connect to ShieldAi',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[800],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your API key is only used for this session and is not stored permanently.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('About ShieldAi'),
                                content: const Text(
                                  'ShieldAi is your intelligent cybersecurity assistant, created by Francis and Robert to help you learn cybersecurity in an interactive and engaging way.\n\n'
                                  'To get your OpenRouter API key:\n'
                                  '1. Visit openrouter.ai\n'
                                  '2. Sign up for an account\n'
                                  '3. Go to API Keys section\n'
                                  '4. Create a new API key\n'
                                  '5. Copy and paste it here',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Got it'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text('About ShieldAi & API Setup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
