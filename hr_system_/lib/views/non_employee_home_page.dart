import 'package:flutter/material.dart';

class NonEmployeeHomeScreen extends StatelessWidget {
  const NonEmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "HELLO",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "ARE YOU READY TO FIND YOUR JOB?",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Jobs Available
              const Text(
                "Jobs Available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _jobCard(
                title: "Java Developer",
                level: "Mid-Senior",
                desc:
                    "We Are Seeking An Experienced Senior Java Developer To Join Our Team And Play A Key Role In Designing, Developing, And Maintaining High-Performance, Scalable Applications",
                location: "Amman - Jordan",
                type: "Full-time / On Site",
              ),
              const SizedBox(height: 12),

              _jobCard(
                title: "Social Media Manager",
                level: "Mid-Senior",
                desc:
                    "We Are Seeking An Experienced Social Media Manager To Join Our Team And Play A Key Role In Strategy, Content Creation, And Campaign Execution",
                location: "Amman - Jordan",
                type: "Full-time / On Site",
              ),

              const SizedBox(height: 24),

              // Upcoming Interview
              const Text(
                "Upcoming Interview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "After The HR Review Your CV And Test Results They Booked This Interview So Make Sure You Attended",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Senior Accountant Interview",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("📅 4.09.2025, THU"),
                    const Text("⏰ 9:00 AM"),
                    const Text("💻 Google Meet"),
                    const Text("🔗 www.Linkqadi.com//"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("Contact"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text("Confirm Your Attendance"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: "JOBS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: "NOTIFY",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "PROFILE",
          ),
        ],
      ),
    );
  }

  Widget _jobCard({
    required String title,
    required String level,
    required String desc,
    required String location,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("Show Details")),
            ],
          ),
          Text(level, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Text("📍 $location"),
          Text("💼 Employment Type: $type"),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(onPressed: () {}, child: const Text("Share")),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
