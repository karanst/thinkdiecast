import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayManager {
  late Razorpay _razorpay;
  final BuildContext context;
  final VoidCallback? onPaymentSuccessCallback;

  RazorpayManager(this.context, {this.onPaymentSuccessCallback}) {
    _razorpay = Razorpay();
  }

  void initialize() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String apiKey,
    required int amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) {
    var options = {
      'key': apiKey,
      'amount': amount, // Amount in paise
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Success: ${response.paymentId}");
    _showMessage('Payment Successful! ID: ${response.paymentId}');
    if (onPaymentSuccessCallback != null) {
      onPaymentSuccessCallback!();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error: ${response.code} | ${response.message}");
    _showMessage('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
    _showMessage('External Wallet Selected: ${response.walletName}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose() {
    _razorpay.clear();
  }
}
