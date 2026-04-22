import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('صباعي'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, 'ملفي', Icons.person, '/profile'),
            _buildCard(context, 'دردشة', Icons.chat, '/chat'),
            _buildCard(context, 'غرف', Icons.meeting_room, '/rooms'),
            _buildCard(context, 'العاب', Icons.games, '/games'),
            _buildCard(context, 'منشورات', Icons.article, '/posts'),
            _buildCard(context, 'ابلاغي', Icons.report, '/reports'),
          ],
        ),
      ),
      bottomNavigationBar: user!= null 
         ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('مسجل دخول: ${user.email}', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          : null,
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.push(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF6A1B9A)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
