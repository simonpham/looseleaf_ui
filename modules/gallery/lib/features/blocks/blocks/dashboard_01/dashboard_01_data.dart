import 'package:flutter/foundation.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The day the visitor ranges count back from.
final DateTime dashboard01ReferenceDay = DateTime.utc(2026, 9, 25);

/// Visitors per day, desktop and mobile.
const List<ChartRow> dashboard01Visitors = [
  {'date': '2026-06-27', 'desktop': 143, 'mobile': 255},
  {'date': '2026-06-28', 'desktop': 171, 'mobile': 259},
  {'date': '2026-06-29', 'desktop': 256, 'mobile': 185},
  {'date': '2026-06-30', 'desktop': 270, 'mobile': 154},
  {'date': '2026-07-01', 'desktop': 323, 'mobile': 165},
  {'date': '2026-07-02', 'desktop': 243, 'mobile': 220},
  {'date': '2026-07-03', 'desktop': 359, 'mobile': 182},
  {'date': '2026-07-04', 'desktop': 175, 'mobile': 325},
  {'date': '2026-07-05', 'desktop': 174, 'mobile': 298},
  {'date': '2026-07-06', 'desktop': 340, 'mobile': 197},
  {'date': '2026-07-07', 'desktop': 244, 'mobile': 191},
  {'date': '2026-07-08', 'desktop': 341, 'mobile': 189},
  {'date': '2026-07-09', 'desktop': 301, 'mobile': 210},
  {'date': '2026-07-10', 'desktop': 280, 'mobile': 180},
  {'date': '2026-07-11', 'desktop': 202, 'mobile': 253},
  {'date': '2026-07-12', 'desktop': 134, 'mobile': 285},
  {'date': '2026-07-13', 'desktop': 250, 'mobile': 196},
  {'date': '2026-07-14', 'desktop': 301, 'mobile': 246},
  {'date': '2026-07-15', 'desktop': 401, 'mobile': 169},
  {'date': '2026-07-16', 'desktop': 250, 'mobile': 252},
  {'date': '2026-07-17', 'desktop': 262, 'mobile': 214},
  {'date': '2026-07-18', 'desktop': 144, 'mobile': 305},
  {'date': '2026-07-19', 'desktop': 135, 'mobile': 288},
  {'date': '2026-07-20', 'desktop': 260, 'mobile': 223},
  {'date': '2026-07-21', 'desktop': 340, 'mobile': 174},
  {'date': '2026-07-22', 'desktop': 291, 'mobile': 210},
  {'date': '2026-07-23', 'desktop': 335, 'mobile': 247},
  {'date': '2026-07-24', 'desktop': 377, 'mobile': 251},
  {'date': '2026-07-25', 'desktop': 165, 'mobile': 245},
  {'date': '2026-07-26', 'desktop': 190, 'mobile': 321},
  {'date': '2026-07-27', 'desktop': 354, 'mobile': 223},
  {'date': '2026-07-28', 'desktop': 345, 'mobile': 172},
  {'date': '2026-07-29', 'desktop': 347, 'mobile': 216},
  {'date': '2026-07-30', 'desktop': 356, 'mobile': 259},
  {'date': '2026-07-31', 'desktop': 279, 'mobile': 249},
  {'date': '2026-08-01', 'desktop': 202, 'mobile': 358},
  {'date': '2026-08-02', 'desktop': 214, 'mobile': 386},
  {'date': '2026-08-03', 'desktop': 269, 'mobile': 263},
  {'date': '2026-08-04', 'desktop': 423, 'mobile': 201},
  {'date': '2026-08-05', 'desktop': 323, 'mobile': 264},
  {'date': '2026-08-06', 'desktop': 427, 'mobile': 288},
  {'date': '2026-08-07', 'desktop': 277, 'mobile': 279},
  {'date': '2026-08-08', 'desktop': 195, 'mobile': 321},
  {'date': '2026-08-09', 'desktop': 169, 'mobile': 367},
  {'date': '2026-08-10', 'desktop': 340, 'mobile': 207},
  {'date': '2026-08-11', 'desktop': 297, 'mobile': 262},
  {'date': '2026-08-12', 'desktop': 452, 'mobile': 273},
  {'date': '2026-08-13', 'desktop': 303, 'mobile': 183},
  {'date': '2026-08-14', 'desktop': 370, 'mobile': 244},
  {'date': '2026-08-15', 'desktop': 223, 'mobile': 347},
  {'date': '2026-08-16', 'desktop': 177, 'mobile': 422},
  {'date': '2026-08-17', 'desktop': 453, 'mobile': 214},
  {'date': '2026-08-18', 'desktop': 341, 'mobile': 289},
  {'date': '2026-08-19', 'desktop': 288, 'mobile': 267},
  {'date': '2026-08-20', 'desktop': 374, 'mobile': 248},
  {'date': '2026-08-21', 'desktop': 328, 'mobile': 191},
  {'date': '2026-08-22', 'desktop': 188, 'mobile': 268},
  {'date': '2026-08-23', 'desktop': 160, 'mobile': 309},
  {'date': '2026-08-24', 'desktop': 415, 'mobile': 251},
  {'date': '2026-08-25', 'desktop': 488, 'mobile': 196},
  {'date': '2026-08-26', 'desktop': 478, 'mobile': 240},
  {'date': '2026-08-27', 'desktop': 462, 'mobile': 227},
  {'date': '2026-08-28', 'desktop': 324, 'mobile': 215},
  {'date': '2026-08-29', 'desktop': 168, 'mobile': 369},
  {'date': '2026-08-30', 'desktop': 166, 'mobile': 423},
  {'date': '2026-08-31', 'desktop': 327, 'mobile': 254},
  {'date': '2026-09-01', 'desktop': 305, 'mobile': 261},
  {'date': '2026-09-02', 'desktop': 468, 'mobile': 305},
  {'date': '2026-09-03', 'desktop': 446, 'mobile': 232},
  {'date': '2026-09-04', 'desktop': 427, 'mobile': 328},
  {'date': '2026-09-05', 'desktop': 172, 'mobile': 280},
  {'date': '2026-09-06', 'desktop': 239, 'mobile': 375},
  {'date': '2026-09-07', 'desktop': 324, 'mobile': 272},
  {'date': '2026-09-08', 'desktop': 497, 'mobile': 215},
  {'date': '2026-09-09', 'desktop': 423, 'mobile': 220},
  {'date': '2026-09-10', 'desktop': 354, 'mobile': 280},
  {'date': '2026-09-11', 'desktop': 423, 'mobile': 309},
  {'date': '2026-09-12', 'desktop': 268, 'mobile': 387},
  {'date': '2026-09-13', 'desktop': 188, 'mobile': 435},
  {'date': '2026-09-14', 'desktop': 499, 'mobile': 273},
  {'date': '2026-09-15', 'desktop': 491, 'mobile': 346},
  {'date': '2026-09-16', 'desktop': 528, 'mobile': 276},
  {'date': '2026-09-17', 'desktop': 341, 'mobile': 352},
  {'date': '2026-09-18', 'desktop': 412, 'mobile': 243},
  {'date': '2026-09-19', 'desktop': 181, 'mobile': 303},
  {'date': '2026-09-20', 'desktop': 182, 'mobile': 455},
  {'date': '2026-09-21', 'desktop': 384, 'mobile': 319},
  {'date': '2026-09-22', 'desktop': 351, 'mobile': 231},
  {'date': '2026-09-23', 'desktop': 393, 'mobile': 315},
  {'date': '2026-09-24', 'desktop': 403, 'mobile': 298},
  {'date': '2026-09-25', 'desktop': 498, 'mobile': 265},
];

/// Visitors per month, January to June.
const List<ChartRow> dashboard01Monthly = [
  {'month': 'January', 'desktop': 186, 'mobile': 80},
  {'month': 'February', 'desktop': 305, 'mobile': 200},
  {'month': 'March', 'desktop': 237, 'mobile': 120},
  {'month': 'April', 'desktop': 73, 'mobile': 190},
  {'month': 'May', 'desktop': 209, 'mobile': 130},
  {'month': 'June', 'desktop': 214, 'mobile': 140},
];

const ChartConfig dashboard01ChartConfig = {
  'desktop': ChartSeriesConfig(label: 'Desktop'),
  'mobile': ChartSeriesConfig(label: 'Mobile'),
};

/// Where a section of the proposal stands.
enum Dashboard01Status {
  done('Done', 'circle-check'),
  inProcess('In process', 'loader'),
  notStarted('Not started', 'circle');

  const Dashboard01Status(this.label, this.icon);

  final String label;
  final String icon;
}

/// The reviewer placeholder of a section nobody reviews yet.
const String dashboard01Unassigned = 'Assign reviewer';

const List<String> dashboard01SectionTypes = [
  'Cover page',
  'Table of contents',
  'Narrative',
  'Technical content',
  'Visual',
  'Legal',
];

const List<String> dashboard01Reviewers = [
  'Eddie Lake',
  'Jamik Tashpulatov',
  'Emily Whalen',
];

/// One section of the proposal, a row of the table.
@immutable
class Dashboard01Section {
  const Dashboard01Section({
    required this.id,
    required this.header,
    required this.type,
    required this.status,
    required this.target,
    required this.limit,
    required this.reviewer,
  });

  final int id;
  final String header;
  final String type;
  final Dashboard01Status status;
  final String target;
  final String limit;
  final String reviewer;

  Dashboard01Section copyWith({
    int? id,
    String? header,
    String? type,
    Dashboard01Status? status,
    String? target,
    String? limit,
    String? reviewer,
  }) => Dashboard01Section(
    id: id ?? this.id,
    header: header ?? this.header,
    type: type ?? this.type,
    status: status ?? this.status,
    target: target ?? this.target,
    limit: limit ?? this.limit,
    reviewer: reviewer ?? this.reviewer,
  );
}

const List<Dashboard01Section> dashboard01Sections = [
  Dashboard01Section(
    id: 1,
    header: 'Cover page',
    type: 'Cover page',
    status: Dashboard01Status.inProcess,
    target: '18',
    limit: '5',
    reviewer: 'Eddie Lake',
  ),
  Dashboard01Section(
    id: 2,
    header: 'Table of contents',
    type: 'Table of contents',
    status: Dashboard01Status.done,
    target: '29',
    limit: '24',
    reviewer: 'Eddie Lake',
  ),
  Dashboard01Section(
    id: 3,
    header: 'Executive summary',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '10',
    limit: '13',
    reviewer: 'Eddie Lake',
  ),
  Dashboard01Section(
    id: 4,
    header: 'Technical approach',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '27',
    limit: '23',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 5,
    header: 'Design',
    type: 'Narrative',
    status: Dashboard01Status.inProcess,
    target: '2',
    limit: '16',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 6,
    header: 'Capabilities',
    type: 'Narrative',
    status: Dashboard01Status.inProcess,
    target: '20',
    limit: '8',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 7,
    header: 'Integration with existing systems',
    type: 'Narrative',
    status: Dashboard01Status.inProcess,
    target: '19',
    limit: '21',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 8,
    header: 'Innovation and Advantages',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '25',
    limit: '26',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 9,
    header: 'Overview of EMR\'s Innovative Solutions',
    type: 'Technical content',
    status: Dashboard01Status.done,
    target: '7',
    limit: '23',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 10,
    header: 'Advanced Algorithms and Machine Learning',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '30',
    limit: '28',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 11,
    header: 'Adaptive Communication Protocols',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '9',
    limit: '31',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 12,
    header: 'Advantages Over Current Technologies',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '12',
    limit: '0',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 13,
    header: 'Past Performance',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '22',
    limit: '33',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 14,
    header: 'Customer Feedback and Satisfaction Levels',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '15',
    limit: '34',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 15,
    header: 'Implementation Challenges and Solutions',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '3',
    limit: '35',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 16,
    header: 'Security Measures and Data Protection Policies',
    type: 'Narrative',
    status: Dashboard01Status.inProcess,
    target: '6',
    limit: '36',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 17,
    header: 'Scalability and Future Proofing',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '4',
    limit: '37',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 18,
    header: 'Cost-Benefit Analysis',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '14',
    limit: '38',
    reviewer: 'Eddie Lake',
  ),
  Dashboard01Section(
    id: 19,
    header: 'User Training and Onboarding Experience',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '17',
    limit: '39',
    reviewer: 'Eddie Lake',
  ),
  Dashboard01Section(
    id: 20,
    header: 'Future Development Roadmap',
    type: 'Narrative',
    status: Dashboard01Status.done,
    target: '11',
    limit: '40',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 21,
    header: 'System Architecture Overview',
    type: 'Technical content',
    status: Dashboard01Status.inProcess,
    target: '24',
    limit: '18',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 22,
    header: 'Risk Management Plan',
    type: 'Narrative',
    status: Dashboard01Status.notStarted,
    target: '15',
    limit: '22',
    reviewer: dashboard01Unassigned,
  ),
  Dashboard01Section(
    id: 23,
    header: 'Compliance Documentation',
    type: 'Legal',
    status: Dashboard01Status.notStarted,
    target: '31',
    limit: '27',
    reviewer: 'Emily Whalen',
  ),
  Dashboard01Section(
    id: 24,
    header: 'API Documentation',
    type: 'Technical content',
    status: Dashboard01Status.done,
    target: '8',
    limit: '12',
    reviewer: 'Jamik Tashpulatov',
  ),
  Dashboard01Section(
    id: 25,
    header: 'User Interface Mockups',
    type: 'Visual',
    status: Dashboard01Status.inProcess,
    target: '19',
    limit: '25',
    reviewer: 'Eddie Lake',
  ),
];

/// The signed-in person's name.
const String dashboard01UserName = 'Jo Delacroix';

/// The signed-in person's email.
const String dashboard01UserEmail = 'jo@inkwell.example';
