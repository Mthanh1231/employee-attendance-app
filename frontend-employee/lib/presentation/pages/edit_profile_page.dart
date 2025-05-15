// lib/presentation/pages/edit_profile_page.dart

import 'dart:io' as io; // chỉ dùng trên mobile/desktop
import 'package:flutter/foundation.dart'; // để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_bloc.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_state.dart';
import 'package:flutter_attendance_clean/presentation/blocs/user/user_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();

  // Trên web lưu bytes, trên mobile lưu File
  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  io.File? _frontFile;
  io.File? _backFile;

  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _cccdInfo;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Prefill email & phone nếu đã load profile
    final state = context.read<UserBloc>().state;
    if (state is UserAuthenticated) {
      _emailCtl.text = state.user.email;
      _phoneCtl.text = state.user.phone;
    }
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    if (kIsWeb) {
      // Web: đọc ra Uint8List
      final bytes = await picked.readAsBytes();
      setState(() {
        if (isFront)
          _frontBytes = bytes;
        else
          _backBytes = bytes;
      });
    } else {
      // Mobile/Desktop: dùng File
      final file = io.File(picked.path);
      setState(() {
        if (isFront)
          _frontFile = file;
        else
          _backFile = file;
      });
    }
  }

  // Hàm làm sạch dữ liệu CCCD: bỏ dấu chấm, khoảng trắng thừa đầu/cuối
  String clean(String? s) => (s ?? '')
      .replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '')
      .replaceAll(RegExp(r'[.]$'), '')
      .trim();

  Future<String?> uploadCCCDImage(String imagePath, String side) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_BASE_URL']}/api/employee/cccd-scan/$side'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['imageUrl'];
    }
    return null;
  }

  Future<Map<String, dynamic>> _scanCCCDFront() async {
    final uri =
        Uri.parse('${dotenv.env['API_BASE_URL']}/api/employee/cccd-scan/front');
    var request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token gửi lên backend (FRONT): \x1B[32m$token\x1B[0m');
    if (token == null) throw Exception('Chưa đăng nhập');
    request.headers['Authorization'] = 'Bearer $token';
    if (kIsWeb && _frontBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('image', _frontBytes!,
          filename: 'front.jpg'));
    } else if (_frontFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _frontFile!.path));
    } else {
      throw Exception('Chưa chọn ảnh mặt trước');
    }
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    print('Response FRONT: $respStr');
    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      // Thử lấy cả các trường phổ biến
      if (data['result'] != null && data['result'] is Map)
        return data['result'];
      if (data['cccd_info'] != null && data['cccd_info'] is Map)
        return data['cccd_info'];
      if (data is Map<String, dynamic>) return data;
      return {};
    } else {
      throw Exception('Lỗi quét CCCD mặt trước: $respStr');
    }
  }

  Future<Map<String, dynamic>> _scanCCCDBack() async {
    final uri =
        Uri.parse('${dotenv.env['API_BASE_URL']}/api/employee/cccd-scan/back');
    var request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Chưa đăng nhập');
    request.headers['Authorization'] = 'Bearer $token';
    if (kIsWeb && _backBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('image', _backBytes!,
          filename: 'back.jpg'));
    } else if (_backFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _backFile!.path));
    } else {
      throw Exception('Chưa chọn ảnh mặt sau');
    }
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    print('Response BACK: $respStr');
    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      if (data['result'] != null && data['result'] is Map)
        return data['result'];
      if (data['cccd_info'] != null && data['cccd_info'] is Map)
        return data['cccd_info'];
      if (data is Map<String, dynamic>) return data;
      return {};
    } else {
      throw Exception('Lỗi quét CCCD mặt sau: $respStr');
    }
  }

  Future<void> _scanCCCD() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final frontInfo = await _scanCCCDFront();
      final backInfo = await _scanCCCDBack();
      print('FRONT INFO: $frontInfo');
      print('BACK INFO: $backInfo');
      // Map lại đúng key, lấy từ fields
      final merged = {
        'id': clean(frontInfo['fields']?['id']),
        'name': clean(frontInfo['fields']?['name']),
        'date': clean(frontInfo['fields']?['date']),
        's': clean(frontInfo['fields']?['s']),
        'na': clean(frontInfo['fields']?['na']),
        'home': clean(frontInfo['fields']?['home']),
        'place': clean(frontInfo['fields']?['place']),
        'ddnd': clean(backInfo['fields']?['ddnd']),
        'img': frontInfo['fields']?['img'] ?? '',
        'tg': clean(backInfo['fields']?['tg']),
      };
      print('MERGED CCCD INFO for dialog: $merged');
      setState(() {
        _cccdInfo = merged;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      print('Lỗi khi quét CCCD: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi quét CCCD: $e')),
      );
    }
  }

  Widget _buildImageCard({
    required Uint8List? bytes,
    required io.File? file,
    required String title,
    required VoidCallback onCapture,
  }) {
    final imagePreview = Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? (bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 48, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ))
          : (file != null
              ? Image.file(file, fit: BoxFit.cover)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 48, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        imagePreview,
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.camera_alt_outlined),
            label: Text('Capture Image'),
            onPressed: onCapture,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPreviewDialog(BuildContext context,
      {Map<String, dynamic>? cccdInfoParam}) async {
    final cccdInfo = cccdInfoParam ?? _cccdInfo ?? {};
    print('Dialog xác nhận - cccdInfo: $cccdInfo');
    final emailCtl = TextEditingController(text: _emailCtl.text);
    final phoneCtl = TextEditingController(text: _phoneCtl.text);
    final noteCtl = TextEditingController();
    bool isLoading = false;
    String? error;

    // Nếu có ảnh CCCD, thực hiện quét
    if ((kIsWeb && (_frontBytes != null || _backBytes != null)) ||
        (!kIsWeb && (_frontFile != null || _backFile != null))) {
      try {
        await _scanCCCD();
      } catch (e) {
        error = 'Lỗi khi quét CCCD: $e';
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print('cccdInfo trước khi mở dialog: $cccdInfo');
        // Khởi tạo controller cho từng trường CCCD
        final nameCtl = TextEditingController(text: clean(cccdInfo['name']));
        final dateCtl = TextEditingController(text: clean(cccdInfo['date']));
        final genderCtl = TextEditingController(text: clean(cccdInfo['s']));
        final idCtl = TextEditingController(text: clean(cccdInfo['id']));
        final homeCtl = TextEditingController(text: clean(cccdInfo['home']));
        final placeCtl = TextEditingController(text: clean(cccdInfo['place']));
        final nationCtl = TextEditingController(text: clean(cccdInfo['na']));
        final ddndCtl = TextEditingController(text: clean(cccdInfo['ddnd']));
        final imgCtl = TextEditingController(text: cccdInfo['img'] ?? '');
        final tgCtl = TextEditingController(text: clean(cccdInfo['tg']));
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Xác nhận thông tin trước khi gửi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    const Text(
                      'Thông tin cơ bản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailCtl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneCtl,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // CCCD Information Section (editable, đúng thứ tự backend)
                    const Text(
                      'Thông tin từ CCCD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameCtl,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['name'] == null ||
                                cccdInfo['name'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateCtl,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['date'] == null ||
                                cccdInfo['date'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: genderCtl,
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['s'] == null ||
                                cccdInfo['s'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: idCtl,
                      decoration: InputDecoration(
                        labelText: 'Số CCCD',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['id'] == null ||
                                cccdInfo['id'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: homeCtl,
                      decoration: InputDecoration(
                        labelText: 'Nơi thường trú',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['home'] == null ||
                                cccdInfo['home'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: placeCtl,
                      decoration: InputDecoration(
                        labelText: 'Nơi cấp',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['place'] == null ||
                                cccdInfo['place'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nationCtl,
                      decoration: InputDecoration(
                        labelText: 'Quốc tịch',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['na'] == null ||
                                cccdInfo['na'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ddndCtl,
                      decoration: InputDecoration(
                        labelText: 'Đặc điểm nhận dạng',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['ddnd'] == null ||
                                cccdInfo['ddnd'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: imgCtl,
                      decoration: InputDecoration(
                        labelText: 'Ảnh chân dung (đường dẫn)',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['img'] == null ||
                                cccdInfo['img'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: tgCtl,
                      decoration: InputDecoration(
                        labelText: 'Thời gian cấp',
                        border: OutlineInputBorder(),
                        hintText: (cccdInfo['tg'] == null ||
                                cccdInfo['tg'].toString().isEmpty)
                            ? 'Chưa có thông tin'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Note Section
                    const Text(
                      'Ghi chú',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: noteCtl,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
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
                            // Gửi yêu cầu cập nhật profile với thông tin CCCD đã chỉnh sửa
                            context.read<UserBloc>().add(
                                  UpdateProfileRequest(
                                    email: emailCtl.text.trim(),
                                    phone: phoneCtl.text.trim(),
                                    note: noteCtl.text.trim(),
                                    cccdInfo: {
                                      'name': clean(nameCtl.text),
                                      'date': clean(dateCtl.text),
                                      's': clean(genderCtl.text),
                                      'id': clean(idCtl.text),
                                      'home': clean(homeCtl.text),
                                      'place': clean(placeCtl.text),
                                      'na': clean(nationCtl.text),
                                      'ddnd': clean(ddndCtl.text),
                                      'img': imgCtl.text.trim(),
                                      'tg': clean(tgCtl.text),
                                    },
                                  ),
                                );
                            if (context.mounted) {
                              Navigator.pop(context); // Đóng dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Yêu cầu cập nhật đã được gửi'),
                                ),
                              );
                              Navigator.pop(context); // Quay lại màn trước
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi yêu cầu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        centerTitle: true,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is UserAuthenticated) {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextButton.icon(
                          icon: Icon(Icons.photo_camera),
                          label: Text('Change Photo'),
                          onPressed: () {
                            // TODO: Implement profile photo change
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Form Fields with improved styling
                  _buildTextField(
                    controller: _emailCtl,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneCtl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  SizedBox(height: 32),

                  // ID Document Section
                  Text(
                    'ID Document',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Front ID Card
                  _buildImageCard(
                    bytes: _frontBytes,
                    file: _frontFile,
                    title: 'CCCD Front Side',
                    onCapture: () => _pickImage(true),
                  ),

                  SizedBox(height: 24),

                  // Back ID Card
                  _buildImageCard(
                    bytes: _backBytes,
                    file: _backFile,
                    title: 'CCCD Back Side',
                    onCapture: () => _pickImage(false),
                  ),

                  SizedBox(height: 24),

                  // Nút Quét CCCD
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.qr_code_scanner),
                      label: Text('Quét CCCD'),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              print('Bắt đầu quét CCCD...');
                              await _scanCCCD();
                              print('Kết quả _cccdInfo: [32m${_cccdInfo}[0m');
                              if (_cccdInfo != null && _cccdInfo!.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã quét xong CCCD!')),
                                );
                                await _showPreviewDialog(context,
                                    cccdInfoParam: _cccdInfo!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Không thu thập được thông tin từ CCCD!')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPreviewDialog(context,
                            cccdInfoParam: _cccdInfo ?? {});
                      },
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
