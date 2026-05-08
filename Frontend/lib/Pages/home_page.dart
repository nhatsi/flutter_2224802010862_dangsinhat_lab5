// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:to_do/Api%20Services/api_services.dart';
import 'package:to_do/Pages/login_page.dart';
import 'package:to_do/Widgets/colors.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({
    super.key,
    required this.token,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  late String userId;

  List todos = [];
  List filteredTodos = [];

  // Lưu trạng thái hoàn thành tạm trên frontend theo id todo
  final Set<String> completedTodoIds = {};

  bool isLoading = true;
  bool isAdding = false;

  @override
  void initState() {
    super.initState();

    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    getTodolist(userId);

    searchController.addListener(() {
      filterTodos(searchController.text);
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String greetingText() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 17) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  void filterTodos(String keyword) {
    final query = keyword.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredTodos = todos;
      } else {
        filteredTodos = todos.where((todo) {
          final desc = (todo['desc'] ?? '').toString().toLowerCase();
          return desc.contains(query);
        }).toList();
      }
    });
  }

  Future<void> getTodolist(String userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final regBody = {
        'userId': userId,
      };

      final response = await http.post(
        Uri.parse(getToDo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        setState(() {
          todos = jsonResponse['success'] ?? [];
          filteredTodos = todos;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showSnackBar('Không thể tải danh sách công việc', isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showSnackBar('Lỗi kết nối server: $e', isError: true);
    }
  }

  Future<void> createTask() async {
    final taskText = taskController.text.trim();

    if (taskText.isEmpty) {
      showSnackBar('Vui lòng nhập nội dung công việc', isError: true);
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      final regBody = {
        'desc': taskText,
        'userId': userId,
      };

      final response = await http.post(
        Uri.parse(createToDo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        taskController.clear();
        Navigator.pop(context);

        showSnackBar('Đã thêm công việc mới');
        await getTodolist(userId);
      } else {
        showSnackBar('Thêm công việc thất bại', isError: true);
      }
    } catch (e) {
      showSnackBar('Lỗi kết nối server: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  Future<void> deleteToDoItem(String id) async {
    try {
      final regBody = {
        'id': id,
      };

      final response = await http.post(
        Uri.parse(deleteToDo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(regBody),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == true) {
        setState(() {
          completedTodoIds.remove(id);
        });

        showSnackBar('Đã xóa công việc');
        await getTodolist(userId);
      } else {
        showSnackBar('Xóa công việc thất bại', isError: true);
      }
    } catch (e) {
      showSnackBar('Lỗi kết nối server: $e', isError: true);
    }
  }

  void toggleComplete(String id) {
    setState(() {
      if (completedTodoIds.contains(id)) {
        completedTodoIds.remove(id);
      } else {
        completedTodoIds.add(id);
      }
    });

    final isDone = completedTodoIds.contains(id);

    showSnackBar(
      isDone ? 'Đã đánh dấu hoàn thành' : 'Đã bỏ đánh dấu hoàn thành',
      isError: false,
    );
  }

  Future<void> logout() async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.remove('token');

    Get.offAll(
      () => LoginPage(onTap: () {}),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 400),
    );
  }

  void showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? red : green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          text,
          style: const TextStyle(
            color: white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void addTask() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thêm công việc',
                      style: TextStyle(
                        color: black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: taskController,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(
                    color: black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFillColor,
                    hintText: 'Ví dụ: Hoàn thành Lab 5 Flutter JWT',
                    hintStyle: const TextStyle(
                      color: grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: primaryColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isAdding ? null : createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isAdding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Lưu công việc',
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
        );
      },
    );
  }

  int get totalTasks => todos.length;

  int get completedTasks => completedTodoIds.length;

  int get pendingTasks {
    final pending = totalTasks - completedTasks;
    return pending < 0 ? 0 : pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        backgroundColor: primaryColor,
        elevation: 0,
        icon: const Icon(
          Icons.add_rounded,
          color: white,
        ),
        label: const Text(
          'Thêm việc',
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => getTodolist(userId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSummaryCard(),
                      const SizedBox(height: 22),
                      _buildSearchBox(),
                      const SizedBox(height: 24),
                      const Text(
                        'Danh sách công việc',
                        style: TextStyle(
                          color: black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${filteredTodos.length} công việc đang hiển thị',
                        style: const TextStyle(
                          color: grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                )
              else if (filteredTodos.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final todo = filteredTodos[index];
                        final String id = todo['_id'];
                        final bool isDone = completedTodoIds.contains(id);

                        return _buildTodoCard(
                          id: id,
                          text: todo['desc'] ?? '',
                          isDone: isDone,
                          onComplete: () => toggleComplete(id),
                          onDelete: () => deleteToDoItem(id),
                        );
                      },
                      childCount: filteredTodos.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingText(),
                style: const TextStyle(
                  color: grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quản lý Todo',
                style: TextStyle(
                  color: black,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: logout,
            tooltip: 'Đăng xuất',
            icon: const Icon(
              Icons.logout_rounded,
              color: red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryColor,
            primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan hôm nay',
            style: TextStyle(
              color: white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalTasks == 0
                ? 'Bạn chưa có công việc nào.'
                : 'Bạn có $totalTasks công việc cần theo dõi.',
            style: TextStyle(
              color: white.withOpacity(0.82),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem('Tổng', totalTasks.toString()),
              const SizedBox(width: 12),
              _buildStatItem('Hoàn thành', completedTasks.toString()),
              const SizedBox(width: 12),
              _buildStatItem('Còn lại', pendingTasks.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: white.withOpacity(0.18),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: white.withOpacity(0.82),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightGrey),
      ),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: primaryColor,
          ),
          hintText: 'Tìm kiếm công việc...',
          hintStyle: TextStyle(
            color: grey,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTodoCard({
    required String id,
    required String text,
    required bool isDone,
    required VoidCallback onComplete,
    required VoidCallback onDelete,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDone ? green.withOpacity(0.08) : cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDone ? green.withOpacity(0.5) : lightGrey,
        ),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onComplete,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDone ? green : secondaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isDone
                    ? Icons.check_rounded
                    : Icons.check_circle_outline_rounded,
                color: isDone ? white : primaryColor,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDone ? grey : black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
                decoration:
                    isDone ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Xóa',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: primaryColor,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Chưa có công việc',
            style: TextStyle(
              color: black,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bấm nút “Thêm việc” để tạo todo đầu tiên của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: grey,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}