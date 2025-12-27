import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventAnggotaPage extends StatefulWidget {
  final int userId;

  const EventAnggotaPage({super.key, required this.userId});

  @override
  State<EventAnggotaPage> createState() => _EventAnggotaPageState();
}

class _EventAnggotaPageState extends State<EventAnggotaPage> {
  List<Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getEvents();
      print('Events response: $response');
      
      if (response is List) {
        final eventList = <Event>[];
        for (var eventData in response) {
          try {
            if (eventData is Map<String, dynamic>) {
              eventList.add(Event.fromJson(eventData));
            }
          } catch (e) {
            print('Error parsing individual event: $e');
            print('Event data: $eventData');
          }
        }
        setState(() {
          events = eventList;
          isLoading = false;
        });
      } else {
        throw Exception('Response is not a list: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error loading events: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event & Pengumuman'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : events.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada event atau pengumuman'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: event.type == 'poll' 
                                        ? Colors.blue[100] 
                                        : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        event.type == 'poll' ? Icons.poll : Icons.announcement,
                                        size: 16,
                                        color: event.type == 'poll' ? Colors.blue : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.type == 'poll' ? 'Polling' : 'Pengumuman',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: event.type == 'poll' ? Colors.blue : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(event.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (event.type == 'poll') ...[
                              const SizedBox(height: 16),
                              _buildPollSection(event),
                            ],
                            if (event.endDate != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isEventExpired(event.endDate!) 
                                      ? Colors.red[100] 
                                      : Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isEventExpired(event.endDate!) 
                                          ? Icons.event_busy 
                                          : Icons.event_available,
                                      size: 16,
                                      color: _isEventExpired(event.endDate!) 
                                          ? Colors.red 
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isEventExpired(event.endDate!) 
                                          ? 'Berakhir: ${_formatDate(event.endDate!)}' 
                                          : 'Berakhir: ${_formatDate(event.endDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isEventExpired(event.endDate!) 
                                            ? Colors.red 
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildPollSection(Event event) {
    if (event.pollOptions == null) return const SizedBox();

    final hasVoted = event.userVotes?.containsKey(widget.userId) ?? false;
    final userVote = event.userVotes?[widget.userId];
    final isExpired = event.endDate != null && _isEventExpired(event.endDate!);
    final totalVotes = event.pollOptions!.fold(0, (sum, option) => sum + option.votes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pilihan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(event.userVotes?.length ?? 0)} orang memilih',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...event.pollOptions!.map((option) {
          final isSelected = userVote == option.id;
          final percentage = totalVotes > 0 ? (option.votes / totalVotes) * 100 : 0.0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: (!hasVoted && !isExpired) ? () => _voteOnPoll(event.id!, option.id!) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? Colors.blue[50] : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.text,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.blue[700] : null,
                            ),
                          ),
                        ),
                        if (hasVoted || isExpired) ...[
                          Text(
                            '${option.votes} suara',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                          ],
                        ],
                      ],
                    ),
                    if (hasVoted || isExpired) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSelected ? Colors.blue : Colors.grey[400]!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
        if (!hasVoted && !isExpired) ...[
          const SizedBox(height: 8),
          Text(
            'Tap pada pilihan untuk memberikan suara',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else if (isExpired) ...[
          const SizedBox(height: 8),
          Text(
            'Polling telah berakhir',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Terima kasih telah memberikan suara!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isEventExpired(DateTime endDate) {
    return DateTime.now().isAfter(endDate);
  }

  Future<void> _voteOnPoll(int eventId, int optionId) async {
    try {
      final response = await ApiService.voteOnPoll(eventId, widget.userId, optionId);
      
      if (response['success']) {
        _loadEvents(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memberikan suara')),
      );
    }
  }
}