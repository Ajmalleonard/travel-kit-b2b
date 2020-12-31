import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models.dart';

class OperatorRepository {
  OperatorRepository(this._client);
  final ApiClient _client;

  Future<OperatorProfile?> me() async {
    final r = await _client.dio.get('/operators/me');
    if (r.statusCode == 404 || r.data == null) return null;
    final body = r.data;
    final data = (body is Map && body['data'] is Map)
        ? body['data'] as Map<String, dynamic>
        : (body as Map<String, dynamic>);
    return OperatorProfile.fromJson(data);
  }

  Future<OperatorProfile> upsert({
    required String businessName,
    String? bio,
    String? phone,
    String? region,
    String? licenseNumber,
  }) async {
    final r = await _client.dio.patch(
      '/operators/me',
      data: {
        'business_name': businessName,
        'business_description': ?bio,
        'phone': ?phone,
        'address': ?region,
        'business_registration_number': ?licenseNumber,
      },
    );
    final body = r.data as Map<String, dynamic>;
    return OperatorProfile.fromJson(
      (body['data'] ?? body) as Map<String, dynamic>,
    );
  }

  Future<List<Listing>> listings() async {
    final r = await _client.dio.get('/operators/listings');
    final body = r.data;
    final List items = (body is Map && body['data'] is List)
        ? body['data'] as List
        : (body is List ? body : const []);
    return items
        .whereType<Map>()
        .map((e) => Listing.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Booking>> bookings() async {
    final r = await _client.dio.get('/operators/bookings');
    final body = r.data;
    final List items = (body is Map && body['data'] is List)
        ? body['data'] as List
        : (body is List ? body : const []);
    return items
        .whereType<Map>()
        .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> confirmBooking(String id) =>
      _client.dio.post('/operators/bookings/$id/confirm');
}

class ListingsRepository {
  ListingsRepository(this._client);
  final ApiClient _client;

  Future<Listing> get(String id) async {
    final r = await _client.dio.get('/listings/$id');
    final body = r.data as Map<String, dynamic>;
    return Listing.fromJson((body['data'] ?? body) as Map<String, dynamic>);
  }

  Future<Listing> create({
    required String title,
    required String type,
    required double price,
    required String destinationId,
    String? description,
    int? capacity,
    int? durationHours,
  }) async {
    final details = switch (type) {
      'site' => {
        'site_details': {
          'max_capacity': ?capacity,
          'duration_hours': ?durationHours,
        },
      },
      'experience' => {
        'experience_details': {
          'max_participants': ?capacity,
          'duration_hours': ?durationHours,
        },
      },
      'trip' => {
        'trip_details': {
          'max_participants': ?capacity,
          'duration_days': durationHours == null
              ? null
              : (durationHours / 24).ceil().clamp(1, 365),
        },
      },
      'safari' => {'safari_details': <String, dynamic>{}},
      _ => <String, dynamic>{},
    };
    final r = await _client.dio.post(
      '/listings',
      data: {
        'title': title,
        'listing_type': type,
        'base_price': price,
        'destination_id': destinationId,
        'description': ?description,
        ...details,
      },
    );
    final body = r.data as Map<String, dynamic>;
    return Listing.fromJson((body['data'] ?? body) as Map<String, dynamic>);
  }

  Future<Listing> update(String id, Map<String, dynamic> patch) async {
    final data = Map<String, dynamic>.from(patch);
    if (data.containsKey('price')) {
      data['base_price'] = data.remove('price');
    }
    if (data.containsKey('is_active')) {
      data['status'] = data.remove('is_active') == true ? 'active' : 'draft';
    }
    final r = await _client.dio.patch('/listings/$id', data: data);
    final body = r.data as Map<String, dynamic>;
    return Listing.fromJson((body['data'] ?? body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.dio.delete('/listings/$id');

  Future<List<Review>> reviews(String id) async {
    final r = await _client.dio.get('/listings/$id/reviews');
    final body = r.data;
    final List items = (body is Map && body['data'] is List)
        ? body['data'] as List
        : (body is List ? body : const []);
    return items
        .whereType<Map>()
        .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> replyToReview({
    required String listingId,
    required String reviewId,
    required String reply,
  }) {
    return _client.dio.post(
      '/listings/$listingId/reviews/$reviewId/reply',
      data: {'reply': reply},
    );
  }
}

class AvailabilityRepository {
  AvailabilityRepository(this._client);
  final ApiClient _client;

  Future<List<AvailabilitySlot>> forListing(String listingId) async {
    final r = await _client.dio.get('/listings/$listingId/availability');
    final body = r.data;
    final List items = (body is Map && body['data'] is List)
        ? body['data'] as List
        : (body is List ? body : const []);
    return items
        .whereType<Map>()
        .map((e) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> add({
    required String listingId,
    required DateTime date,
    required int capacity,
  }) async {
    await _client.dio.post(
      '/listings/$listingId/availability',
      data: {
        'travel_date': date.toIso8601String().substring(0, 10),
        'capacity': capacity,
      },
    );
  }

  Future<void> remove({
    required String listingId,
    required String availId,
  }) async {
    await _client.dio.delete('/listings/$listingId/availability/$availId');
  }
}

class BookingsRepository {
  BookingsRepository(this._client);
  final ApiClient _client;

  Future<Booking> get(String id) async {
    final r = await _client.dio.get('/bookings/$id');
    final body = r.data as Map<String, dynamic>;
    return Booking.fromJson((body['data'] ?? body) as Map<String, dynamic>);
  }

  Future<void> cancel(String id) => _client.dio.post('/bookings/$id/cancel');
}

class DestinationsRepository {
  DestinationsRepository(this._client);
  final ApiClient _client;

  Future<List<Destination>> all() async {
    final r = await _client.dio.get('/destinations?limit=50');
    final body = r.data;
    final List items = (body is Map && body['data'] is List)
        ? body['data'] as List
        : (body is List ? body : const []);
    return items
        .whereType<Map>()
        .map((e) => Destination.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class AnalyticsRepository {
  AnalyticsRepository(this._client);
  final ApiClient _client;

  /// Best-effort analytics fetch. Server may scope this by operator from the
  /// auth token; if not, callers fall back to local aggregation.
  Future<Map<String, dynamic>?> summary() async {
    try {
      final r = await _client.dio.get('/operators/analytics');
      if (r.statusCode == 200 && r.data is Map) {
        final m = r.data as Map<String, dynamic>;
        return (m['data'] ?? m) as Map<String, dynamic>;
      }
    } catch (_) {}
    try {
      final r = await _client.dio.get('/admin/analytics');
      if (r.statusCode == 200 && r.data is Map) {
        final m = r.data as Map<String, dynamic>;
        return (m['data'] ?? m) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────

final operatorRepoProvider = Provider<OperatorRepository>(
  (ref) => OperatorRepository(ref.watch(apiClientProvider)),
);
final listingsRepoProvider = Provider<ListingsRepository>(
  (ref) => ListingsRepository(ref.watch(apiClientProvider)),
);
final availabilityRepoProvider = Provider<AvailabilityRepository>(
  (ref) => AvailabilityRepository(ref.watch(apiClientProvider)),
);
final bookingsRepoProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(apiClientProvider)),
);
final destinationsRepoProvider = Provider<DestinationsRepository>(
  (ref) => DestinationsRepository(ref.watch(apiClientProvider)),
);
final analyticsRepoProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepository(ref.watch(apiClientProvider)),
);

final myListingsProvider = FutureProvider<List<Listing>>((ref) async {
  try {
    return await ref.watch(operatorRepoProvider).listings();
  } catch (_) {
    return const [];
  }
});

final incomingBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  try {
    return await ref.watch(operatorRepoProvider).bookings();
  } catch (_) {
    return const [];
  }
});

final destinationsProvider = FutureProvider<List<Destination>>((ref) async {
  try {
    return await ref.watch(destinationsRepoProvider).all();
  } catch (_) {
    return const [];
  }
});

final operatorProfileProvider = FutureProvider<OperatorProfile?>((ref) async {
  try {
    return await ref.watch(operatorRepoProvider).me();
  } catch (_) {
    return null;
  }
});

final listingByIdProvider = FutureProvider.family<Listing?, String>((
  ref,
  id,
) async {
  try {
    return await ref.watch(listingsRepoProvider).get(id);
  } catch (_) {
    return null;
  }
});

final reviewsForListingProvider = FutureProvider.family<List<Review>, String>((
  ref,
  id,
) async {
  try {
    return await ref.watch(listingsRepoProvider).reviews(id);
  } catch (_) {
    return const [];
  }
});

final availabilityForListingProvider =
    FutureProvider.family<List<AvailabilitySlot>, String>((ref, id) async {
      try {
        return await ref.watch(availabilityRepoProvider).forListing(id);
      } catch (_) {
        return const [];
      }
    });

final bookingByIdProvider = FutureProvider.family<Booking?, String>((
  ref,
  id,
) async {
  try {
    return await ref.watch(bookingsRepoProvider).get(id);
  } catch (_) {
    return null;
  }
});

final analyticsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await ref.watch(analyticsRepoProvider).summary();
});
