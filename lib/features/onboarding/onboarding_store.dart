import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PartnerKind { solo, agency, hotel }

class OnboardingAnswers {
  OnboardingAnswers({
    this.kind,
    this.offerings = const {},
    this.region,
    this.businessName,
    this.phone,
    this.completed = false,
  });
  final PartnerKind? kind;
  final Set<String> offerings;
  final String? region;
  final String? businessName;
  final String? phone;
  final bool completed;

  OnboardingAnswers copyWith({
    PartnerKind? kind,
    Set<String>? offerings,
    String? region,
    String? businessName,
    String? phone,
    bool? completed,
  }) =>
      OnboardingAnswers(
        kind: kind ?? this.kind,
        offerings: offerings ?? this.offerings,
        region: region ?? this.region,
        businessName: businessName ?? this.businessName,
        phone: phone ?? this.phone,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'kind': kind?.name,
        'offerings': offerings.toList(),
        'region': region,
        'businessName': businessName,
        'phone': phone,
        'completed': completed,
      };

  static OnboardingAnswers fromJson(Map<String, dynamic> j) => OnboardingAnswers(
        kind: switch (j['kind']) {
          'solo' => PartnerKind.solo,
          'agency' => PartnerKind.agency,
          'hotel' => PartnerKind.hotel,
          _ => null,
        },
        offerings:
            ((j['offerings'] as List?) ?? const []).map((e) => '$e').toSet(),
        region: j['region']?.toString(),
        businessName: j['businessName']?.toString(),
        phone: j['phone']?.toString(),
        completed: j['completed'] == true,
      );
}

class OnboardingController extends StateNotifier<OnboardingAnswers> {
  OnboardingController() : super(OnboardingAnswers()) {
    _restore();
  }
  static const _key = 'partners.onboarding';

  Future<void> _restore() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return;
    try {
      state = OnboardingAnswers.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(state.toJson()));
  }

  void setKind(PartnerKind k) {
    state = state.copyWith(kind: k);
    _persist();
  }

  void toggleOffering(String o) {
    final next = {...state.offerings};
    if (!next.add(o)) next.remove(o);
    state = state.copyWith(offerings: next);
    _persist();
  }

  void setRegion(String r) {
    state = state.copyWith(region: r);
    _persist();
  }

  void setBusiness({String? name, String? phone}) {
    state = state.copyWith(businessName: name, phone: phone);
    _persist();
  }

  Future<void> complete() async {
    state = state.copyWith(completed: true);
    await _persist();
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingAnswers>(
  (_) => OnboardingController(),
);
