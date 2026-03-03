import '../models/job.dart';

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

  // Convert JSON from Database to Job Object
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: int.parse(json['id'].toString()),
      type: json['type'] ?? 'Service',
      location: json['location'] ?? 'Location not provided',
      // We wrap this in ₹ if it's not already there
      rate: json['rate'].toString().contains('₹')
          ? json['rate']
          : "₹${json['rate']}",
      category: json['category'] ?? 'General',
      // Defaulting to 'Customer' since your PHP uses a placeholder for now
      customer: json['customer'] ?? 'Customer',
      customerRating: json['rating'] ?? '4.9',
      // --- THIS IS THE FIX ---
      // It looks for 'notes' from your PHP and assigns it to detailedDescription
      detailedDescription: json['notes'] ?? 'No additional notes provided.',
      status: _parseStatus(json['status']),
    );
  }

  static JobStatus _parseStatus(String status) {
    return JobStatus.values.firstWhere(
          (e) => e.toString().split('.').last == status,
      orElse: () => JobStatus.available,
    );
  }
}