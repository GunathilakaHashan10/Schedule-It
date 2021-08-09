import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  Connectivity _connectivity = new Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool? _isOnline;

  bool? get isOnline => _isOnline;

  startMonitoring() async {
    await initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        await _updateConnectionStatus().then((bool isConnected) {
          _isOnline = isConnected;
          notifyListeners();
        });
      }
    });
  }

  void cancelStreamSubscription() {
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    try {
      final status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        await _updateConnectionStatus().then((bool isConnected) {
          _isOnline = isConnected;
          notifyListeners();
        });
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> _updateConnectionStatus() async {
    bool isConnected = false;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

// bool _isExitsIPv6(List<InternetAddress> result) {
//   bool isExits = false;
//   for(var i = 0; i < result.length; i++) {
//     if(result[i].type.name == 'IPv6'){
//       isExits = true;
//       break;
//     }
//   }
//   print('isExits = $isExits');
//   return isExits;
// }

}
