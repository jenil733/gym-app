import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';

class BmiCalculatorCard extends StatefulWidget {
  const BmiCalculatorCard({
    super.key,
    this.initialHeight = 0,
    this.initialWeight = 0,
  });

  final double initialHeight;
  final double initialWeight;

  @override
  State<BmiCalculatorCard> createState() => _BmiCalculatorCardState();
}

class _BmiCalculatorCardState extends State<BmiCalculatorCard> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double? _bmi;
  String? _error;

  @override
  void initState() {
    super.initState();
    _useProfileMeasurements();
  }

  @override
  void didUpdateWidget(covariant BmiCalculatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHeight != widget.initialHeight ||
        oldWidget.initialWeight != widget.initialWeight) {
      _useProfileMeasurements();
    }
  }

  void _useProfileMeasurements() {
    if (widget.initialHeight > 0) {
      _heightController.text = _compact(widget.initialHeight);
    }
    if (widget.initialWeight > 0) {
      _weightController.text = _compact(widget.initialWeight);
    }
    if (widget.initialHeight > 0 && widget.initialWeight > 0) {
      final meters = widget.initialHeight / 100;
      _bmi = widget.initialWeight / (meters * meters);
      _error = null;
    } else {
      _bmi = null;
    }
  }

  String _compact(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    final height = double.tryParse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    if (height == null || height <= 0 || weight == null || weight <= 0) {
      setState(() {
        _bmi = null;
        _error = 'Enter a valid height and weight.';
      });
      return;
    }
    final heightInMeters = height / 100;
    setState(() {
      _bmi = weight / (heightInMeters * heightInMeters);
      _error = null;
    });
  }

  String _category(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy range';
    if (bmi < 30) return 'Overweight';
    return 'Obesity range';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    return Container(
      key: const ValueKey('home-bmi-calculator'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI Calculator', style: TextHelper.homeTitle2),
                    Text(
                      'Check your weight-to-height range',
                      style: TextHelper.homeSubtitle.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('bmi-height-input'),
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    suffixText: 'cm',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const ValueKey('bmi-weight-input'),
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    suffixText: 'kg',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('calculate-bmi-button'),
              onPressed: _calculate,
              icon: const Icon(Icons.monitor_heart_outlined),
              label: const Text('Calculate BMI'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              key: const ValueKey('bmi-error'),
              style: TextHelper.homeSubtitle.copyWith(color: AppColors.warning),
            ),
          ],
          const SizedBox(height: 12),
          Semantics(
            label: bmi == null
                ? 'BMI 0.0, add height and weight'
                : 'BMI ${bmi.toStringAsFixed(1)}, ${_category(bmi)}',
            child: Container(
              key: const ValueKey('bmi-result'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    bmi?.toStringAsFixed(1) ?? '0.0',
                    style: TextHelper.homeValue.copyWith(fontSize: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bmi == null ? 'Add height and weight' : _category(bmi),
                      style: TextHelper.poppins.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
