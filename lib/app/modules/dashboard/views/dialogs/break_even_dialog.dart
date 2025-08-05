import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/notification_helper.dart';
import '../../../../data/models/package_model.dart';
import '../../controllers/dashboard_controller.dart';

class BreakEvenDialog extends StatefulWidget {
  final DashboardController controller;

  const BreakEvenDialog({
    super.key,
    required this.controller,
  });

  @override
  State<BreakEvenDialog> createState() => _BreakEvenDialogState();
}

class _BreakEvenDialogState extends State<BreakEvenDialog> {
  final TextEditingController _manualController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController(text: '0');

  bool _isAutoMode = true;
  double _calculatedBreakEven = 0.0;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _calculateBreakEven();
  }

  void _initializeValues() {
    _manualController.text = widget.controller.breakEvenPoint.toStringAsFixed(0);
  }

  void _calculateBreakEven() {
    setState(() {
      _isCalculating = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      double packageCost = 0;

      if (widget.controller.activePackage != null) {
        packageCost = widget.controller.activePackage!.breakEvenCost;
      } else if (widget.controller.availablePackages.isNotEmpty) {
        packageCost = widget.controller.availablePackages.first.breakEvenCost;
      }

      final expenses = double.tryParse(_expensesController.text) ?? 0;
      _calculatedBreakEven = packageCost + expenses;

      setState(() {
        _isCalculating = false;
      });
    });
  }

  PackageModel? get _activePackage {
    return widget.controller.activePackage ??
        (widget.controller.availablePackages.isNotEmpty ? widget.controller.availablePackages.first : null);
  }

  @override
  void dispose() {
    _manualController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModeSelector(),
                    const SizedBox(height: 24),
                    if (_isAutoMode) ...[
                      _buildAutoModeContent(),
                    ] else ...[
                      _buildManualModeContent(),
                    ],
                    const SizedBox(height: 24),
                    _buildActionButtons(),
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
    return Container(
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
            Icons.analytics_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Başabaş Noktası Belirle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAutoMode = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isAutoMode ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'Otomatik',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isAutoMode ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAutoMode = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isAutoMode ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'Manuel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: !_isAutoMode ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoModeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_activePackage != null) _buildPackageCard(),
        const SizedBox(height: 16),
        _buildExpensesInput(),
        const SizedBox(height: 16),
        _buildCalculationResult(),
      ],
    );
  }

  Widget _buildPackageCard() {
    final package = _activePackage!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Paket: ${package.name}',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Maliyet: ${package.breakEvenCostDescription}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ek Giderler',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _expensesController,
          keyboardType: TextInputType.number,
          onChanged: (value) => _calculateBreakEven(),
          decoration: InputDecoration(
            labelText: 'Manuel giderler (₺)',
            helperText: 'Yakıt gideri otomatik hesaplanır',
            prefixIcon: const Icon(Icons.receipt_long_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hesaplanan Başabaş Noktası:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          if (_isCalculating) ...[
            const Center(child: CircularProgressIndicator()),
          ] else ...[
            Text(
              '₺${_calculatedBreakEven.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Paket maliyeti + manuel giderler',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualModeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manuel Başabaş Noktası',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Başabaş noktası (₺)',
            helperText: 'Günlük kazanç hedefinizi belirleyin',
            prefixIcon: const Icon(Icons.flag_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveBreakEvenPoint,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: const Text('Kaydet'),
      ),
    );
  }

  Future<void> _saveBreakEvenPoint() async {
    double newBreakEven = 0;

    if (_isAutoMode) {
      newBreakEven = _calculatedBreakEven;
    } else {
      newBreakEven = double.tryParse(_manualController.text) ?? 0;
    }

    if (newBreakEven > 0) {
      await widget.controller.updateBreakEvenPoint(newBreakEven);
      Get.back();
      NotificationHelper.showSuccess(
        'Başabaş noktası ₺${newBreakEven.toStringAsFixed(0)} olarak güncellendi',
      );
    } else {
      NotificationHelper.showError('Geçerli bir tutar giriniz');
    }
  }
}
