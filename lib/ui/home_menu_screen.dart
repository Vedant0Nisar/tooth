import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'tooth_list_screen.dart';
import 'jaw_simulator_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E17), Color(0xFF131A26), Color(0xFF0A0E17)],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glows
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildMenuCard(
                            title: 'Dental Tutorial',
                            subtitle: '32 Teeth Mastery & 3D Lookup',
                            icon: Icons.auto_stories_rounded,
                            accentColor: Colors.blueAccent,
                            onTap: () => Get.to(() => const ToothListScreen()),
                          ),
                          const SizedBox(height: 20),
                          _buildMenuCard(
                            title: 'Clinical Quizzes',
                            subtitle: 'Test your knowledge (Coming Soon)',
                            icon: Icons.quiz_rounded,
                            accentColor: Colors.amberAccent,
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'This module is currently under development.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.amberAccent.withOpacity(0.1),
                                colorText: Colors.white,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildMenuCard(
                            title: '3D Jaw Simulator',
                            subtitle: 'Interactive Positioning & Simulation',
                            icon: Icons.view_in_ar_rounded,
                            accentColor: Colors.greenAccent,
                            onTap: () => Get.to(() =>  JawSimulatorScreen()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.biotech_rounded, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 16),
            const Text(
              'DENTALPRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Diagnostic\nLearning Suite',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Icon(icon, color: accentColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
