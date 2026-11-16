/// Profile state management — loads/saves from Supabase `profiles` table.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/user_profile_model.dart';

class ProfileState {
  const ProfileState({this.profile, this.isLoading = false, this.error});

  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  bool get hasRegion => profile?.hasRegion ?? false;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) =>
      ProfileState(
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  SupabaseClient get _db => Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response =
          await _db.from('profiles').select().eq('id', uid).maybeSingle();
      if (response != null) {
        state = state.copyWith(
          profile: UserProfile.fromJson(Map<String, dynamic>.from(response as Map)),
          isLoading: false,
        );
      } else {
        // New user — create a minimal profile row.
        final fresh = UserProfile(id: uid);
        await _db.from('profiles').insert(fresh.toJson());
        state = state.copyWith(profile: fresh, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final uid = _uid;
    if (uid == null) return;

    final updated = (state.profile ?? UserProfile(id: uid)).copyWith(
      displayName: displayName.isEmpty ? null : displayName,
    );
    state = state.copyWith(profile: updated);

    try {
      await _db.from('profiles').upsert(updated.toJson());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateRegion({
    required String country,
    required String city,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final updated = (state.profile ?? UserProfile(id: uid)).copyWith(
      regionCountry: country,
      regionCity: city,
    );

    // Optimistic update
    state = state.copyWith(profile: updated);

    try {
      await _db.from('profiles').upsert(updated.toJson());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (_) => ProfileNotifier(),
);
