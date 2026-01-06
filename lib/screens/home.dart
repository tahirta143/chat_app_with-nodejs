import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login.dart';
import '../model/user_model.dart';
import '../utils/constants.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }
  Future<void> logout(BuildContext context) async {
    // Remove token or login flag
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // or prefs.clear() to remove everything

    // Navigate back to login screen and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.BASE_URL}/api/users'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Could not connect to server.\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF2A6F6F),
        actions: [
          IconButton(onPressed: (){logout(context);}, icon: Icon(Icons.logout,color: Colors.white,)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade400,
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text('${user.email}\nAge: ${user.age}'),
            isThreeLine: true,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A6F6F),
        child: const Icon(Icons.refresh,color: Colors.white,),
        onPressed: () {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
          fetchUsers();
        },
      ),
    );
  }
}
