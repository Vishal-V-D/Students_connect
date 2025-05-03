import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class AssignmentDetailPage extends StatelessWidget {
  const AssignmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {
      "Top Score": 3,
      "Lower Performamce": 2,
    };
final Map<String, double> taskData = const {
    "Completed": 3,
    "Pending": 2,
    "In Progress": 1,
    "Not Started": 5,
  };
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignment Details"),
        backgroundColor: Colors.grey, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: const [
                  Icon(Icons.assignment_turned_in, color: Colors.teal),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Assignment 2: Data Structures and Algorithms",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              sectionHeader(Icons.info, "Overview:"),
              const Text(
                "This assignment focuses on implementing core data structures like Linked Lists, Stacks, and Queues, with a report on their time complexities.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              sectionHeader(Icons.task_alt, "Tasks to Complete:"),
              const TaskItem(task: "1. Singly linked list with insert, delete, search"),
              const TaskItem(task: "2. Stack using arrays and linked list"),
              const TaskItem(task: "3. Queue using circular arrays"),
              const TaskItem(task: "4. Reverse linked list (iterative & recursive)"),
              const TaskItem(task: "5. Submit code and report with screenshots"),
              const SizedBox(height: 20),

              sectionHeader(Icons.timeline, "Assignment Progress:"),
              const SizedBox(height: 10),
              PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 2.5,
                colorList: [Colors.green, Colors.orange],
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                ),
              ),
              const SizedBox(height: 20),
 const SizedBox(height: 20),

              // Pie Chart
              const Text(
                "Progress Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              PieChart(
                dataMap: taskData,
                chartRadius: MediaQuery.of(context).size.width / 2.2,
                colorList: [const Color.fromARGB(255, 109, 238, 245), const Color.fromARGB(255, 251, 247, 24),const Color.fromARGB(255, 24, 192, 114),const Color.fromARGB(255, 187, 21, 162)],
                chartType: ChartType.ring,
                ringStrokeWidth: 24,
                animationDuration: const Duration(seconds: 1),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: true,
                ),
              ),
              const SizedBox(height: 30),

              sectionHeader(Icons.calendar_today, "Submission Deadline:"),
              const Text(
                "Monday, 6th May 2025 - 11:59 PM",
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              const SizedBox(height: 20),

              sectionHeader(Icons.rule, "Instructions:"),
              const Text("• Submit zipped folder with code + report"),
              const Text("• Use only C++ or Python"),
              const Text("• Add screenshots of outputs"),
              const Text("• No plagiarism allowed"),
              const Text("• Report should explain logic and complexity"),
              const SizedBox(height: 20),

              sectionHeader(Icons.menu_book, "Recommended References:"),
              const Text("• Data Structures and Algorithms - Karumanchi"),
              const Text("• GeeksforGeeks.org"),
              const Text("• Visualgo.net for animations"),
              const Text("• LeetCode DSA Practice"),
              const SizedBox(height: 30),

              sectionHeader(Icons.person, "Faculty Coordinator:"),
              const Text("Dr. Priya Sharma"),
              const Text("Email: priya.sharma@univ.edu"),
              const Text("Office Hours: Mon–Fri, 3 PM – 5 PM"),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final String task;
  const TaskItem({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(task, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
