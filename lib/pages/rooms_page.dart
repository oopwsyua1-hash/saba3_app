import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../main.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _roomNameController = TextEditingController();
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
        .from('rooms')
        .select()
        .order('created_at', ascending: false);
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createRoom() async {
    final name = _roomNameController.text.trim();
    if (name.isEmpty) return;

    try {
      await supabase.from('rooms').insert({
        'name': name,
        'created_by': supabase.auth.currentUser!.id,
      });
      _roomNameController.clear();
      _fetchRooms(); // حدث اللستة
      if (mounted) Navigator.of(context).pop(); // سكر الدايلوغ
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل انشاء الغرفة'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انشاء غرفة جديدة'),
        content: TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(hintText: 'اسم الغرفة'),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: _createRoom,
            child: const Text('انشاء'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الغرف')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
            ? const Center(child: Text('لا يوجد غرف بعد. كن اول من ينشئ غرفة!'))
              : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    final time = timeago.format(DateTime.parse(room['created_at']), locale: 'ar');
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.meeting_room, color: Color(0xFF6A1B9A)),
                        title: Text(room['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('انشئت $time'),
                        onTap: () {
                          // هون منضيف دخول الغرفة بعدين
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('رح ندخل غرفة ${room['name']} قريباً')),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add),
      ),
    );
  }
}
