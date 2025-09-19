import 'dart:convert';
import 'dart:io';

// Arrow function: square(age)
int square(int x) => x * x;

// Student class
class Student {
  String name;
  int age;
  String city;
  int rollNumber;
  String department;
  List<String> hobbies;
  Set<String> subjects;

  Student({
    required this.name,
    required this.age,
    required this.city,
    required this.rollNumber,
    required this.department,
    required this.hobbies,
    required this.subjects,
  });

  bool isEligible() => age >= 18;

  void greet() {
    print("👋 Welcome $name from $city!");
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "age": age,
      "city": city,
      "rollNumber": rollNumber,
      "department": department,
      "hobbies": hobbies,
      "subjects": subjects.toList(),
      "eligible": isEligible(),
    };
  }

  void showData() {
    print("----- Student Info -----");
    print("Name: $name");
    print("Age: $age (${isEligible() ? 'Eligible' : 'Not Eligible'})");
    print("Age (squared): ${square(age)}");
    print("City: $city");
    print("Roll No: $rollNumber");
    print("Department: $department");
    print("Hobbies: ${hobbies.isEmpty ? 'None' : hobbies.join(', ')}");
    print("Subjects: ${subjects.isEmpty ? 'None' : subjects.join(', ')}");
    print("------------------------");
  }
}

// Read a non-empty line (optional)
String _readNonEmpty(String prompt) {
  while (true) {
    stdout.write(prompt);
    final s = stdin.readLineSync();
    if (s != null && s.trim().isNotEmpty) return s.trim();
    print("Please enter a value.");
  }
}

// Input student data with validation
Student inputData() {
  final name = _readNonEmpty("Enter name: ");

  int age;
  while (true) {
    stdout.write("Enter age: ");
    final line = stdin.readLineSync();
    try {
      age = int.parse(line ?? "");
      break;
    } catch (_) {
      print("❌ Invalid age. Enter a number.");
    }
  }

  final city = _readNonEmpty("Enter city: ");

  int rollNumber;
  while (true) {
    stdout.write("Enter roll number: ");
    final line = stdin.readLineSync();
    try {
      rollNumber = int.parse(line ?? "");
      break;
    } catch (_) {
      print("❌ Invalid roll number. Enter a number.");
    }
  }

  final department = _readNonEmpty("Enter department: ");

  stdout.write("Enter hobbies (comma separated, or leave empty): ");
  final hobbiesInput = stdin.readLineSync() ?? "";
  final hobbies = hobbiesInput
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  stdout.write("Enter subjects (comma separated, or leave empty): ");
  final subjectsInput = stdin.readLineSync() ?? "";
  final subjects = subjectsInput
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();

  return Student(
    name: name,
    age: age,
    city: city,
    rollNumber: rollNumber,
    department: department,
    hobbies: hobbies,
    subjects: subjects,
  );
}

void main() {
  final List<Student> students = [];

  while (true) {
    print("\n===== Student Info Manager =====");
    print("1. Add Student");
    print("2. Show All Students");
    print("3. Export Data as JSON (print)");
    print("4. Save JSON to file (students.json)");
    print("5. Search Student by Name");
    print("6. Filter by Hobby or Subject");
    print("7. Exit");
    stdout.write("Choose an option: ");
    final choice = stdin.readLineSync() ?? "";

    switch (choice.trim()) {
      case "1":
        final s = inputData();
        s.greet();
        students.add(s);
        break;

      case "2":
        if (students.isEmpty) {
          print("📭 No students found.");
        } else {
          for (var st in students) {
            st.showData();
          }
        }
        break;

      case "3":
        if (students.isEmpty) {
          print("📭 No students to export.");
        } else {
          final jsonList = students.map((s) => s.toMap()).toList();
          final jsonString = jsonEncode(jsonList);
          print("📂 JSON Export: $jsonString");
        }
        break;

      case "4":
        if (students.isEmpty) {
          print("📭 No students to save.");
        } else {
          try {
            final jsonList = students.map((s) => s.toMap()).toList();
            final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
            final file = File('students.json');
            file.writeAsStringSync(jsonString);
            print("✅ Saved to students.json");
          } catch (e) {
            print("❌ Error saving file: $e");
          }
        }
        break;

      case "5":
        stdout.write("Enter name to search: ");
        final q = (stdin.readLineSync() ?? "").toLowerCase();
        final found = students.where((s) => s.name.toLowerCase() == q).toList();
        if (found.isEmpty) {
          print("❌ Student not found.");
        } else {
          for (var f in found) f.showData();
        }
        break;

      case "6":
        print("Filter by: 1) Hobby  2) Subject");
        stdout.write("Choose 1 or 2: ");
        final t = stdin.readLineSync() ?? "";
        if (t.trim() == "1") {
          stdout.write("Enter hobby to filter by: ");
          final hobby = (stdin.readLineSync() ?? "").toLowerCase();
          final res = students.where((s) => s.hobbies.any((h) => h.toLowerCase() == hobby)).toList();
          if (res.isEmpty) print("No students with that hobby.");
          else res.forEach((s) => s.showData());
        } else if (t.trim() == "2") {
          stdout.write("Enter subject to filter by: ");
          final subject = (stdin.readLineSync() ?? "").toLowerCase();
          final res = students.where((s) => s.subjects.any((sub) => sub.toLowerCase() == subject)).toList();
          if (res.isEmpty) print("No students with that subject.");
          else res.forEach((s) => s.showData());
        } else {
          print("Invalid option.");
        }
        break;

      case "7":
        print("👋 Exiting... Goodbye!");
        return;

      default:
        print("❌ Invalid choice. Try again.");
    }
  }
 //void main() {
    // Variables
    String name = "Ali";
    int age = 20;
    String city = "Lahore";

    // Output
    print("Welcome $name from $city!");
    // Control Flow
    if (age >= 18) {
      print("You are eligible to register.");
    } else {
      print("You must be 18+ to register.");
    }
    // Collections
    List<String> hobbies = ['Reading', 'Coding', 'Music'];
    Set<String> subjects = {'Math', 'Science', 'Math'}; // Set removes duplicates
    // Map for student info
    Map<String, dynamic> student = {
      'name': name,
      'age': age,
      'city': city,
    };
    // Functions
    void greet(String name) {
      print("Hello, $name!");
    }
    int square(int x) => x * x;
    // Function Calls
    greet(name);
    print("Your age squared is: ${square(age)}");
  }//