import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'login.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email; // diteruskan dari ForgotPasswordPage

  const ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _doReset() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (token.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Semua field wajib diisi');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Password tidak cocok');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password minimal 8 karakter');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ProfileService.resetPassword(
      email: widget.email ?? '',
      token: token,
      password: password,
      passwordConfirmation: confirm,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Reset berhasil → kembali ke login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      setState(
          () => _errorMessage = result['message'] ?? 'Gagal mereset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(color: Colors.black.withValues(alpha: 0.5)),

          Column(
            children: [
              Expanded(child: Container()),

              // Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white, Colors.black],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      height: 60,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage("assets/deco/banner.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (widget.email != null && widget.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Reset untuk: ${widget.email}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),

                    // Token field
                    TextField(
                      controller: _tokenController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Token dari Email",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Password Baru
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureNew,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Password Baru",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Konfirmasi Password
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Masukkan Ulang Password",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Button Reset
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC67C4E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Reset Password",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
