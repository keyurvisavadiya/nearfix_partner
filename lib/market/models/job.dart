import 'package:flutter/foundation.dart';

// Ensure 'pending' is exactly here
enum JobStatus { available, active, completed, pending, Confirmed }

class Job {
  final int id;
  final int customerId;
  final String customerPhone;
  final String? customerImage;
  final String type;
  final String location;
  final String rate;
  final String category;
  final String customer;
  final String customerRating;
  final String detailedDescription;
  // --- ADD THESE TWO FIELDS ---
  final double latitude;
  final double longitude;
  JobStatus status;

  Job({
    required this.id,
    required this.customerId,
    required this.customerPhone,
    this.customerImage,
    required this.type,
    required this.location,
    required this.rate,
    required this.category,
    required this.customer,
    required this.customerRating,
    required this.detailedDescription,
    required this.status,
    // --- ADD TO CONSTRUCTOR ---
    required this.latitude,
    required this.longitude,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix";

    String? rawPath = json['profile_image']?.toString();
    String? finalImageUrl;

    if (rawPath != null && rawPath.isNotEmpty && rawPath != "null") {
      finalImageUrl = "$baseUrl/$rawPath";
    }

    return Job(
      id: int.tryParse(json['id'].toString()) ?? 0,
      customerId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      customerPhone: (json['phone'] ?? '').toString(),
      customerImage: finalImageUrl,
      type: (json['service_name'] ?? 'Service').toString().toUpperCase(),
      location: json['address'] ?? 'No Address',
      rate: "₹${json['amount'] ?? '0'}",
      category: json['service_name'] ?? 'General',
      customer: json['customer_name'] ?? "Customer",
      customerRating: '4.9',
      detailedDescription: json['notes'] ?? "No notes.",
      status: _parseStatus(json['status']?.toString()),
      // --- PARSE THE LAT/LNG FROM DATABASE ---
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  static JobStatus _parseStatus(String? status) {
    if (status == null || status.isEmpty) return JobStatus.available;
    String s = status.toLowerCase().trim();

    if (s == 'pending' || s == 'available') return JobStatus.pending;
    if (s == 'confirmed' || s == 'active' || s == 'Confirmed') return JobStatus.active;
    if (s == 'completed') return JobStatus.completed;

    return JobStatus.available;
  }
}