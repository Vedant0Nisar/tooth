import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/tooth_list_controller.dart';
import '../controllers/transform_controller.dart';
import '../models/tooth_model.dart';
import 'main_screen.dart';

class ToothListScreen extends StatelessWidget {
  const ToothListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ToothListController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text(
          'Dental Arch',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF131A26), Color(0xFF0A0E17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                          strokeWidth: 2,
                        ),
                      ),
                      Lottie.asset(
                        'assets/tooth_loader.json',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Initializing 3D Module...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        final upperTeeth = controller.teethList.where((t) => t.position.contains('Upper')).toList();
        final lowerTeeth = controller.teethList.where((t) => t.position.contains('Lower')).toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSectionHeader('UPPER ARCH', Colors.blueAccent),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildToothCard(context, upperTeeth[index], index),
                  childCount: upperTeeth.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            _buildSectionHeader('LOWER ARCH', Colors.orangeAccent),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildToothCard(context, lowerTeeth[index], index),
                  childCount: lowerTeeth.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: accentColor, blurRadius: 12, spreadRadius: 2),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                shadows: [
                  Shadow(color: accentColor.withOpacity(0.8), blurRadius: 15),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.stars_rounded, color: accentColor.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildToothCard(BuildContext context, ToothModel tooth, int index) {
    // Determine the color accent based on quadrant
    Color accentColor;
    if (tooth.position.contains("Upper Right")) {
      accentColor = Colors.lightBlueAccent;
    } else if (tooth.position.contains("Upper Left")) {
      accentColor = Colors.tealAccent;
    } else if (tooth.position.contains("Lower Left")) {
      accentColor = Colors.deepOrangeAccent;
    } else {
      accentColor = Colors.purpleAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: accentColor.withOpacity(0.2),
          highlightColor: accentColor.withOpacity(0.1),
          onTap: () {
            // Set the selected tooth in the TransformController
            final transformCtrl = Get.put(TransformController());
            transformCtrl.setSelectedTooth(tooth);
            
            // Navigate to main screen showing the 3D model
            Get.to(() => const MainScreen(), transition: Transition.zoom);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withOpacity(0.2),
                        const Color(0xFF0F1520),
                      ],
                      radius: 0.8,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      tooth.number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: accentColor, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tooth.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          tooth.position.toUpperCase(),
                          style: TextStyle(
                            color: accentColor.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.view_in_ar,
                    color: accentColor.withOpacity(0.8),
                    size: 24,
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
