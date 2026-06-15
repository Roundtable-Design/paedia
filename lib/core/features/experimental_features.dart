import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabledKey = 'paedia_experimental_enabled';
const _dayIllustrationsKey = 'paedia_experimental_day_illustrations';

/// User-controlled experimental feature flags (off by default).
class ExperimentalFeaturesSettings {
  const ExperimentalFeaturesSettings({
    this.enabled = false,
    this.dayIllustrations = false,
  });

  final bool enabled;
  final bool dayIllustrations;

  bool get showDayIllustrations => enabled && dayIllustrations;

  ExperimentalFeaturesSettings copyWith({
    bool? enabled,
    bool? dayIllustrations,
  }) {
    return ExperimentalFeaturesSettings(
      enabled: enabled ?? this.enabled,
      dayIllustrations: dayIllustrations ?? this.dayIllustrations,
    );
  }
}

class ExperimentalFeaturesNotifier
    extends StateNotifier<ExperimentalFeaturesSettings> {
  ExperimentalFeaturesNotifier() : super(const ExperimentalFeaturesSettings()) {
    _load();
  }

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    state = ExperimentalFeaturesSettings(
      enabled: _prefs!.getBool(_enabledKey) ?? false,
      dayIllustrations: _prefs!.getBool(_dayIllustrationsKey) ?? false,
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await (_prefs ??= await SharedPreferences.getInstance())
        .setBool(_enabledKey, value);
  }

  Future<void> setDayIllustrations(bool value) async {
    state = state.copyWith(dayIllustrations: value);
    await (_prefs ??= await SharedPreferences.getInstance())
        .setBool(_dayIllustrationsKey, value);
  }
}

final experimentalFeaturesProvider = StateNotifierProvider<
    ExperimentalFeaturesNotifier, ExperimentalFeaturesSettings>(
  (ref) => ExperimentalFeaturesNotifier(),
);
