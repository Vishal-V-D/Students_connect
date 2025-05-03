import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:students_connect/screens/assigemnt.dart';
import 'package:students_connect/screens/dates.dart';
import 'package:students_connect/screens/profile_page.dart';

class DashboardClone extends StatelessWidget {
  const DashboardClone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.grey,
        title: const Text(" Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle,size: 30,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile Image and Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                 
                ],
              ),
              const SizedBox(height: 20),

              // Exam Performance Section
              Text("EXAM PERFORMANCE", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.science, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text("Semester 4", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Text("35/40 (+4)", style: TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3.5),
                          FlSpot(1, 4),
                          FlSpot(2, 4.5),
                          FlSpot(3, 5),
                          FlSpot(4, 4.8),
                          FlSpot(5, 5.1),
                        ],
                        isCurved: true,
                        dotData: FlDotData(show: true),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Assignment Performance Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AssignmentDetailPage()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[100],
                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3), spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ASSIGNMENT PERFORMANCE", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text("Homework_022 - 25 May 2023 at 3:30PM"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("Evaluation Complete", style: TextStyle(color: Colors.white)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("A+", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subject-Based Stats with a Bar Chart
              Text("SUBJECT STATISTICS", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 10),
              Container(
                height: 220,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                    border: Border.all(
    color: const Color.fromARGB(255, 9, 9, 9),  // Choose your border color here
    width: 1,  // Set the border width
  ),
                  color: Colors.blue[50],
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3), spreadRadius: 2),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(show: true),
                barGroups: [
  BarChartGroupData(
    x: 0,
    barRods: [
      BarChartRodData(
        fromY: 0, // Start of the bar
        toY: 8,   // End of the bar
        color: Colors.blue,
      ),
    ],
  ),
  BarChartGroupData(
    x: 1,
    barRods: [
      BarChartRodData(
        fromY: 0, // Start of the bar
        toY: 7,   // End of the bar
        color: Colors.green,
      ),
    ],
  ),
  BarChartGroupData(
    x: 2,
    barRods: [
      BarChartRodData(
        fromY: 0, // Start of the bar
        toY: 6,   // End of the bar
        color: Colors.red,
      ),
    ],
  ),
  BarChartGroupData(
    x: 3,
    barRods: [
      BarChartRodData(
        fromY: 0, // Start of the bar
        toY: 9,   // End of the bar
        color: Colors.orange,
      ),
    ],
  ),
],


                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Syllabus & Dates to Remember with Navigation
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SyllabusDetailPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
    color: const Color.fromARGB(255, 33, 34, 35),  // Choose your border color here
    width: 1,  // Set the border width
  ),
 
                          boxShadow: [
                            BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3), spreadRadius: 2),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Text("SYLLABUS COVERAGE", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("92%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("Data Structures by Prof. Sharma", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DatesToRememberPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
    color: const Color.fromARGB(255, 67, 70, 72),  // Choose your border color here
    width: 1,  // Set the border width
  ),
 
                          boxShadow: [
                            BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3), spreadRadius: 2),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text("DATES TO REMEMBER", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Text("M"), Text("T"), Text("W"), Text("T"), Text("F"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Text("26"), Text("27"), Text("28"), Text("29"), Text("30"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                CircleAvatar(radius: 4, backgroundColor: Colors.blue),
                                SizedBox(width: 5),
                                Text("Assignments"),
                              ],
                            ),
                            Row(
                              children: const [
                                CircleAvatar(radius: 4, backgroundColor: Colors.purple),
                                SizedBox(width: 5),
                                Text("Exams"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Assignment Detail Page


// Syllabus Detail Page
class SyllabusDetailPage extends StatelessWidget {
  const SyllabusDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Syllabus Details"),
      backgroundColor: Colors.grey, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Syllabus Overview
              const Text(
                "Syllabus Overview",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 4, 4),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "This course covers topics in Data Structures, Algorithms, and their practical applications in computer science. "
                "The syllabus includes theoretical learning and hands-on coding exercises.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Course Modules
              const Text(
                "Course Modules",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 10),

              // List of modules
              ModuleTile(
                title: "Introduction to Data Structures",
                duration: "Week 1 - Week 2",
                description:
                    "Learn about the basic data structures such as arrays, linked lists, and stacks.",
              ),
              ModuleTile(
                title: "Sorting and Searching Algorithms",
                duration: "Week 3 - Week 4",
                description:
                    "Study sorting algorithms (Quick Sort, Merge Sort) and searching algorithms (Binary Search).",
              ),
              ModuleTile(
                title: "Trees and Graphs",
                duration: "Week 5 - Week 6",
                description:
                    "Understand trees and graph structures, along with traversal techniques like BFS and DFS.",
              ),
              ModuleTile(
                title: "Dynamic Programming and Greedy Algorithms",
                duration: "Week 7 - Week 8",
                description:
                    "Explore dynamic programming and greedy algorithms for solving optimization problems.",
              ),
              ModuleTile(
                title: "Advanced Data Structures",
                duration: "Week 9 - Week 10",
                description:
                    "Learn about advanced data structures like heaps, tries, and balanced binary trees.",
              ),
              const SizedBox(height: 20),

              // Important Dates
              const Text(
                "Important Dates",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 10),

              // Date and Event List
              DateTile(
                date: "1st May 2023",
                event: "Assignment 1 Submission Deadline",
              ),
              DateTile(
                date: "15th May 2023",
                event: "Midterm Exam",
              ),
              DateTile(
                date: "25th May 2023",
                event: "Assignment 2 Submission Deadline",
              ),
              DateTile(
                date: "5th June 2023",
                event: "Final Exam",
              ),
              const SizedBox(height: 20),

              // Resources Section
              const Text(
                "Resources",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 2, 2, 2),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "1. Data Structures Book by Author X\n"
                "2. Online Coding Platform for Practice\n"
                "3. Lecture Notes Available on the Portal\n"
                "4. Algorithm Visualizer Tools",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Notes Section
              const Text(
                "Notes and Announcements",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 38, 39),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "• Ensure you review the material before each lecture.\n"
                "• Practice coding problems regularly to improve your skills.\n"
                "• Keep up with the deadlines for assignments and exams.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Module Tile for displaying course modules
class ModuleTile extends StatelessWidget {
  final String title;
  final String duration;
  final String description;

  const ModuleTile({
    required this.title,
    required this.duration,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            duration,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Date Tile for displaying important dates (FIXED overflow issue)
class DateTile extends StatelessWidget {
  final String date;
  final String event;

  const DateTile({
    required this.date,
    required this.event,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Dates to Remember Page
