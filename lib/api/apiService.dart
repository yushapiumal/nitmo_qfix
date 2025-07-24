import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:qfix_nitmo_new/model/TaskModel.dart';

class TenantAPI {
  final LocalStorage storage = LocalStorage('qfix');

  Future apiSet() async {
    return "https://" +
        storage.getItem('tenant') +
        ".go.digitable.io/qfix/api/v1/";

    // return "http://" + storage.getItem('tenant') + ".go.rype3.loc/qfix/api/v1/";
  }
}

class APIService {
  final LocalStorage storage = LocalStorage('qfix');
  TenantAPI api = TenantAPI();

  Future checkTenant(tenant) async {
    try {
      String url =
          'https://' + tenant + '.go.digitable.io/qfix/api/v1/getservicetype';
      // 'http://' + tenant + '.go.rype3.loc/qfix/api/v1/getservicetype';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      );
      var values = json.decode(response.body);

      if (values['status'] || !values['status']) {
        storage.setItem('tenant', tenant);
        return true;
      }
    } catch (e) {
      showToast('There are no tenant account found');
      return false;
    }
  }

  Future login(email, password) async {
    String url = await api.apiSet() + 'login';
    print('TOKEN======>   ' + storage.getItem('messageToken'));
    final response = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          'username': email,
          'password': password,
          'did': storage.getItem('messageToken'),
          'reg_id': '1',
        },
        encoding: Encoding.getByName("utf-8"));
    var values = json.decode(response.body);

    if (values['status']) {
      storage.setItem('userId', values['data']['user_id'].toString());
      storage.setItem('role', values['data']['role'].toString());
      storage.setItem('token', values['data']['token'].toString());
      storage.setItem('sId', values['data']['staff']['s_id'].toString());
      storage.setItem('name', values['data']['staff']['name'].toString());
      storage.setItem('contact', values['data']['staff']['contact'].toString());
      storage.setItem(
          'designation', values['data']['staff']['designation'].toString());
      storage.setItem(
          'calling_name', values['data']['staff']['calling_name'].toString());
    } else {
      print('login else');
      showToast(values['message']);
    }
    return values['status'];
  }

  Future checkInCheckOut(data) async {
    String url = await api.apiSet() + 'time';

    final response = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    // print(response);
    var values = json.decode(response.body);
    // print(values);
    showToast(values['message']);
    return true;
  }

  Future getProjects(fromType) async {
    String url = await api.apiSet() + 'getprojects?sid=' + fromType;
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
    }
    return [];
  }

  Future getCustomersProjects(customerId) async {
    String url = await api.apiSet() + 'customer-projects';
    final response = await http.get(
      Uri.parse(url).replace(queryParameters: {'customer': customerId}),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
    }
    return [];
  }

  Future getProjectTask(contractSerial) async {
    try {
      String url = await api.apiSet() +
          'getprojecttask?project_serial=' +
          contractSerial +
          '&sid=' +
          storage.getItem('sId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      );
      var values = json.decode(response.body);
      if (values['status']) {
        if (values['data'].length > 0) {
          return values['data'];
        }
        showToast('No task found');
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future getBin(qrCode) async {
    String url = await api.apiSet() + 'bincard/' + qrCode;
    print("qrcode==================$qrCode");


    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);
    print("value000000000000000000 $values");
    if (values['status']) {

      print("bin bin");
      return values['data'];
    } else {
     print("$qrCode");
      showToast(values['message']);
      return values['status'];
    }
  }

  Future createNewCsr(data) async {
    print(data);
    String url = await api.apiSet() + 'new/csr';
    final response = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));
    var values = json.decode(response.body);
    print(values['message']);
    print('createNewCsr');
    showToast(values['message']);
    return values['status'];
  }

  Future getComplexity() async {
    String url = await api.apiSet() + 'getcomplexity';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
      // return (values['data'] as List).toList();
    } else {
      print('getstaff else');
      showToast(values['message']);
      return values['status'];
    }
  }

  Future getStaff() async {
    String url = await api.apiSet() + 'getstaff';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
    } else {
      print('getServiceType else');
      showToast(values['message']);
      return values['status'];
    }
  }

  Future getServiceTypes() async {
    String url = await api.apiSet() + 'getservicetype';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
    } else {
      print('getServiceType else');
      showToast(values['message']);
      return values['status'];
    }
  }

  Future getExistCustomers() async {
    String url = await api.apiSet() + 'getcustomers';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);
    // print('api ${values}');
    if (values['status']) {
      return values['data'];
    } else {
      print('getCustomer else');
      showToast(values['message']);
      return values['status'];
    }
  }

  Future saveStoreLedger(type, detail) async {
    String url = await api.apiSet() + 'storeledger/' + type;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: detail,
      encoding: Encoding.getByName("utf-8"),
    );

    var values = json.decode(response.body);

    if (values['status']) {
      showToast(values['message']);
      return values['status'];
    } else {
      print('saveStoreLedger fail');
      showToast(values['message']);
      return values['status'];
    }
  }

  Future<bool> markUpdateTask(  csrId,  detail) async {
  String url = await api.apiSet() + 'csr/' + csrId + '/fix';
  print("detail===================================>$detail");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: detail,
      encoding: Encoding.getByName("utf-8"),
    );

    if (response.statusCode == 200) {
      var values = json.decode(response.body);

      if (values['status'] != null && values['status']) {
        showToast(values['message']);
        return true; // Return true for successful status
      } else {
        showToast(values['message']);
        return false; // Return false for unsuccessful status
      }
    } else {
      print('error ${response.statusCode}');
      showToast('error ${response.statusCode}');
      return false; // Return false on error
    }
  } catch (e) {
    print("Exception occurred: $e");
    showToast('An error occurred');
    return false; // Return false on exception
  }
}

Future<void> updateStore(String type, String taskNo, List<Map<String, String>> items) async {
  String apiUrl = "https://your-api-endpoint.com/api/submit";

  Map<String, dynamic> requestBody = {
    "type": type, 
    "taskNo": taskNo,
    "items": items, 
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print("Data submitted successfully: ${response.body}");
    } else {
      print("Failed to submit data: ${response.body}");
    }
  } catch (error) {
    print("Error submitting data: $error");
  }
}



  Future addNewItem(itemCode, detail) async {
    String url = await api.apiSet() + 'bincard/' + itemCode;
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: detail,
      encoding: Encoding.getByName("utf-8"),
    );

    if (response.statusCode == 200) {
      var values = json.decode(response.body);

      if (values['status']) {
        showToast(values['message']);
        return values['status'];
      } else {
        showToast(values['message']);
        return values['status'];
      }
    } else {
      print('error 400');
      showToast('error 400');
      return false;
    }
  }

  Future<List<TaskModel>> getTaskList() async {
    try {
      String url = await api.apiSet() + 'queue/my';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      );
      if (response.statusCode == 200) {
       
        var jsonData = json.decode(response.body);
          print("Decoded JSON Data: $jsonData");
        if (jsonData['status']) {
          final detail = (jsonData['data'] as List)
              .map((data) => TaskModel.fromJson(data))
              .toList();
          return detail;
        } else {
          return [];
        }
      } else {
        throw Exception("Failed to load getTaskList");
      }
    } catch (error, stackTrace) {
      print("Error :  $error");
      print("StackTrace :  $stackTrace");
      throw Exception(error);
    }
  }

 //fatch GRN and GIN
Future<List<TaskModelG>> fetchGINorGRNData(String type) async {
  try {
    final response = await http.get(
      Uri.parse('https://your-api-url.com/api/tasks?type=$type'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic> tasksData = responseData['data'];

      if (tasksData.isEmpty) {
        print("No $type tasks available.");
        return [];
      }

      List<TaskModelG> tasks = tasksData.map((task) {
        return TaskModelG.fromJson(task);
      }).toList();

      return tasks;
    } else {
      print('Failed to load tasks');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}



  Future getCsrTrack(csrId) async {
    try {
      String url = await api.apiSet() + 'csr-track/$csrId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status']) {
          return jsonData['data'];
        } else {
          return [];
        }
      } else {
        throw Exception("Failed to load leaves");
      }
    } catch (error, stackTrace) {
      print("Error :  $error");
      print("StackTrace :  $stackTrace");
      throw Exception(error);
    }
  }

  Future getMyNotifications(sid) async {
    String url = await api.apiSet() + sid + '/notifications';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer ${storage.getItem('token')}',
      },
    );
    var values = json.decode(response.body);

    if (values['status']) {
      return values['data'];
    } else {
      print('notifications else');
      showToast(values['message']);
      return values['status'];
    }
  }


  Future getAttendance() async {
    try {
      String url = await api.apiSet() + 'getattendance';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer ${storage.getItem('token')}',
        },
      );
      var values = json.decode(response.body);

      if (values['status']) {
        return values['data'];
      } else {
        showToast(values['message']);
        return values['status'];
      }
    } catch (e) {
      print('error $e');
    }
  }

  Future saveGRN(details) async {
    print(details);
  }

  Future showToast(text) async {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        textColor: Colors.white);
  }


}
 class TaskModelG {
  final String taskNo;
  final String description;
  final String type; 
  final List<String> items; 
  final String task;

  TaskModelG(this.task, {
    required this.taskNo,
    required this.description,
    required this.type,
    required this.items, 
  });


  factory TaskModelG.fromJson(Map<String, dynamic> json) {
    return TaskModelG(
      json['task'] ?? 'N/A',
      taskNo: json['taskNo'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      type: json['type'] ?? 'N/A',
      items: (json['items'] as List<dynamic>?)?.map((item) => item as String).toList() ?? [], 
    );
  }
}


