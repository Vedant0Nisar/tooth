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
      ToothModel(number: 1, name: "Third Molar (Wisdom Tooth)", position: "Upper Right"),
      ToothModel(number: 2, name: "Second Molar", position: "Upper Right"),
      ToothModel(number: 3, name: "First Molar", position: "Upper Right"),
      ToothModel(number: 4, name: "Second Premolar (Bicuspid)", position: "Upper Right"),
      ToothModel(number: 5, name: "First Premolar (Bicuspid)", position: "Upper Right"),
      ToothModel(number: 6, name: "Canine (Cuspid)", position: "Upper Right"),
      ToothModel(number: 7, name: "Lateral Incisor", position: "Upper Right"),
      ToothModel(number: 8, name: "Central Incisor", position: "Upper Right"),
      ToothModel(number: 9, name: "Central Incisor", position: "Upper Left"),
      ToothModel(number: 10, name: "Lateral Incisor", position: "Upper Left"),
      ToothModel(number: 11, name: "Canine (Cuspid)", position: "Upper Left"),
      ToothModel(number: 12, name: "First Premolar (Bicuspid)", position: "Upper Left"),
      ToothModel(number: 13, name: "Second Premolar (Bicuspid)", position: "Upper Left"),
      ToothModel(number: 14, name: "First Molar", position: "Upper Left"),
      ToothModel(number: 15, name: "Second Molar", position: "Upper Left"),
      ToothModel(number: 16, name: "Third Molar (Wisdom Tooth)", position: "Upper Left"),
      ToothModel(number: 17, name: "Third Molar (Wisdom Tooth)", position: "Lower Left"),
      ToothModel(number: 18, name: "Second Molar", position: "Lower Left"),
      ToothModel(number: 19, name: "First Molar", position: "Lower Left"),
      ToothModel(number: 20, name: "Second Premolar (Bicuspid)", position: "Lower Left"),
      ToothModel(number: 21, name: "First Premolar (Bicuspid)", position: "Lower Left"),
      ToothModel(number: 22, name: "Canine (Cuspid)", position: "Lower Left"),
      ToothModel(number: 23, name: "Lateral Incisor", position: "Lower Left"),
      ToothModel(number: 24, name: "Central Incisor", position: "Lower Left"),
      ToothModel(number: 25, name: "Central Incisor", position: "Lower Right"),
      ToothModel(number: 26, name: "Lateral Incisor", position: "Lower Right"),
      ToothModel(number: 27, name: "Canine (Cuspid)", position: "Lower Right"),
      ToothModel(number: 28, name: "First Premolar (Bicuspid)", position: "Lower Right"),
      ToothModel(number: 29, name: "Second Premolar (Bicuspid)", position: "Lower Right"),
      ToothModel(number: 30, name: "First Molar", position: "Lower Right"),
      ToothModel(number: 31, name: "Second Molar", position: "Lower Right"),
      ToothModel(number: 32, name: "Third Molar (Wisdom Tooth)", position: "Lower Right"),
    ];
    
    isLoading.value = false;
  }
}
