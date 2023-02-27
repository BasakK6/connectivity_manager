import 'dart:async';

import 'package:connectivity_manager/connectivity_change/network_result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkChangeManager extends ChangeNotifier {
  late final Connectivity _connectivity;
  late NetworkResult networkResult = NetworkResult.off;

  NetworkChangeManager() {
    _connectivity = Connectivity();
    init();
  }

  Future<void> init() async{
    networkResult = await checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((event) {
      networkResult = NetworkResult.checkConnectivity(event);
      notifyListeners();
    });
  }

  Future<NetworkResult> checkInitialConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return NetworkResult.checkConnectivity(connectivityResult);
  }
}

final networkChangeManagerProvider = ChangeNotifierProvider((ref) {
  return NetworkChangeManager();
});
