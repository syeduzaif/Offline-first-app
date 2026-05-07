import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/core/theme/app_theme.dart';
import 'package:offline_first_app/features/attendance/presentation/pages/attendance_page.dart';
import 'package:offline_first_app/features/home/presentation/pages/home_page.dart';
import 'package:offline_first_app/features/lms/presentation/pages/class_detail_page.dart';
import 'package:offline_first_app/features/lms/presentation/pages/grading_detail_page.dart';
import 'package:offline_first_app/features/lms/presentation/pages/lms_page.dart';
import 'package:offline_first_app/features/students/presentation/pages/student_profile_page.dart';
import 'package:offline_first_app/features/students/presentation/pages/students_page.dart';
import 'package:offline_first_app/features/timetable/presentation/pages/timetable_page.dart';
import 'package:offline_first_app/shared/widgets/main_shell.dart';

// ─── Router ───────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation: '/home',
  errorBuilder: (ctx, state) => const _ErrorPage(),
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home',       builder: (ctx, _) => const HomePage()),
        GoRoute(path: '/students',   builder: (ctx, _) => const StudentsPage()),
        GoRoute(
          path: '/students/:id',
          builder: (ctx, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) return const _ErrorPage();
            return StudentProfilePage(studentId: id);
          },
        ),
        GoRoute(path: '/attendance', builder: (ctx, _) => const AttendancePage()),
        GoRoute(path: '/timetable',  builder: (ctx, _) => const TimetablePage()),
        GoRoute(path: '/lms',        builder: (ctx, _) => const LmsPage()),
        GoRoute(
          path: '/lms/:classId',
          builder: (ctx, state) {
            final id = int.tryParse(state.pathParameters['classId'] ?? '');
            if (id == null) return const _ErrorPage();
            return ClassDetailPage(classId: id);
          },
        ),
        GoRoute(
          path: '/lms/:classId/grading/:itemId',
          builder: (ctx, state) {
            final classId = int.tryParse(state.pathParameters['classId'] ?? '');
            final itemId = int.tryParse(state.pathParameters['itemId'] ?? '');
            if (classId == null || itemId == null) return const _ErrorPage();
            return GradingDetailPage(classId: classId, classworkItemId: itemId);
          },
        ),
      ],
    ),
  ],
);

// ─── Root widget ─────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (ctx, _) => MaterialApp.router(
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
        title: 'Teacher App',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ─── Error page ───────────────────────────────────────────────────────────────

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
