import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maternal_infant_care/data/models/fertility_profile_model.dart';

class FertilityProfileRepository {
  FertilityProfileRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> upsertProfile(FertilityProfileModel profile) async {
    await _client.from('fertility_profiles').upsert(profile.toMap());
  }

  Future<FertilityProfileModel?> fetchProfile(String userId) async {
    final data = await _client
        .from('fertility_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return FertilityProfileModel.fromMap(data);
  }
}
