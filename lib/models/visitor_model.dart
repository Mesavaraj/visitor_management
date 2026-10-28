class VisitorModel {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  const VisitorModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString(),
      visitorType: json['visitor_type']?.toString() ?? 'Other',
      project: json['project']?.toString() ?? 'Project A',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Registered',
      createdAt: json['created_at']?.toString() ?? '',
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }

  // Fields sent when creating a visitor.
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': 'Registered',
    };
  }

  // Fields sent when updating visitor information.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
    };
  }

  VisitorModel copyWith({
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    String? checkInTime,
    String? checkOutTime,
  }) {
    return VisitorModel(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }
}

// class VisitorModel {
//   final String id;
//   final String name;
//   final String mobile;
//   final String? email;
//   final String visitorType;
//   final String project;
//   final String purpose;
//   final String status;
//   final String createdAt;
//   final String? checkInTime;
//   final String? checkOutTime;
//
//   const VisitorModel({
//     required this.id,
//     required this.name,
//     required this.mobile,
//     this.email,
//     required this.visitorType,
//     required this.project,
//     required this.purpose,
//     required this.status,
//     required this.createdAt,
//     this.checkInTime,
//     this.checkOutTime,
//   });
//
//   // Convert API JSON into a Dart model.
//   factory VisitorModel.fromJson(Map<String, dynamic> json) {
//     return VisitorModel(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       mobile: json['mobile']?.toString() ?? '',
//       email: json['email']?.toString(),
//       visitorType: json['visitor_type']?.toString() ?? 'Other',
//       project: json['project']?.toString() ?? '',
//       purpose: json['purpose']?.toString() ?? '',
//       status: json['status']?.toString() ?? 'Registered',
//       createdAt: json['created_at']?.toString() ?? '',
//       checkInTime: json['check_in_time']?.toString(),
//       checkOutTime: json['check_out_time']?.toString(),
//     );
//   }
//
//   // Convert the model into JSON for API requests.
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'mobile': mobile,
//       'email': email,
//       'visitor_type': visitorType,
//       'project': project,
//       'purpose': purpose,
//       'status': status,
//       'created_at': createdAt,
//       'check_in_time': checkInTime,
//       'check_out_time': checkOutTime,
//     };
//   }
//
//   // Create a copy with selected fields updated.
//   VisitorModel copyWith({
//     String? name,
//     String? mobile,
//     String? email,
//     String? visitorType,
//     String? project,
//     String? purpose,
//     String? status,
//     String? checkInTime,
//     String? checkOutTime,
//   }) {
//     return VisitorModel(
//       id: id,
//       name: name ?? this.name,
//       mobile: mobile ?? this.mobile,
//       email: email ?? this.email,
//       visitorType: visitorType ?? this.visitorType,
//       project: project ?? this.project,
//       purpose: purpose ?? this.purpose,
//       status: status ?? this.status,
//       createdAt: createdAt,
//       checkInTime: checkInTime ?? this.checkInTime,
//       checkOutTime: checkOutTime ?? this.checkOutTime,
//     );
//   }
// }
