class TaskModel {
  String solution;
  List technicianSolution;
  int csr_id;
  String description;
  String status;
  bool internal;
  Map<String, dynamic> customer;
  String service_area;
  String service_type;
  Map<String, dynamic> assigned_to;
  Map<String, dynamic> owner;
  String time_spent;
  Map<String, dynamic> contract;
  String priority;
  String complexity;
  List team;
  bool reopencsr;
  String phone;
  int cts;
  int uts;
  String contactname;
  String address;
  String created_on;
  List parts;

  TaskModel({
    required this.solution,
    required this.technicianSolution,
    required this.csr_id,
    required this.description,
    required this.status,
    required this.internal,
    required this.customer,
    required this.service_area,
    required this.service_type,
    required this.assigned_to,
    required this.owner,
    required this.time_spent,
    required this.contract,
    required this.priority,
    required this.complexity,
    required this.team,
    required this.reopencsr,
    required this.phone,
    required this.cts,
    required this.uts,
    required this.contactname,
    required this.address,
    required this.created_on,
    required this.parts,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      solution: json['solution'] != null ? json['solution'] : '' as String,
      technicianSolution: json['technicianSolution'] as List,
      csr_id: json['csr_id'] as int,
      description:
          json['description'] != null ? json['description'] : '' as String,
      status: json['status'] != null ? json['status'] : '' as String,
      internal: json['internal'] as bool,
      customer: json['customer'] as Map<String, dynamic>,
      service_area:
          json['service_area'] != null ? json['service_area'] : '' as String,
      service_type:
          json['service_type'] != null ? json['service_type'] : '' as String,
      assigned_to: json['assigned_to'] as Map<String, dynamic>,
      owner: json['owner'] as Map<String, dynamic>,
      time_spent:
          json['time_spent'] != null ? json['time_spent'] : '' as String,
      contract: json['contract'] as Map<String, dynamic>,
      priority: json['priority'] != null ? json['priority'] : '' as String,
      complexity:
          json['complexity'] != null ? json['complexity'] : '' as String,
      team: json['team'] as List,
      reopencsr: json['reopencsr'] as bool,
      phone: json['phon'] != null ? json['phon'] : '' as String,
      cts: json['cts'] != null ? json['cts'] : 0 as int,
      uts: json['uts'] != null ? json['uts'] : 0 as int,
      contactname:
          json['contactname'] != null ? json['contactname'] : '' as String,
      address: json['address'] != null ? json['address'] : '' as String,
      created_on:
          json['created_on'] != null ? json['created_on'] : '' as String,
      parts: json['parts'],
    );
  }
}
