import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/secrets.dart';

class AppVersionProvider extends ChangeNotifier {
  final String? _authToken;

  AppVersionProvider(this._authToken);

  Future<String> isAppOutdated() async {
    try {
      final url = '${Secrets.FIREBASE_URL}/appVersion.json?auth=$_authToken';
      final response = await http.get(Uri.parse(url));
      return json.decode(response.body)['version'];
    } catch (error) {
      throw error;
    }
  }

}