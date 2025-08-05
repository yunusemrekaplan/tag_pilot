import 'package:get/get.dart';
import '../../../core/controllers/base_controller.dart';

/// Navigation Controller
/// Ana navigation state management (BottomNavigationBar)
class NavigationController extends BaseController {
  // Reactive Variables
  final RxInt _selectedIndex = 0.obs;

  // Getters
  int get selectedIndex => _selectedIndex.value;

  /// Bottom navigation tab değiştirme
  void changeTab(int index) {
    _selectedIndex.value = index;
  }

  /// Dashboard'a git (index 0)
  void goToDashboard() {
    changeTab(0);
  }

  /// Seferler'e git (index 1)
  void goToRides() {
    changeTab(1);
  }

  /// Giderler'e git (index 2)
  void goToExpenses() {
    changeTab(2);
  }

  /// Raporlar'a git (index 3)
  void goToReports() {
    changeTab(3);
  }

  /// Profil'e git (index 4)
  void goToProfile() {
    changeTab(4);
  }
}
