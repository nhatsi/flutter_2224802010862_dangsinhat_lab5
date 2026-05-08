// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:to_do/Api%20Services/api_services.dart';
import 'package:to_do/Pages/home_page.dart';
import 'package:to_do/Pages/register_page.dart';
import 'package:to_do/Widgets/colors.dart';
import 'package:to_do/Widgets/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool errorText = false;
  bool isLoading = false;

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() {
        errorText = true;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = false;
    });

    try {
      final loginBody = {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      };

      final response = await http.post(
        Uri.parse(login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginBody),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];

        final sharedPref = await SharedPreferences.getInstance();
        await sharedPref.setString('token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công'),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Get.off(
          () => HomePage(token: token),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 400),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: ${response.body}'),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối server: $e'),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void goToRegister() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Get.to(
        () => RegisterPage(onTap: () {}),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'TaskFlow',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Đăng nhập tài khoản',
                    style: TextStyle(
                      color: black,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Quản lý công việc cá nhân, theo dõi tiến độ và hoàn thành mục tiêu mỗi ngày.',
                    style: TextStyle(
                      color: grey,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFeild(
                          labelText: 'Email',
                          hintText: 'Nhập email của bạn',
                          icon: const Icon(Icons.email_rounded),
                          controller: emailController,
                          obscureText: false,
                          errorText: errorText,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        TextFeild(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu',
                          icon: const Icon(Icons.lock_rounded),
                          controller: passwordController,
                          obscureText: true,
                          errorText: errorText,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              disabledBackgroundColor:
                                  primaryColor.withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản?',
                        style: TextStyle(
                          color: grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: goToRegister,
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}