import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search pets, records, and more',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.mic,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            // Grid section
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildCard(
                    title: 'Add Pet',
                    color: Colors.green[400]!,
                    icon: Icons.pets,
                  ),
                  _buildCard(
                    title: 'Vaccines',
                    color: Colors.purple[400]!,
                    icon: Icons.vaccines,
                  ),
                  _buildCard(
                    title: 'Deworming',
                    color: Colors.blue[400]!,
                    icon: Icons.medication_outlined,
                  ),
                  _buildCard(
                    title: 'Appointments',
                    color: Colors.orange[400]!,
                    icon: Icons.calendar_month,
                  ),
                  _buildCard(
                    title: 'Health Records',
                    color: Colors.teal[400]!,
                    icon: Icons.folder_shared,
                  ),
                  _buildCard(
                    title: 'Diet Planner',
                    color: Colors.amber[400]!,
                    icon: Icons.restaurant_menu,
                  ),
                  _buildCard(
                    title: 'Medications',
                    color: Colors.red[400]!,
                    icon: Icons.medical_services,
                  ),
                  _buildCard(
                    title: 'Activities',
                    color: Colors.lightBlue[400]!,
                    icon: Icons.directions_run,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required Color color, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: Icon(
              icon,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
