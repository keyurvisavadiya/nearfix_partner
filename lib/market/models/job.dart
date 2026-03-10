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
  JobStatus status;

  Job({
    required this.id, required this.customerId, required this.customerPhone,
    this.customerImage, required this.type, required this.location,
    required this.rate, required this.category, required this.customer,
    required this.customerRating, required this.detailedDescription, required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // 1. Ensure this URL is your CURRENT active ngrok link
    // 2. Do NOT put a slash at the very end if you're adding it manually below
    const String baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix";

    String? rawPath = json['profile_image']?.toString();
    String? finalImageUrl;

    if (rawPath != null && rawPath.isNotEmpty && rawPath != "null") {
      // Logic: If rawPath starts with 'uploads', just add a single slash
      finalImageUrl = "$baseUrl/$rawPath";
    }

    return Job(
      id: int.tryParse(json['id'].toString()) ?? 0,
      customerId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      customerPhone: (json['phone'] ?? '').toString(),
      customerImage: finalImageUrl, // Using the cleaned URL
      type: (json['service_name'] ?? 'Service').toString().toUpperCase(),
      location: json['address'] ?? 'No Address',
      rate: "₹${json['amount'] ?? '0'}",
      category: json['service_name'] ?? 'General',
      customer: json['customer_name'] ?? "Customer",
      customerRating: '4.9',
      detailedDescription: json['notes'] ?? "No notes.",
      status: _parseStatus(json['status']?.toString()),
    );
  }

  static JobStatus _parseStatus(String? status) {
    if (status == null || status.isEmpty) return JobStatus.available;
    String s = status.toLowerCase().trim();

    // Mapping logic
    if (s == 'pending' || s == 'available') return JobStatus.pending;
    if (s == 'confirmed' || s == 'active') return JobStatus.active;
    if (s == 'completed') return JobStatus.completed;

    return JobStatus.available;
  }
}