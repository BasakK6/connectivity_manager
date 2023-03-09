import 'dart:async';

import 'package:connectivity_manager/connectivity_change/network_result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkChangeNotifier extends StateNotifier<NetworkResult> {
  NetworkChangeNotifier(NetworkResult state) : super(state) {
    init();
  }

  Future<void> init() async {
    final Connectivity connectivity = Connectivity();
    await checkInitialConnection(connectivity);
    subscribeToTheConnectionChange(connectivity);
  }

  Future<void> checkInitialConnection(
      Connectivity connectivity) async {
    var connectivityResult = await connectivity.checkConnectivity();
    state = NetworkResult.checkConnectivity(connectivityResult);
  }

  void subscribeToTheConnectionChange(Connectivity connectivity) {
    connectivity.onConnectivityChanged.listen((event) {
      state = NetworkResult.checkConnectivity(event);
    });
  }
}

//create a global provider object
final networkChangeNotifierProvider =
    StateNotifierProvider<NetworkChangeNotifier, NetworkResult>((ref) {
  return NetworkChangeNotifier(NetworkResult.off);
});
