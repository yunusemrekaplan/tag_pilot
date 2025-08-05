import 'package:get/get.dart';

import '../controllers/expense_controller.dart';

/// Clean Architecture uyumlu Expense Binding
/// SOLID: Single Responsibility - Sadece expense controller dependency injection
/// Repository ve Use Case'ler ApplicationBinding'de hallediliyor
/// Bu binding sadece controller'ı register eder
class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // Expense Controller'ı register et
    // Dependencies (repositories, use cases) ApplicationBinding'de hallediliyor
    _registerControllers();
  }

  /// Controller'ları register et
  void _registerControllers() {
    Get.lazyPut<ExpenseController>(
      () => ExpenseController(),
      fenix: true,
    );
  }
}
