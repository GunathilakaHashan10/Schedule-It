import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../models/http_exception.dart';
import '../helpers/secrets.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String? email, String? password, String? urlSegment) async {
    final url =
        '${Secrets.FIREBASE_AUTH_URL}/v1/accounts:$urlSegment?key=${Secrets.API_KEY}';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _refreshToken = responseData['refreshToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoRefreshIdToken();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      final userData = json.encode({
        'token': _token,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _refreshIdToken(String refreshToken) async {
    final url = '${Secrets.FIREBASE_REFRESH_ID_TOKEN_URL}/v1/token?key=${Secrets.API_KEY}';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken
        },
        encoding: Encoding.getByName('utf-8')
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['id_token'];
      _refreshToken = responseData['refresh_token'];
      _userId = responseData['user_id'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expires_in']),
        ),
      );
      _autoRefreshIdToken();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      final userData = json.encode({
        'token': _token,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } on HttpException catch (error) {
      logout();
    } catch (error) {
      logout();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final String? userId = extractedUserData['userId'];
    if (userId == null) {
      return false;
    }
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    _token = extractedUserData['token'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = userId;
    _expiryDate = expiryDate;

    if (expiryDate.isBefore(DateTime.now())) {
      await _refreshIdToken(_refreshToken!).then((_) {
        notifyListeners();
      });
    } else {
      _autoRefreshIdToken();
      notifyListeners();
    }
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _refreshToken = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoRefreshIdToken() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () => _refreshIdToken(_refreshToken!));
  }

}
