// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDB();
  runApp(const CGPAMain());
}

/* ---------------- DB helper ---------------- */
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;
  Database? get database => _db;

  Future<void> initDB() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'cgpa_app.db');

    _db = await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE semesters (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');

      await db.execute('''
        CREATE TABLE courses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          semesterId INTEGER NOT NULL,
          name TEXT NOT NULL,
          credit REAL NOT NULL,
          quiz REAL NOT NULL DEFAULT 0,
          assignment REAL NOT NULL DEFAULT 0,
          mid REAL NOT NULL DEFAULT 0,
          finalTerm REAL NOT NULL DEFAULT 0,
          totalMarks REAL NOT NULL DEFAULT 0,
          gradePoint REAL NOT NULL,
          FOREIGN KEY (semesterId) REFERENCES semesters(id) ON DELETE CASCADE
        )
      ''');
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        try {
          await db.execute("ALTER TABLE courses ADD COLUMN quiz REAL NOT NULL DEFAULT 0");
          await db.execute("ALTER TABLE courses ADD COLUMN assignment REAL NOT NULL DEFAULT 0");
          await db.execute("ALTER TABLE courses ADD COLUMN mid REAL NOT NULL DEFAULT 0");
          await db.execute("ALTER TABLE courses ADD COLUMN finalTerm REAL NOT NULL DEFAULT 0");
          await db.execute("ALTER TABLE courses ADD COLUMN totalMarks REAL NOT NULL DEFAULT 0");
        } catch (_) {}
      }
    });
  }

  Future<int> insertSemester(String name) async => await _db!.insert('semesters', {'name': name});
  Future<int> updateSemester(int id, String name) async => await _db!.update('semesters', {'name': name}, where: 'id = ?', whereArgs: [id]);
  Future<List<Map<String, dynamic>>> getSemesters() async => await _db!.query('semesters', orderBy: 'id');
  Future<int> deleteSemester(int id) async {
    await _db!.delete('courses', where: 'semesterId = ?', whereArgs: [id]);
    return await _db!.delete('semesters', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertCourse(int semesterId, Map<String, dynamic> course) async {
    final row = {
      'semesterId': semesterId,
      'name': course['name'],
      'credit': course['credit'],
      'quiz': course['quiz'],
      'assignment': course['assignment'],
      'mid': course['mid'],
      'finalTerm': course['finalTerm'],
      'totalMarks': course['totalMarks'],
      'gradePoint': course['gradePoint'],
    };
    return await _db!.insert('courses', row);
  }

  Future<int> updateCourse(int id, Map<String, dynamic> course) async {
    final row = {
      'name': course['name'],
      'credit': course['credit'],
      'quiz': course['quiz'],
      'assignment': course['assignment'],
      'mid': course['mid'],
      'finalTerm': course['finalTerm'],
      'totalMarks': course['totalMarks'],
      'gradePoint': course['gradePoint'],
    };
    return await _db!.update('courses', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCourseSemester(int courseId, int semesterId) async =>
      await _db!.update('courses', {'semesterId': semesterId}, where: 'id = ?', whereArgs: [courseId]);

  Future<List<Map<String, dynamic>>> getCourses(int semesterId) async =>
      await _db!.query('courses', where: 'semesterId = ?', whereArgs: [semesterId], orderBy: 'id');

  Future<List<Map<String, dynamic>>> getAllCoursesWithSemester() async {
    final result = await _db!.rawQuery('''
      SELECT c.*, s.name as semesterName FROM courses c
      JOIN semesters s ON s.id = c.semesterId
      ORDER BY s.id, c.id
    ''');
    return result;
  }

  Future<int> deleteCourse(int id) async => await _db!.delete('courses', where: 'id = ?', whereArgs: [id]);
  Future<void> clearAll() async {
    await _db!.delete('courses');
    await _db!.delete('semesters');
  }
}

/* ---------------- grading helpers ---------------- */
double marksToGradePoint(double marks) {
  if (marks >= 85) return 4.0;
  if (marks >= 80) return 3.7;
  if (marks >= 75) return 3.3;
  if (marks >= 70) return 3.0;
  if (marks >= 65) return 2.7;
  if (marks >= 60) return 2.3;
  if (marks >= 55) return 2.0;
  if (marks >= 50) return 1.7;
  return 0.0;
}

/* ---------------- App ---------------- */
class CGPAMain extends StatefulWidget {
  const CGPAMain({super.key});
  @override
  State<CGPAMain> createState() => _CGPAMainState();
}

class _CGPAMainState extends State<CGPAMain> {
  bool isDark = false;
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDark = prefs.getBool('isDarkMode') ?? false);
  }

  Future<void> _setTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() => isDark = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA App',
      theme: ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.light),
      darkTheme: ThemeData(primarySwatch: Colors.indigo, brightness: Brightness.dark),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeChanged: _setTheme, isDark: isDark),
    );
  }
}

/* ---------------- Home / Dashboard ---------------- */
class HomeScreen extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final bool isDark;
  const HomeScreen({super.key, required this.onThemeChanged, required this.isDark});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  final nameCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final programCtrl = TextEditingController();

  List<Map<String, dynamic>> semesters = [];
  Map<int, List<Map<String, dynamic>>> coursesBySemester = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // reload everything from DB (use after every DB write)
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    nameCtrl.text = prefs.getString('studentName') ?? '';
    rollCtrl.text = prefs.getString('studentRoll') ?? '';
    programCtrl.text = prefs.getString('studentProgram') ?? '';

    final sems = await db.getSemesters();
    semesters = sems;
    coursesBySemester.clear();
    for (final s in semesters) {
      final list = await db.getCourses(s['id'] as int);
      // ensure numeric types are doubles to avoid surprises
      final normalized = list.map((m) {
        return {
          ...m,
          'credit': (m['credit'] as num).toDouble(),
          'quiz': (m['quiz'] as num).toDouble(),
          'assignment': (m['assignment'] as num).toDouble(),
          'mid': (m['mid'] as num).toDouble(),
          'finalTerm': (m['finalTerm'] as num).toDouble(),
          'totalMarks': (m['totalMarks'] as num).toDouble(),
          'gradePoint': (m['gradePoint'] as num).toDouble(),
        };
      }).toList();
      coursesBySemester[s['id'] as int] = normalized;
    }
    setState(() {});
  }

  // compute overall CGPA robustly
  double computeCgpa() {
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    for (final list in coursesBySemester.values) {
      for (final c in list) {
        final gp = (c['gradePoint'] as num).toDouble();
        final cr = (c['credit'] as num).toDouble();
        totalPoints += gp * cr;
        totalCredits += cr;
      }
    }
    if (totalCredits == 0.0) return 0.0;
    return totalPoints / totalCredits;
  }

  // compute SGPA for a list of courses
  double computeSgpaFor(List<Map<String, dynamic>> list) {
    double tp = 0.0, tc = 0.0;
    for (final c in list) {
      final gp = (c['gradePoint'] as num).toDouble();
      final cr = (c['credit'] as num).toDouble();
      tp += gp * cr;
      tc += cr;
    }
    if (tc == 0.0) return 0.0;
    return tp / tc;
  }

  Future<void> _saveStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentName', nameCtrl.text.trim());
    await prefs.setString('studentRoll', rollCtrl.text.trim());
    await prefs.setString('studentProgram', programCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student info saved')));
  }

  /* ---------- Dialogs and Add/Edit flows ---------- */

  Future<void> _addSemester() async {
    final ctrl = TextEditingController(text: 'Semester ${semesters.length + 1}');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Semester'),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
          child: SingleChildScrollView(child: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Semester name or number'))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                try {
                  await db.insertSemester(name);
                  await _loadAll();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add semester (maybe duplicate)')));
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSemester(int id, String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Semester'),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
          child: SingleChildScrollView(child: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Semester name or number'))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                try {
                  await db.updateSemester(id, name);
                  await _loadAll();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit semester (maybe duplicate)')));
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCourse() async {
    if (semesters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a semester first')));
      return;
    }
    final subjectCtrl = TextEditingController();
    final creditCtrl = TextEditingController();
    final quizCtrl = TextEditingController(text: '0');
    final assignmentCtrl = TextEditingController(text: '0');
    final midCtrl = TextEditingController(text: '0');
    final finalCtrl = TextEditingController(text: '0');
    int selectedSemesterId = semesters.first['id'] as int;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
                TextField(controller: creditCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Credit Hours')),
                const SizedBox(height: 8),
                const Text('Component marks (0-100)'),
                TextField(controller: quizCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quizzes')),
                TextField(controller: assignmentCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Assignments')),
                TextField(controller: midCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mid-term')),
                TextField(controller: finalCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Final-term (0 if not taken)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: selectedSemesterId,
                  items: semesters.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text(s['name'] as String))).toList(),
                  onChanged: (v) => selectedSemesterId = v ?? selectedSemesterId,
                  decoration: const InputDecoration(labelText: 'Semester'),
                ),
                const SizedBox(height: 6),
                const Text('Weights: Q 10% • A 20% • M 30% • F 40%'),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = subjectCtrl.text.trim();
                final credit = double.tryParse(creditCtrl.text) ?? 0;
                final quiz = double.tryParse(quizCtrl.text) ?? 0;
                final assignment = double.tryParse(assignmentCtrl.text) ?? 0;
                final mid = double.tryParse(midCtrl.text) ?? 0;
                final finalT = double.tryParse(finalCtrl.text) ?? 0;
                if (name.isNotEmpty && credit > 0 && quiz >= 0 && assignment >= 0 && mid >= 0 && finalT >= 0) {
                  final totalMarks = (quiz * 0.10) + (assignment * 0.20) + (mid * 0.30) + (finalT * 0.40);
                  final gp = marksToGradePoint(totalMarks);
                  try {
                    await db.insertCourse(selectedSemesterId, {
                      'name': name,
                      'credit': credit,
                      'quiz': quiz,
                      'assignment': assignment,
                      'mid': mid,
                      'finalTerm': finalT,
                      'totalMarks': totalMarks,
                      'gradePoint': gp
                    });
                    await _loadAll();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add course')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid values')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCourse(int courseId, int semesterId, Map<String, dynamic> currentValues) async {
    final subjectCtrl = TextEditingController(text: (currentValues['name'] ?? '') as String);
    final creditCtrl = TextEditingController(text: ((currentValues['credit'] ?? 0) as num).toString());
    final quizCtrl = TextEditingController(text: ((currentValues['quiz'] ?? 0) as num).toString());
    final assignmentCtrl = TextEditingController(text: ((currentValues['assignment'] ?? 0) as num).toString());
    final midCtrl = TextEditingController(text: ((currentValues['mid'] ?? 0) as num).toString());
    final finalCtrl = TextEditingController(text: ((currentValues['finalTerm'] ?? 0) as num).toString());
    int selectedSemesterId = semesterId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Course'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedSemesterId,
                  items: semesters.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text(s['name'] as String))).toList(),
                  onChanged: (v) => selectedSemesterId = v ?? selectedSemesterId,
                  decoration: const InputDecoration(labelText: 'Semester'),
                ),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
                TextField(controller: creditCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Credit Hours')),
                const SizedBox(height: 8),
                const Text('Component marks (0-100)'),
                TextField(controller: quizCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quizzes')),
                TextField(controller: assignmentCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Assignments')),
                TextField(controller: midCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Mid-term')),
                TextField(controller: finalCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Final-term')),
                const SizedBox(height: 6),
                const Text('Weights: Q 10% • A 20% • M 30% • F 40%'),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = subjectCtrl.text.trim();
                final credit = double.tryParse(creditCtrl.text) ?? 0;
                final quiz = double.tryParse(quizCtrl.text) ?? 0;
                final assignment = double.tryParse(assignmentCtrl.text) ?? 0;
                final mid = double.tryParse(midCtrl.text) ?? 0;
                final finalT = double.tryParse(finalCtrl.text) ?? 0;
                if (name.isNotEmpty && credit > 0 && quiz >= 0 && assignment >= 0 && mid >= 0 && finalT >= 0) {
                  final totalMarks = (quiz * 0.10) + (assignment * 0.20) + (mid * 0.30) + (finalT * 0.40);
                  final gp = marksToGradePoint(totalMarks);
                  try {
                    await db.updateCourse(courseId, {
                      'name': name,
                      'credit': credit,
                      'quiz': quiz,
                      'assignment': assignment,
                      'mid': mid,
                      'finalTerm': finalT,
                      'totalMarks': totalMarks,
                      'gradePoint': gp
                    });
                    if (selectedSemesterId != semesterId) {
                      await db.updateCourseSemester(courseId, selectedSemesterId);
                    }
                    await _loadAll();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update course')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid values')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSemester(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete semester?'),
        content: const Text('Deleting a semester will remove all its courses. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await db.deleteSemester(id);
      await _loadAll();
    }
  }

  Future<void> _deleteCourse(int id, int semesterId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete course?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await db.deleteCourse(id);
      final list = await db.getCourses(semesterId);
      coursesBySemester[semesterId] = list;
      await _loadAll();
    }
  }

  Future<void> _openSummary() async {
    final all = await db.getAllCoursesWithSemester();
    final cgpa = computeCgpa();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => SummaryScreen(courses: all, studentName: nameCtrl.text, roll: rollCtrl.text, program: programCtrl.text, cgpa: cgpa)));
    await _loadAll();
  }

  // Per-course predictor dialog (constrained to avoid overflow)
  Future<void> _predictForCourse(Map<String, dynamic> c) async {
    final quiz = (c['quiz'] as num).toDouble();
    final assignment = (c['assignment'] as num).toDouble();
    final mid = (c['mid'] as num).toDouble();
    final finalTerm = (c['finalTerm'] as num).toDouble();
    final currentWeightedWithoutFinal = (quiz * 0.10) + (assignment * 0.20) + (mid * 0.30);

    final targetCtrl = TextEditingController();
    final finalCtrl = TextEditingController(text: finalTerm.toString());
    String message = '';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Predict for ${c['name']}'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current: Q:${quiz.toStringAsFixed(1)} A:${assignment.toStringAsFixed(1)} M:${mid.toStringAsFixed(1)}'),
                const SizedBox(height: 8),
                const Text('Option A — target total:'),
                TextField(controller: targetCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Target total % (e.g. 75)')),
                ElevatedButton(onPressed: () {
                  final target = double.tryParse(targetCtrl.text) ?? -1;
                  if (target < 0 || target > 100) {
                    setState(() => message = 'Enter a valid target percent (0–100).');
                    return;
                  }
                  final requiredFinal = (target - currentWeightedWithoutFinal) / 0.40;
                  if (requiredFinal > 100) {
                    setState(() => message = 'Target unreachable — requires final ${requiredFinal.toStringAsFixed(1)}% (>100).');
                  } else if (requiredFinal < 0) {
                    setState(() => message = 'You already exceed the target without needing final marks.');
                  } else {
                    final gp = marksToGradePoint(target);
                    setState(() => message = 'Need final ≈ ${requiredFinal.toStringAsFixed(1)}% to reach total ${target.toStringAsFixed(1)}% (GP ≈ ${gp.toStringAsFixed(2)})');
                  }
                }, child: const Text('Compute required final')),
                const Divider(),
                const Text('Option B — given final term mark:'),
                TextField(controller: finalCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Final-term mark (0–100)')),
                ElevatedButton(onPressed: () {
                  final finalGiven = double.tryParse(finalCtrl.text) ?? -1;
                  if (finalGiven < 0 || finalGiven > 100) {
                    setState(() => message = 'Enter a valid final-term mark (0–100).');
                    return;
                  }
                  final total = currentWeightedWithoutFinal + (finalGiven * 0.40);
                  final gp = marksToGradePoint(total);
                  setState(() => message = 'With final ${finalGiven.toStringAsFixed(1)}% → Total ${total.toStringAsFixed(1)}% (GP ≈ ${gp.toStringAsFixed(2)})');
                }, child: const Text('Compute resulting total & GP')),
                const SizedBox(height: 8),
                if (message.isNotEmpty) Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = computeCgpa();
    final totalCourses = coursesBySemester.values.fold<int>(0, (p, e) => p + e.length);

    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Dashboard'), actions: [
        IconButton(onPressed: _openSummary, icon: const Icon(Icons.analytics_outlined)),
        IconButton(
            onPressed: () async {
              await db.clearAll();
              await _loadAll();
            },
            icon: const Icon(Icons.delete_forever))
      ]),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).primaryColor), child: const Text('CGPA App', style: TextStyle(color: Colors.white, fontSize: 20))),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Semesters'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SemestersScreen()));
              await _loadAll();
            },
          ),
          ListTile(leading: const Icon(Icons.add_box), title: const Text('Add Semester'), onTap: () { Navigator.pop(context); _addSemester(); }),
          ListTile(leading: const Icon(Icons.book), title: const Text('Add Course'), onTap: () { Navigator.pop(context); _addCourse(); }),
          ListTile(leading: const Icon(Icons.person), title: const Text('Student Info'), onTap: () async { Navigator.pop(context); await Navigator.push(context, MaterialPageRoute(builder: (_) => StudentInfoScreen(nameCtrl: nameCtrl, rollCtrl: rollCtrl, programCtrl: programCtrl))); await _loadAll(); }),
          const Divider(),
          SwitchListTile(title: const Text('Dark Mode'), value: widget.isDark, secondary: const Icon(Icons.dark_mode), onChanged: (v) => widget.onThemeChanged(v)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
          TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number')),
          TextField(controller: programCtrl, decoration: const InputDecoration(labelText: 'Program')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _saveStudentInfo, child: const Text('Save Student Info')),
          const SizedBox(height: 12),
          Text('Semesters: ${semesters.length}  •  Courses: $totalCourses'),
          const SizedBox(height: 12),
          // use builder to avoid building a huge column that can overflow
          Expanded(
            child: ListView.builder(
              itemCount: semesters.length,
              itemBuilder: (context, sIndex) {
                final s = semesters[sIndex];
                final id = s['id'] as int;
                final list = coursesBySemester[id] ?? [];
                final sgpa = computeSgpaFor(list);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s['name'] as String), Text('SGPA: ${sgpa.toStringAsFixed(2)}')]),
                    children: [
                      if (list.isEmpty)
                        const ListTile(title: Text('No courses')),
                      if (list.isNotEmpty)
                      // constrain course list height within expansion tile to prevent overflow
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final c = list[i];
                              final totalMarks = (c['totalMarks'] as num).toDouble();
                              final quiz = (c['quiz'] as num).toDouble();
                              final assignment = (c['assignment'] as num).toDouble();
                              final mid = (c['mid'] as num).toDouble();
                              final finalT = (c['finalTerm'] as num).toDouble();
                              final gp = (c['gradePoint'] as num).toDouble();
                              final cr = (c['credit'] as num).toDouble();

                              return ListTile(
                                title: Text('${c['name']} (${cr.toStringAsFixed(1)} Cr)'),
                                subtitle: Text('Total: ${totalMarks.toStringAsFixed(1)} • Q:${quiz.toStringAsFixed(1)} A:${assignment.toStringAsFixed(1)} M:${mid.toStringAsFixed(1)} F:${finalT.toStringAsFixed(1)} • GP:${gp.toStringAsFixed(2)}'),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(onPressed: () => _predictForCourse(c), icon: const Icon(Icons.remove_red_eye), tooltip: 'Predict for this subject'),
                                  IconButton(onPressed: () => _editCourse(c['id'] as int, id, c), icon: const Icon(Icons.edit)),
                                  IconButton(onPressed: () => _deleteCourse(c['id'] as int, id), icon: const Icon(Icons.delete)),
                                ]),
                              );
                            },
                          ),
                        ),
                      ButtonBar(alignment: MainAxisAlignment.end, children: [
                        TextButton(onPressed: () => _editSemester(id, s['name'] as String), child: const Text('Edit Semester')),
                        TextButton(onPressed: () => _deleteSemester(id), child: const Text('Delete Semester', style: TextStyle(color: Colors.red))),
                      ])
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('CGPA: ${cgpa.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall)),
          if (cgpa <= 2.0 && semesters.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(
              color: Colors.redAccent.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('⚠️ Low CGPA Warning!'),
                  Text('Name: ${nameCtrl.text}'),
                  Text('Roll: ${rollCtrl.text}'),
                  Text('Program: ${programCtrl.text}'),
                ]),
              ),
            )
          ]
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addCourse, icon: const Icon(Icons.add), label: const Text('Add Course')),
    );
  }
}

/* ---------------- Semesters screen ---------------- */
class SemestersScreen extends StatefulWidget {
  const SemestersScreen({super.key});
  @override
  State<SemestersScreen> createState() => _SemestersScreenState();
}

class _SemestersScreenState extends State<SemestersScreen> {
  final db = DatabaseHelper.instance;
  final ctrl = TextEditingController();
  List<Map<String, dynamic>> semesters = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    semesters = await db.getSemesters();
    setState(() {});
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete semester?'),
        content: const Text('Deleting a semester will remove all its courses. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await db.deleteSemester(id);
      await _load();
    }
  }

  Future<void> _edit(int id, String current) async {
    final c = TextEditingController(text: current);

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Semester'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: TextField(
                controller: c,
                decoration: const InputDecoration(labelText: 'Semester name or number'),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = c.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await db.updateSemester(id, name);
                    await _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to edit semester (maybe duplicate)')),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semesters')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Semester name or number')),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await db.insertSemester(name);
                    ctrl.clear();
                    await _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add semester (maybe duplicate)')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: semesters.length,
                itemBuilder: (context, i) {
                  final s = semesters[i];
                  return Card(
                    child: ListTile(
                      title: Text(s['name'] as String),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(s['id'] as int, s['name'] as String)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(s['id'] as int)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Student Info & Summary ---------------- */
class StudentInfoScreen extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rollCtrl;
  final TextEditingController programCtrl;
  const StudentInfoScreen({super.key, required this.nameCtrl, required this.rollCtrl, required this.programCtrl});
  @override State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}
class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentName', widget.nameCtrl.text.trim());
    await prefs.setString('studentRoll', widget.rollCtrl.text.trim());
    await prefs.setString('studentProgram', widget.programCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Student Info')), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [ TextField(controller: widget.nameCtrl, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: widget.rollCtrl, decoration: const InputDecoration(labelText: 'Roll')), TextField(controller: widget.programCtrl, decoration: const InputDecoration(labelText: 'Program')), const SizedBox(height: 12), ElevatedButton(onPressed: _save, child: const Text('Save')), ])));
  }
}

class SummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final String studentName;
  final String roll;
  final String program;
  final double cgpa;
  const SummaryScreen({super.key, required this.courses, required this.studentName, required this.roll, required this.program, required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final totalCredits = courses.fold<double>(0, (p, e) => p + ((e['credit'] ?? 0) as num).toDouble());
    final failing = courses.where((c) => ((c['gradePoint'] ?? 0) as num).toDouble() == 0.0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Result Summary')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Student: $studentName', style: Theme.of(context).textTheme.titleMedium),
          Text('Roll: $roll'),
          Text('Program: $program'),
          const SizedBox(height: 12),
          Text('Overall CGPA: ${cgpa.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text('Total Credits: ${totalCredits.toStringAsFixed(1)}'),
          const SizedBox(height: 12),
          Text('Courses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(child: ListView.separated(
            itemCount: courses.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final c = courses[i];
              final totalMarks = ((c['totalMarks'] ?? 0) as num).toDouble();
              return ListTile(
                title: Text('${c['semesterName'] ?? ''} • ${c['name']}'),
                subtitle: Text('Credits: ${(c['credit'] ?? 0)} • Total: ${totalMarks.toStringAsFixed(1)} • GP: ${((c['gradePoint'] ?? 0) as num).toDouble()}'),
                trailing: ((c['gradePoint'] ?? 0) as num).toDouble() == 0.0 ? const Icon(Icons.warning, color: Colors.red) : null,
              );
            },
          )),
          if (failing.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Failing Subjects:', style: Theme.of(context).textTheme.titleMedium),
            ...failing.map((f) => Text('- ${f['name']} (Total: ${(f['totalMarks'] ?? 0)})')).toList(),
          ],
        ]),
      ),
    );
  }
}
