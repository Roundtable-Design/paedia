import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _startDate = prefs.containsKey('ff_startDate')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_startDate')!)
          : _startDate;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  set startDate(DateTime? value) {
    _startDate = value;
    value != null
        ? prefs.setInt('ff_startDate', value.millisecondsSinceEpoch)
        : prefs.remove('ff_startDate');
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
