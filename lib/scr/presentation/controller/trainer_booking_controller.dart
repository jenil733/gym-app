import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';

class TrainerBookingController extends GetxController {
  final List<Trainer> trainers = const [
    Trainer(
      name: 'Arjun Mehta',
      specialty: 'Strength and hypertrophy',
      time: 'Today, 6:00 PM',
      amount: 'INR 699',
      rating: '4.9',
      color: AppColors.primary,
      icon: Icons.fitness_center_rounded,
    ),
    Trainer(
      name: 'Neha Kapoor',
      specialty: 'Weight loss and HIIT',
      time: 'Tomorrow, 7:30 AM',
      amount: 'INR 599',
      rating: '4.8',
      color: AppColors.statCalories,
      icon: Icons.directions_run_rounded,
    ),
    Trainer(
      name: 'Vikram Rao',
      specialty: 'Mobility and posture',
      time: 'Friday, 5:30 PM',
      amount: 'INR 549',
      rating: '4.7',
      color: AppColors.secondary,
      icon: Icons.self_improvement_rounded,
    ),
  ];

  void bookTrainer(Trainer trainer) {
    ToastHelper.success(
      'Trainer booked',
      '${trainer.name} is reserved for ${trainer.time}.',
    );
  }
}

class Trainer {
  const Trainer({
    required this.name,
    required this.specialty,
    required this.time,
    required this.amount,
    required this.rating,
    required this.color,
    required this.icon,
  });

  final String name;
  final String specialty;
  final String time;
  final String amount;
  final String rating;
  final Color color;
  final IconData icon;
}
