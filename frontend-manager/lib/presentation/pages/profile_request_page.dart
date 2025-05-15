import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/cccd_info_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<dynamic>> fetchProfileRequests() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return [];

  final response = await http.get(
    Uri.parse(
        '${dotenv.env['API_BASE_URL']}/api/manager/profile-update-requests'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is Map && data['requests'] is List) {
      return data['requests'];
    }
    if (data is List) {
      return data;
    }
  }
  return [];
}

Future<bool> processRequest(String requestId, String status) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return false;

  final body = jsonEncode({'status': status});
  print('Body gửi lên: $body');
  final response = await http.put(
    Uri.parse(
        '${dotenv.env['API_BASE_URL']}/api/manager/profile-update-requests/$requestId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: body,
  );
  print('processRequest: status=${response.statusCode}, body=${response.body}');
  return response.statusCode == 200;
}

class ProfileRequestPage extends StatefulWidget {
  final void Function(int)? onRequestCountChanged;
  const ProfileRequestPage({Key? key, this.onRequestCountChanged})
      : super(key: key);
  @override
  State<ProfileRequestPage> createState() => _ProfileRequestPageState();
}

class _ProfileRequestPageState extends State<ProfileRequestPage> {
  late Future<List<dynamic>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = fetchProfileRequests();
    _futureRequests.then((list) {
      if (widget.onRequestCountChanged != null) {
        widget.onRequestCountChanged!(
            list.where((r) => r['status'] == 'pending').length);
      }
    });
  }

  void _refresh() {
    setState(() {
      _futureRequests = fetchProfileRequests();
      _futureRequests.then((list) {
        if (widget.onRequestCountChanged != null) {
          widget.onRequestCountChanged!(
              list.where((r) => r['status'] == 'pending').length);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu cập nhật hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Text('Không có yêu cầu nào'),
            );
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final newData = req['newData'] ?? {};
              final cccdInfo = CccdInfo.fromJson(newData['cccd_info']);
              final noteController = TextEditingController();

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Employee ID: ${req['employeeId'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (cccdInfo != null) ...[
                        const Text('Thông tin từ CCCD:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Tên: ${cccdInfo.cccdName ?? ''}'),
                        Text('Ngày sinh: ${cccdInfo.date ?? ''}'),
                        Text('Nơi cấp: ${cccdInfo.place ?? ''}'),
                        Text('Số CCCD: ${cccdInfo.id ?? ''}'),
                        Text('Giới tính: ${cccdInfo.s ?? ''}'),
                        Text('Quốc tịch: ${cccdInfo.na ?? ''}'),
                        Text('Đặc điểm nhận dạng: ${cccdInfo.ddnd ?? ''}'),
                        const SizedBox(height: 8),
                      ],
                      const Text('Thông tin cập nhật:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Email: ${newData['email'] ?? ''}'),
                      Text('Số điện thoại: ${newData['phone'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Ghi chú của nhân viên: ${newData['note'] ?? ''}',
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                labelText: 'Ghi chú của manager',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              const status = 'approved';
                              print('Gửi status: $status');
                              final ok =
                                  await processRequest(req['id'], status);
                              if (ok) {
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Duyệt thành công!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Duyệt thất bại!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('Duyệt'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              const status = 'denied';
                              print('Gửi status: $status');
                              final ok =
                                  await processRequest(req['id'], status);
                              if (ok) {
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Từ chối thành công!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Từ chối thất bại!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Từ chối'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
