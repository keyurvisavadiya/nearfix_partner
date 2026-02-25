import '../models/job.dart';

final List<Job> sampleJobs = [
  Job(
    id: 1,
    type: 'Plumbing Leak',
    location: 'Andheri East',
    rate: '₹500',
    category: 'Plumbing',
    customer: 'Amit S.',
    customerRating: '4.8',
    detailedDescription:
        'The kitchen faucet has a constant drip starting yesterday.',
    status: JobStatus.available,
  ),
  Job(
    id: 2,
    type: 'Mixer Install',
    location: 'Borivali',
    rate: '₹650',
    category: 'Plumbing',
    customer: 'Vikram V.',
    customerRating: '4.6',
    detailedDescription:
        'Need to install 3 new designer taps in the renovated kitchen area.',
    status: JobStatus.available,
  ),
  Job(
    id: 3,
    type: 'Switch Fix',
    location: 'Powai',
    rate: '₹300',
    category: 'Electrical',
    customer: 'Neha K.',
    customerRating: '4.9',
    detailedDescription: 'Bedroom switches are loose and sparking.',
    status: JobStatus.active,
  ),
  Job(
    id: 4,
    type: 'Bathroom Overhaul',
    location: 'Juhu',
    rate: '₹850',
    category: 'Plumbing',
    customer: 'Priya M.',
    customerRating: '4.7',
    detailedDescription:
        'Multiple leakages in the bathroom pipes need urgent attention.',
    status: JobStatus.completed,
  ),
];
