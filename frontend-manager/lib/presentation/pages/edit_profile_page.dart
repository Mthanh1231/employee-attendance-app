import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/models/cccd_info_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  File? _frontImage;
  File? _backImage;
  Map<String, dynamic>? _cccdInfo;
  CccdInfo? get cccdInfoModel => CccdInfo.fromJson(_cccdInfo);

  @override
  void initState() {
    super.initState();
    // TODO: Prefill email & phone nếu cần
  }

  Future<void> _pickImage(bool isFront) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _scanCCCD() async {
    if (_frontImage == null || _backImage == null) {
      setState(() {
        _error = 'Vui lòng chọn cả ảnh mặt trước và sau của CCCD';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Chưa đăng nhập');

      // Gửi ảnh mặt trước
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/employee/cccd-scan-front'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _frontImage!.path,
      ));
      var response = await request.send();
      var frontData = await response.stream.bytesToString();
      var frontInfo = jsonDecode(frontData);

      // Gửi ảnh mặt sau
      request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/employee/cccd-scan-back'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _backImage!.path,
      ));
      response = await request.send();
      var backData = await response.stream.bytesToString();
      var backInfo = jsonDecode(backData);

      setState(() {
        _cccdInfo = {
          ...frontInfo,
          ...backInfo,
        };
        // Tự động điền thông tin vào form
        if (_cccdInfo != null) {
          _emailCtl.text = _cccdInfo!['email'] ?? '';
          _phoneCtl.text = _cccdInfo!['phone'] ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi quét CCCD: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showPreviewDialog(BuildContext context) async {
    final emailCtl = TextEditingController(text: _emailCtl.text);
    final phoneCtl = TextEditingController(text: _phoneCtl.text);
    final noteCtl = TextEditingController(text: _noteCtl.text);
    final cccdInfo = _cccdInfo ?? {};
    bool isLoading = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Xác nhận thông tin trước khi gửi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: emailCtl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneCtl,
                      decoration:
                          const InputDecoration(labelText: 'Số điện thoại'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: noteCtl,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                    if (cccdInfoModel != null) ...[
                      const SizedBox(height: 8),
                      const Text('Thông tin từ CCCD:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Tên: ${cccdInfoModel!.cccdName ?? ''}'),
                      Text('Ngày sinh: ${cccdInfoModel!.date ?? ''}'),
                      Text('Nơi cấp: ${cccdInfoModel!.place ?? ''}'),
                      Text('Số CCCD: ${cccdInfoModel!.id ?? ''}'),
                      Text('Giới tính: ${cccdInfoModel!.s ?? ''}'),
                      Text('Quốc tịch: ${cccdInfoModel!.na ?? ''}'),
                      Text('Đặc điểm nhận dạng: ${cccdInfoModel!.ddnd ?? ''}'),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            error = null;
                          });
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');
                            if (token == null)
                              throw Exception('Chưa đăng nhập');
                            final response = await http.post(
                              Uri.parse(
                                  'http://localhost:3000/api/employee/profile-update-request'),
                              headers: {
                                'Authorization': 'Bearer $token',
                                'Content-Type': 'application/json',
                              },
                              body: jsonEncode({
                                'newData': {
                                  'email': emailCtl.text.trim(),
                                  'phone': phoneCtl.text.trim(),
                                  'note': noteCtl.text.trim(),
                                  'cccd_info': cccdInfo,
                                },
                              }),
                            );
                            if (response.statusCode == 201) {
                              if (context.mounted) {
                                Navigator.pop(context); // Đóng dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Yêu cầu cập nhật đã được gửi')),
                                );
                                Navigator.pop(context); // Quay lại màn trước
                              }
                            } else {
                              setState(() {
                                error = 'Gửi yêu cầu thất bại';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              error = 'Lỗi: $e';
                            });
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Gửi yêu cầu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phần chọn ảnh CCCD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quét CCCD',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Mặt trước'),
                                const SizedBox(height: 8),
                                _frontImage != null
                                    ? Image.file(
                                        _frontImage!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                                TextButton(
                                  onPressed: () => _pickImage(true),
                                  child: const Text('Chọn ảnh'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Mặt sau'),
                                const SizedBox(height: 8),
                                _backImage != null
                                    ? Image.file(
                                        _backImage!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                                TextButton(
                                  onPressed: () => _pickImage(false),
                                  child: const Text('Chọn ảnh'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _scanCCCD,
                        child: const Text('Quét CCCD'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Form thông tin
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ ?$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtl,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^[0-9]{6,15} ?$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await _showPreviewDialog(context);
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
