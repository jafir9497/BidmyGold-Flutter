import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Model for Payment Log Entry (consider creating a separate model file later)
class PaymentLog {
  final String id;
  final String userId;
  final String status; // 'success', 'failed'
  final Timestamp timestamp;
  final String? orderId;
  final String? paymentId;
  final String? errorCode;
  final String? errorMessage;
  final String? paymentMethod;

  PaymentLog({
    required this.id,
    required this.userId,
    required this.status,
    required this.timestamp,
    this.orderId,
    this.paymentId,
    this.errorCode,
    this.errorMessage,
    this.paymentMethod,
  });

  factory PaymentLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'unknown',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      orderId: data['orderId'] as String?,
      paymentId: data['paymentId'] as String?,
      errorCode: data['errorCode'] as String?,
      errorMessage: data['errorMessage'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
    );
  }
}

class PaymentHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxList<PaymentLog> paymentLogs = <PaymentLog>[].obs;
  final RxString errorMessage = ''.obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    if (isRefresh) {
      paymentLogs.clear();
    }

    if (currentUser == null) {
      errorMessage.value = 'User not authenticated.';
      isLoading.value = false;
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('payment_logs')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit initial fetch, add pagination later if needed
          .get();

      paymentLogs.value = querySnapshot.docs
          .map((doc) => PaymentLog.fromFirestore(doc))
          .toList();

      if (paymentLogs.isEmpty) {
        print('No payment logs found for user ${currentUser!.uid}');
        // Optionally set a message like "No payment history yet."
      }
    } catch (e) {
      print('Error fetching payment history: $e');
      errorMessage.value = 'Failed to load payment history: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper for formatting dates
  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }
}
