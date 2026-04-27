import 'package:get/get.dart';
import '../models/tooth_model.dart';

class ToothListController extends GetxController {
  var isLoading = true.obs;
  var teethList = <ToothModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTeeth();
  }

  void loadTeeth() async {
    isLoading.value = true;
    
    // Simulate network/initialization delay to show beautiful loader
    await Future.delayed(const Duration(seconds: 3));
    
    teethList.value = [
      // Upper Right (Maxillary Right) - 1 to 8
      ToothModel(number: 1, name: "Third Molar (Wisdom Tooth)", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-third-molar.glb"),
      ToothModel(number: 2, name: "Second Molar", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-second-molar.glb"),
      ToothModel(number: 3, name: "First Molar", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-first-molar.glb"),
      ToothModel(number: 4, name: "Second Premolar (Bicuspid)", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-second-premolar.glb"),
      ToothModel(number: 5, name: "First Premolar (Bicuspid)", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-first-premolar.glb"),
      ToothModel(number: 6, name: "Canine (Cuspid)", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-canine.glb"),
      ToothModel(number: 7, name: "Lateral Incisor", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-lateral-incisor.glb"),
      ToothModel(number: 8, name: "Central Incisor", position: "Upper Right", objPath: "assets/tooth_single_32/maxillary-right-central-incisor.glb"),
      
      // Upper Left (Maxillary Left) - 9 to 16
      ToothModel(number: 9, name: "Central Incisor", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-central-incisor.glb"),
      ToothModel(number: 10, name: "Lateral Incisor", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-lateral-incisor.glb"),
      ToothModel(number: 11, name: "Canine (Cuspid)", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-canine.glb"),
      ToothModel(number: 12, name: "First Premolar (Bicuspid)", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-first-premolar.glb"),
      ToothModel(number: 13, name: "Second Premolar (Bicuspid)", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-second-premolar.glb"),
      ToothModel(number: 14, name: "First Molar", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-first-molar.glb"),
      ToothModel(number: 15, name: "Second Molar", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-second-molar.glb"),
      ToothModel(number: 16, name: "Third Molar (Wisdom Tooth)", position: "Upper Left", objPath: "assets/tooth_single_32/maxillary-left-third-molar.glb"),
      
      // Lower Left (Mandibular Left) - 17 to 24
      ToothModel(number: 17, name: "Third Molar (Wisdom Tooth)", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-third-molar.glb"),
      ToothModel(number: 18, name: "Second Molar", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-second-molar.glb"),
      ToothModel(number: 19, name: "First Molar", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-first-molar.glb"),
      ToothModel(number: 20, name: "Second Premolar (Bicuspid)", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-second-premolar.glb"),
      ToothModel(number: 21, name: "First Premolar (Bicuspid)", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-first-premolar.glb"),
      ToothModel(number: 22, name: "Canine (Cuspid)", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-canine.glb"),
      ToothModel(number: 23, name: "Lateral Incisor", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-lateral-incisor.glb"),
      ToothModel(number: 24, name: "Central Incisor", position: "Lower Left", objPath: "assets/tooth_single_32/mandibular-left-central-incisor.glb"),
      
      // Lower Right (Mandibular Right) - 25 to 32
      ToothModel(number: 25, name: "Central Incisor", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-central-incisor.glb"),
      ToothModel(number: 26, name: "Lateral Incisor", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-lateral-incisor.glb"),
      ToothModel(number: 27, name: "Canine (Cuspid)", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-canine.glb"),
      ToothModel(number: 28, name: "First Premolar (Bicuspid)", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-first-premolar.glb"),
      ToothModel(number: 29, name: "Second Premolar (Bicuspid)", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-second-premolar.glb"),
      ToothModel(number: 30, name: "First Molar", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-first-molar.glb"),
      ToothModel(number: 31, name: "Second Molar", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-second-molar.glb"),
      ToothModel(number: 32, name: "Third Molar (Wisdom Tooth)", position: "Lower Right", objPath: "assets/tooth_single_32/mandibular-right-third-molar.glb"),
    ];
    
    isLoading.value = false;
  }
}
