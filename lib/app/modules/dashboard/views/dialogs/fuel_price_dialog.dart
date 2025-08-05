import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tag_pilot/app/core/utils/notification_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/vehicle_model.dart';

class FuelPriceDialog extends StatefulWidget {
  final VehicleModel? defaultVehicle;

  const FuelPriceDialog({
    super.key,
    this.defaultVehicle,
  });

  @override
  State<FuelPriceDialog> createState() => _FuelPriceDialogState();
}

class _FuelPriceDialogState extends State<FuelPriceDialog> {
  late TextEditingController _fuelPriceController;
  bool _useDefaultPrice = true;

  @override
  void initState() {
    super.initState();
    final defaultPrice = widget.defaultVehicle?.defaultFuelPricePerLitre ?? 35.0;
    _fuelPriceController = TextEditingController(
      text: defaultPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _fuelPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPrice = widget.defaultVehicle?.defaultFuelPricePerLitre ?? 35.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_gas_station_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Güncel Yakıt Fiyatı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(result: null),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sefer boyunca yakıt gideri hesaplaması için güncel benzin fiyatını girebilirsiniz.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.defaultVehicle != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Araç: ${widget.defaultVehicle!.displayName}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Varsayılan: ₺${defaultPrice.toStringAsFixed(2)}/L',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  RadioListTile<bool>(
                    title: const Text('Varsayılan fiyatı kullan'),
                    subtitle: Text('₺${defaultPrice.toStringAsFixed(2)}/Litre'),
                    value: true,
                    groupValue: _useDefaultPrice,
                    onChanged: (value) {
                      setState(() {
                        _useDefaultPrice = value ?? true;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  RadioListTile<bool>(
                    title: const Text('Güncel fiyat gir'),
                    subtitle: const Text('Bugünkü benzin fiyatını manuel girin'),
                    value: false,
                    groupValue: _useDefaultPrice,
                    onChanged: (value) {
                      setState(() {
                        _useDefaultPrice = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  if (!_useDefaultPrice) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fuelPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Güncel Benzin Fiyatı (₺/Litre)',
                        hintText: 'Örn: ${defaultPrice.toStringAsFixed(2)}',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_gas_station_outlined),
                        suffixText: '₺/L',
                      ),
                      autofocus: true,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        double? fuelPrice;
                        if (_useDefaultPrice) {
                          fuelPrice = defaultPrice; // null değil!
                        } else {
                          final inputPrice = double.tryParse(_fuelPriceController.text);
                          if (inputPrice == null || inputPrice <= 0) {
                            NotificationHelper.showError('Geçerli bir yakıt fiyatı girin');
                            return;
                          }
                          fuelPrice = inputPrice;
                        }
                        Get.back(result: fuelPrice);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Devam Et'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
