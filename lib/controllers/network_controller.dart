import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class NetworkController extends GetxController {
  static NetworkController get to => Get.find<NetworkController>();

  final RxBool isConnected = true.obs;
  late StreamSubscription _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _startConnectivityListener();
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(connectivityResults);
  }

  void _startConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      await _updateConnectionStatus(results);
    });
  }

  Future<void> _updateConnectionStatus(dynamic results) async {
    List<ConnectivityResult> list = [];
    if (results is List) {
      list = results.cast<ConnectivityResult>();
    } else if (results is ConnectivityResult) {
      list = [results];
    }

    bool hasNetworkInterface = list.isNotEmpty && !list.contains(ConnectivityResult.none);

    if (!hasNetworkInterface) {
      isConnected.value = false;
      return;
    }

    // Active handshake to verify internet backhaul
    final hasInternet = await _checkInternetHandshake();
    isConnected.value = hasInternet;
  }

  Future<bool> _checkInternetHandshake() async {
    try {
      // Ping a reliable public endpoint with a short timeout
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// Force a manual connection recheck
  Future<void> forceRecheck() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(connectivityResults);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
