import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkResult{
  on,
  off;

  static NetworkResult checkConnectivity(ConnectivityResult result){
    switch(result){
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
        return NetworkResult.on;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
      default:
        return NetworkResult.off;
    }
  }
}