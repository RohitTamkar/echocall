import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echocall/services/firebase_service.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/ui/components/call_list_item.dart';

class FirebaseLogsPage extends StatefulWidget {
  const FirebaseLogsPage({super.key});

  @override
  State<FirebaseLogsPage> createState() => _FirebaseLogsPageState();
}

class _FirebaseLogsPageState extends State<FirebaseLogsPage> {
  final ScrollController _scrollCtrl = ScrollController();
  final List<CallEntryModel> _logs = [];
  final FirebaseService _firebaseService = FirebaseService();

  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200 &&
          !_loading &&
          _hasMore) {
        _fetchLogs();
      }
    });
  }

  Future<void> _fetchLogs() async {
    if (_loading) return;
    setState(() => _loading = true);

    await _firebaseService.tryInit();
    if (!_firebaseService.isAvailable) {
      setState(() => _loading = false);
      return;
    }

    Query query = FirebaseFirestore.instance
        .collection("CALL_LOGS")
        .orderBy("timestamp", descending: true)
        .limit(20);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    try {
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;

        // 🔄 Convert each Firestore doc into CallEntryModel
        final newLogs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CallEntryModel.fromMap(data);
        }).toList();

        _logs.addAll(newLogs);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Call Logs")),
      body: _logs.isEmpty && !_loading
          ? const Center(child: Text("No logs found"))
          : ListView.builder(
        controller: _scrollCtrl,
        itemCount: _logs.length + 1,
        itemBuilder: (context, index) {
          if (index == _logs.length) {
            return _loading
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox.shrink();
          }

          final entry = _logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: CallListItem(
              entry: entry,
              onTap: () {
                // 👉 here you can open details if needed
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(entry.number),
                    content: Text(
                        "Direction: ${entry.direction.name}\n"
                            "Duration: ${entry.durationSeconds}s\n"
                            "SIM: ${entry.simLabel ?? '-'}"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
