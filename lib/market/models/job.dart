import 'package:flutter/material.dart';

enum JobStatus { available, active, completed, pending, Confirmed }

class Job {
  final int id;
  final String type;
  final String location;
  final String rate;
  final String category;
  final String customer;
  final String customerRating;
  final String detailedDescription;
  JobStatus status;

  Job({
    required this.id,
    required this.type,
    required this.location,
    required this.rate,
    required this.category,
    required this.customer,
    required this.customerRating,
    required this.detailedDescription,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: int.parse(json['id'].toString()),
      type: (json['service_name'] ?? 'Service').toString().toUpperCase(),
      location: json['address'] ?? 'No Address Provided',
      // Using 'amount' from your JSON
      rate: json['amount'] != null ? "₹${json['amount']}" : "₹0",
      category: json['service_name'] ?? 'General',
      // Using 'customer_name' from the PHP JOIN
      customer: json['customer_name'] ?? "User #${json['user_id']}",
      customerRating: '4.9',
      // Mapping 'notes' to detailedDescription
      detailedDescription: (json['notes'] != null && json['notes'].toString().trim().isNotEmpty)
          ? json['notes']
          : "No additional notes provided for this booking.",
      status: _parseStatus(json['status']),
    );
  }

  static JobStatus _parseStatus(String? status) {
    if (status == null) return JobStatus.available;
    String s = status.toLowerCase();
    if (s == 'pending') return JobStatus.available;
    if (s == 'confirmed') return JobStatus.active;
    if (s == 'completed') return JobStatus.completed;
    return JobStatus.available;
  }
}