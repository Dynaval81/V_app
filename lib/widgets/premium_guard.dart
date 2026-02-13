import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

/// Widget that wraps a screen and shows an activation prompt when the
/// current user is not premium. After entering a code and activating,
/// the child is displayed immediately.
class PremiumGuard extends StatefulWidget {
  final Widget child;

  const PremiumGuard({Key? key, required this.child}) : super(key: key);

  @override
  _PremiumGuardState createState() => _PremiumGuardState();
}

class _PremiumGuardState extends State<PremiumGuard> {
  final TextEditingController _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _activate(UserProvider userProvider) async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService().activatePremium(code);
    setState(() => _loading = false);
    if (result['success'] == true) {
      // Update local state immediately
      userProvider.activatePremium(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Activated')),
      );
    } else {
      setState(() => _error = result['error'] ?? 'Activation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (userProvider.isPremium) {
          return widget.child;
        }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 72, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Feature',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your activation code to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Code',
                      errorText: _error,
                      filled: true,
                      fillColor:
                          isDark ? Colors.white12 : Colors.black12,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => _activate(userProvider),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Activate'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
