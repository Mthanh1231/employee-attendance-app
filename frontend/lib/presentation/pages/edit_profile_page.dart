import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String token;
  final String phone;
  final String name;
  final Map<String, dynamic> cccdInfo;

  const EditProfilePage({
    Key? key,
    required this.token,
    required this.phone,
    required this.name,
    required this.cccdInfo,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController phoneCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController placeCtrl;
  late TextEditingController dateCtrl;
  late TextEditingController homeCtrl;
  late TextEditingController cccdNameCtrl;
  late TextEditingController imgCtrl;
  late TextEditingController naCtrl;
  late TextEditingController idCtrl;
  late TextEditingController sCtrl;
  late TextEditingController ddndCtrl;
  late TextEditingController tgCtrl;

  @override
  void initState() {
    super.initState();
    phoneCtrl = TextEditingController(text: widget.phone);
    nameCtrl = TextEditingController(text: widget.name);

    placeCtrl = TextEditingController(text: widget.cccdInfo['place'] ?? '');
    dateCtrl = TextEditingController(text: widget.cccdInfo['date'] ?? '');
    homeCtrl = TextEditingController(text: widget.cccdInfo['home'] ?? '');
    cccdNameCtrl = TextEditingController(text: widget.cccdInfo['cccd_name'] ?? '');
    imgCtrl = TextEditingController(text: widget.cccdInfo['img'] ?? '');
    naCtrl = TextEditingController(text: widget.cccdInfo['na'] ?? '');
    idCtrl = TextEditingController(text: widget.cccdInfo['id'] ?? '');
    sCtrl = TextEditingController(text: widget.cccdInfo['s'] ?? '');
    ddndCtrl = TextEditingController(text: widget.cccdInfo['ddnd'] ?? '');
    tgCtrl = TextEditingController(text: widget.cccdInfo['tg'] ?? '');
  }

  Future<void> _save() async {
    final body = {
      "phone": phoneCtrl.text,
      "name": nameCtrl.text,
      "cccd_info": {
        "place": placeCtrl.text,
        "date": dateCtrl.text,
        "home": homeCtrl.text,
        "cccd_name": cccdNameCtrl.text,
        "img": imgCtrl.text,
        "na": naCtrl.text,
        "id": idCtrl.text,
        "s": sCtrl.text,
        "ddnd": ddndCtrl.text,
        "tg": tgCtrl.text
      }
    };
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': widget.token
        },
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
        Navigator.pop(context, true); // Báo cho ProfilePage reload
      } else {
        final data = json.decode(response.body);
        final errMsg = data['message'] ?? 'Lỗi không xác định';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $errMsg')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: placeCtrl,
              decoration: const InputDecoration(labelText: 'CCCD place'),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: 'CCCD date'),
            ),
            TextField(
              controller: homeCtrl,
              decoration: const InputDecoration(labelText: 'CCCD home'),
            ),
            TextField(
              controller: cccdNameCtrl,
              decoration: const InputDecoration(labelText: 'CCCD name'),
            ),
            TextField(
              controller: imgCtrl,
              decoration: const InputDecoration(labelText: 'CCCD img'),
            ),
            TextField(
              controller: naCtrl,
              decoration: const InputDecoration(labelText: 'CCCD na'),
            ),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'CCCD id'),
            ),
            TextField(
              controller: sCtrl,
              decoration: const InputDecoration(labelText: 'CCCD s'),
            ),
            TextField(
              controller: ddndCtrl,
              decoration: const InputDecoration(labelText: 'CCCD ddnd'),
            ),
            TextField(
              controller: tgCtrl,
              decoration: const InputDecoration(labelText: 'CCCD tg'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
