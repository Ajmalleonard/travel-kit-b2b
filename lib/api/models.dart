class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });
  final String id;
  final String email;
  final String fullName;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    fullName: (j['full_name'] ?? j['fullName'] ?? '').toString(),
    role: j['role']?.toString() ?? 'operator',
  );
}

class OperatorProfile {
  OperatorProfile({
    required this.id,
    required this.businessName,
    required this.status,
    this.bio,
    this.phone,
    this.region,
    this.licenseNumber,
  });
  final String id;
  final String businessName;
  final String status;
  final String? bio;
  final String? phone;
  final String? region;
  final String? licenseNumber;

  factory OperatorProfile.fromJson(Map<String, dynamic> j) => OperatorProfile(
    id: (j['id'] ?? j['user_id'] ?? '').toString(),
    businessName: (j['business_name'] ?? j['businessName'] ?? '').toString(),
    status: (j['verification_status'] ?? j['status'] ?? 'pending').toString(),
    bio: (j['bio'] ?? j['business_description'])?.toString(),
    phone: j['phone']?.toString(),
    region: (j['region'] ?? j['address'])?.toString(),
    licenseNumber:
        (j['license_number'] ??
                j['licenseNumber'] ??
                j['business_registration_number'])
            ?.toString(),
  );
}

class Destination {
  Destination({required this.id, required this.name});
  final String id;
  final String name;
  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
  );
}

class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.isActive,
    this.destinationName,
    this.heroImageUrl,
    this.description,
    this.capacity,
    this.durationHours,
  });
  final String id;
  final String title;
  final String type;
  final double price;
  final bool isActive;
  final String? destinationName;
  final String? heroImageUrl;
  final String? description;
  final int? capacity;
  final int? durationHours;

  factory Listing.fromJson(Map<String, dynamic> j) {
    final details = j['details'] is Map
        ? Map<String, dynamic>.from(j['details'] as Map)
        : const <String, dynamic>{};
    final images = j['image_urls'] is List ? j['image_urls'] as List : const [];
    final status = (j['status'] ?? '').toString();
    return Listing(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      type: (j['type'] ?? j['listing_type'] ?? 'experience').toString(),
      price: (j['price'] is num)
          ? (j['price'] as num).toDouble()
          : double.tryParse((j['price'] ?? j['base_price'] ?? '').toString()) ??
                0,
      isActive:
          j['is_active'] == true || j['isActive'] == true || status == 'active',
      destinationName: (j['destination_name'] ?? j['destinationName'])
          ?.toString(),
      heroImageUrl:
          (j['hero_image_url'] ??
                  j['heroImageUrl'] ??
                  (images.isNotEmpty ? images.first : null))
              ?.toString(),
      description: j['description']?.toString(),
      capacity: _intFrom(
        j['capacity'] ??
            j['max_capacity'] ??
            details['max_capacity'] ??
            details['max_participants'],
      ),
      durationHours: _intFrom(
        j['duration_hours'] ??
            details['duration_hours'] ??
            (details['duration_days'] is num
                ? (details['duration_days'] as num) * 24
                : null),
      ),
    );
  }
}

class Review {
  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.author,
    required this.createdAt,
    this.operatorReply,
  });
  final String id;
  final int rating;
  final String comment;
  final String author;
  final DateTime createdAt;
  final String? operatorReply;

  factory Review.fromJson(Map<String, dynamic> j) => Review(
    id: j['id']?.toString() ?? '',
    rating: (j['rating'] is num) ? (j['rating'] as num).toInt() : 0,
    comment: (j['comment'] ?? '').toString(),
    author: (j['author_name'] ?? j['author'] ?? 'Guest').toString(),
    createdAt:
        DateTime.tryParse(
          (j['created_at'] ?? j['createdAt'] ?? '').toString(),
        ) ??
        DateTime.now(),
    operatorReply: (j['operator_reply'] ?? j['operatorReply'])?.toString(),
  );
}

class AvailabilitySlot {
  AvailabilitySlot({
    required this.id,
    required this.date,
    required this.capacity,
    this.remaining,
  });
  final String id;
  final DateTime date;
  final int capacity;
  final int? remaining;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> j) => AvailabilitySlot(
    id: j['id']?.toString() ?? '',
    date:
        DateTime.tryParse((j['date'] ?? j['travel_date'] ?? '').toString()) ??
        DateTime.now(),
    capacity: (j['capacity'] is num) ? (j['capacity'] as num).toInt() : 0,
    remaining: _intFrom(j['remaining'] ?? j['available_spots']),
  );
}

class Booking {
  Booking({
    required this.id,
    required this.listingTitle,
    required this.travelerName,
    required this.travelDate,
    required this.guests,
    required this.total,
    required this.status,
  });
  final String id;
  final String listingTitle;
  final String travelerName;
  final DateTime travelDate;
  final int guests;
  final double total;
  final String status;

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id']?.toString() ?? '',
    listingTitle: (j['listing_title'] ?? j['listingTitle'] ?? 'Listing')
        .toString(),
    travelerName:
        (j['traveler_name'] ?? j['travelerName'] ?? j['user_name'] ?? 'Guest')
            .toString(),
    travelDate:
        DateTime.tryParse(
          (j['travel_date'] ??
                  j['travelDate'] ??
                  j['created_at'] ??
                  j['createdAt'] ??
                  '')
              .toString(),
        ) ??
        DateTime.now(),
    guests: (j['guests'] is num) ? (j['guests'] as num).toInt() : 1,
    total: (j['total_amount'] is num)
        ? (j['total_amount'] as num).toDouble()
        : double.tryParse(j['total_amount']?.toString() ?? '') ?? 0,
    status: (j['status'] ?? 'pending').toString(),
  );
}

int? _intFrom(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
