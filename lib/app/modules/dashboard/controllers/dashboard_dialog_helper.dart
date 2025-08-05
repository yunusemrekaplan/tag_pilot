import 'package:get/get.dart';
import '../../../data/models/package_model.dart';
import '../../../data/models/vehicle_model.dart';
import '../views/dialogs/package_selection_dialog.dart';
import '../views/dialogs/fuel_price_dialog.dart';

/// Dashboard Dialog Helper - Dialog açma fonksiyonları burada merkezi olarak yönetilir
class DashboardDialogHelper {
  /// Paket seçim dialogunu göster
  static Future<PackageModel?> showPackageSelectionDialog(List<PackageModel> availablePackages) async {
    if (availablePackages.isEmpty) {
      return null;
    }
    PackageModel? selectedPackage;
    await Get.dialog<PackageModel>(
      PackageSelectionDialog(
        availablePackages: availablePackages,
        onPackageSelected: (package) {
          selectedPackage = package;
        },
      ),
      barrierDismissible: false,
    );
    return selectedPackage;
  }

  /// Yakıt fiyatı dialogunu göster
  static Future<double?> showFuelPriceDialog(VehicleModel? defaultVehicle) async {
    final fuelPrice = await Get.dialog<double?>(
      FuelPriceDialog(defaultVehicle: defaultVehicle),
      barrierDismissible: false,
    );
    return fuelPrice;
  }
}
