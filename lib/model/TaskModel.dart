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
  final String gin;
  final String grn;
  final String id;
  final String type;
  final String descriptiong;
   final String taskNo;

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
    required this.gin,
    required this.grn,
    required this.id,
    required this.type,
    required this.descriptiong,
    required this.taskNo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      solution: json['solution'] ?? '',
      technicianSolution: json['technicianSolution'] ?? [],
      csr_id: json['csr_id'] ?? 0,
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      internal: json['internal'] ?? false,
      customer: json['customer'] ?? {},
      service_area: json['service_area'] ?? '',
      service_type: json['service_type'] ?? '',
      assigned_to: json['assigned_to'] ?? {},
      owner: json['owner'] ?? {},
      time_spent: json['time_spent'] ?? '',
      contract: json['contract'] ?? {},
      priority: json['priority'] ?? '',
      complexity: json['complexity'] ?? '',
      team: json['team'] ?? [],
      reopencsr: json['reopencsr'] ?? false,
      phone: json['phone'] ?? '',
      cts: json['cts'] ?? 0,
      uts: json['uts'] ?? 0,
      contactname: json['contactname'] ?? '',
      address: json['address'] ?? '',
      created_on: json['created_on'] ?? '',
      parts: json['parts'] ?? [],
      gin: json['gin'] ?? '',
      grn: json['grn'] ?? '',
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      descriptiong: json['descriptiong'] ?? '',
      taskNo: json['taskNo'] ?? '',
    );
  }
}

Future<Map<String, List<TaskModel>>> getNoteList() async {
  await Future.delayed(const Duration(seconds: 2));

  // Dummy data for testing
  List<TaskModel> ginList = [
    TaskModel(
      solution: 'Gin Task 1',
      technicianSolution: [],
      csr_id: 1,
      description: 'GIN Task 1 description',
      status: 'Pending',
      internal: true,
      customer: {},
      service_area: 'Area 1',
      service_type: 'Type 1',
      assigned_to: {},
      owner: {},
      time_spent: '1 hour',
      contract: {},
      priority: 'High',
      complexity: 'Simple',
      team: [],
      reopencsr: false,
      phone: '1234567890',
      cts: 123,
      uts: 456,
      contactname: 'John Doe',
      address: 'Address 1',
      created_on: '2022-01-01',
      parts: [],
      gin: 'GIN-001',
      grn: '',
      type: 'GIN',
      descriptiong: '', 
      id: '1', 
      taskNo: '1',
    ),
    TaskModel(
      solution: 'Gin Task 2',
      technicianSolution: [],
      csr_id: 2,
      description: 'GIN Task 2 description',
      status: 'Completed',
      internal: false,
      customer: {},
      service_area: 'Area 2',
      service_type: 'Type 2',
      assigned_to: {},
      owner: {},
      time_spent: '2 hours',
      contract: {},
      priority: 'Medium',
      complexity: 'Moderate',
      team: [],
      reopencsr: false,
      phone: '0987654321',
      cts: 789,
      uts: 101,
      contactname: 'Jane Smith',
      address: 'Address 2',
      created_on: '2022-01-02',
      parts: [],
      gin: 'GIN-002',
      grn: '',
      type: 'GIN',
      descriptiong: '',
      id: '2', 
      taskNo: '2',
    ),
  ];

  List<TaskModel> grnList = [
    TaskModel(
      solution: 'Grn Task 1',
      technicianSolution: [],
      csr_id: 3,
      description: 'GRN Task 1 description',
      status: 'Pending',
      internal: true,
      customer: {},
      service_area: 'Area 3',
      service_type: 'Type 3',
      assigned_to: {},
      owner: {},
      time_spent: '3 hours',
      contract: {},
      priority: 'Low',
      complexity: 'High',
      team: [],
      reopencsr: false,
      phone: '1112223333',
      cts: 234,
      uts: 567,
      contactname: 'Robert Brown',
      address: 'Address 3',
      created_on: '2022-02-01',
      parts: [],
      gin: '',
      grn: 'GRN-001',
      type: 'GRN',
      descriptiong: '',
      id: '3', 
      taskNo: '3',
    ),
    TaskModel(
      solution: 'Grn Task 2',
      technicianSolution: [],
      csr_id: 4,
      description: 'GRN Task 2 description',
      status: 'Completed',
      internal: false,
      customer: {},
      service_area: 'Area 4',
      service_type: 'Type 4',
      assigned_to: {},
      owner: {},
      time_spent: '1 hour',
      contract: {},
      priority: 'High',
      complexity: 'Simple',
      team: [],
      reopencsr: false,
      phone: '5554443333',
      cts: 678,
      uts: 910,
      contactname: 'Lucy Green',
      address: 'Address 4',
      created_on: '2022-02-02',
      parts: [],
      gin: '',
      grn: 'GRN-002',
      type: 'GRN',
      descriptiong: '',
      id: '4', 
      taskNo: '4',
    ),
  ];

  return {
    'GIN': ginList,
    'GRN': grnList,
  };
}
