import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  String? imageUrl;

  late AnimationController pageController;

  @override
  void initState() {
    super.initState();

    // Page animation controller
    pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();

    // Load profile
    final user = ref.read(authProvider);
    if (user != null) {
      loadUserData(user.uid);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadUserData(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    usernameController.text = snap["username"];
    imageUrl = snap["photoUrl"];
    setState(() {});
  }

  Future<void> pickImage(String uid) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("$uid.jpg");

    await ref.putFile(File(picked.path));
    imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"photoUrl": imageUrl});

    setState(() {});
  }

  Future<void> saveProfile() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    if (usernameController.text.trim().isEmpty) {
   
      pageController.forward(from: 0.0);
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"username": usernameController.text.trim()});

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),

      // Fade + Slide animation
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: pageController,
          curve: Curves.easeIn,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: pageController,
            curve: Curves.easeOut,
          )),

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero Animation + Smooth animate container 
                GestureDetector(
                  onTap: () => pickImage(user.uid),
                  child: Hero(
                    tag: "profile_${user.uid}",
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          image: imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //  Username Field with Fade-in
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: pageController,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Save Button - slide + fade
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: pageController,
                    curve: const Interval(0.3, 1, curve: Curves.easeOut),
                  )),
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
