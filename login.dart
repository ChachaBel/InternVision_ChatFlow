import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  late AnimationController pageController;

  @override
  void initState() {
    super.initState();

    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      pageController.forward(from: 0.0); // 📌 small shake animation
      return;
    }

    setState(() => loading = true);

    final success =
        await ref.read(authProvider.notifier).login(email, password);

    setState(() => loading = false);

    if (!mounted) return;

    if (success) {
      final user = ref.read(authProvider);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/users');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      // 🔥 Fade transition for whole page
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: pageController,
          curve: Curves.easeIn,
        ),

        // 🔥 Slide down animation
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: pageController,
            curve: Curves.easeOut,
          )),

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // EMAIL
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // 🔥 LOGIN BUTTON — AnimatedSwitcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : ElevatedButton(
                          key: const ValueKey("loginBtn"),
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Login"),
                        ),
                ),

                const SizedBox(height: 10),

                // 🔥 AnimatedOpacity + Hero transition
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 400),
                  child: Hero(
                    tag: "registerLink",
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text("Create account"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
