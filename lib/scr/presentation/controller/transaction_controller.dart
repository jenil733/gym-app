import 'package:get/get.dart';

class TransactionController extends GetxController {
  final RxList<TransactionRecord> transactions = <TransactionRecord>[].obs;

  static TransactionController findOrCreate() {
    if (Get.isRegistered<TransactionController>()) {
      return Get.find<TransactionController>();
    }
    return Get.put(TransactionController());
  }

  void recordPayment({
    required String plan,
    required String amount,
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    transactions.insert(
      0,
      TransactionRecord(
        id: 'TXN-${now.microsecondsSinceEpoch}',
        plan: plan,
        amount: amount,
        paymentMethod: paymentMethod,
        createdAt: now,
        status: TransactionStatus.completed,
      ),
    );
  }
}

enum TransactionStatus { completed }

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.plan,
    required this.amount,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String plan;
  final String amount;
  final String paymentMethod;
  final DateTime createdAt;
  final TransactionStatus status;
}
