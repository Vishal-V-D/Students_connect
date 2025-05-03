import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatesToRememberPage extends StatefulWidget {
  const DatesToRememberPage({super.key});

  @override
  State<DatesToRememberPage> createState() => _DatesToRememberPageState();
}

class _DatesToRememberPageState extends State<DatesToRememberPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();

  final Map<DateTime, DateItem> dateToItem = {
    DateTime(2025, 5, 6): DateItem(
      title: "📘 Mid-Term Exam Week",
      description: "6th May – 11th May | Covers Units 1–3 of all core subjects.",
      icon: Icons.school,
      color: Colors.blueAccent,
    ),
    DateTime(2025, 5, 15): DateItem(
      title: "📤 Project Submission Deadline",
      description: "15th May | Final year students must upload to project portal.",
      icon: Icons.upload_file,
      color: Colors.deepPurple,
    ),
    DateTime(2025, 5, 18): DateItem(
      title: "🧪 Open Day (Project Expo)",
      description: "18th May | Invite industry professionals and parents.",
      icon: Icons.event_available,
      color: Colors.orange,
    ),
    DateTime(2025, 5, 20): DateItem(
      title: "📊 Internal Marks Publication",
      description: "20th May | Check student portal for scores.",
      icon: Icons.bar_chart,
      color: Colors.teal,
    ),
    DateTime(2025, 5, 25): DateItem(
      title: "📝 Semester Exams Start",
      description: "25th May onwards | Final exams – All departments.",
      icon: Icons.edit_calendar,
      color: Colors.redAccent,
    ),
    DateTime(2025, 6, 5): DateItem(
      title: "💼 Placement Training Begins",
      description: "From 5th June | Aptitude, coding, group discussion sessions.",
      icon: Icons.computer,
      color: Colors.indigo,
    ),
    DateTime(2025, 6, 10): DateItem(
      title: "🏢 Company Visit: TCS & Infosys",
      description: "10th June | Pre-placement talk & registration drive.",
      icon: Icons.business_center,
      color: Colors.pinkAccent,
    ),
    DateTime(2025, 7, 10): DateItem(
      title: "📅 Next Semester Reopening",
      description: "10th July 2025 (Tentative) | New timetable release expected.",
      icon: Icons.calendar_today,
      color: Colors.green,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final sortedDates = dateToItem.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Important Dates & Events"),
        backgroundColor: Colors.grey, 
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2024),
            lastDay: DateTime(2026),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              int index = sortedDates.indexWhere((d) =>
                  d.year == selectedDay.year &&
                  d.month == selectedDay.month &&
                  d.day == selectedDay.day);

              if (index != -1) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _scrollController.animateTo(
                    index * 150.0, // Updated multiplier to match item height
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                });
              }
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final item = dateToItem[date]!;

                return Card(
                  color: item.color.withOpacity(0.1),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.color,
                      child: Icon(item.icon, color: Colors.white),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DateItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const DateItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
