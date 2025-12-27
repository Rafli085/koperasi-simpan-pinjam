import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventAdminPage extends StatefulWidget {
  const EventAdminPage({super.key});

  @override
  State<EventAdminPage> createState() => _EventAdminPageState();
}

class _EventAdminPageState extends State<EventAdminPage> {
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
      print('Admin events response: $response');
      
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
        title: const Text('Kelola Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateEventDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : events.isEmpty
                ? const Center(child: Text('Belum ada event'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  event.type == 'poll' ? Icons.poll : Icons.announcement,
                                  color: event.type == 'poll' ? Colors.blue : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    event.type == 'poll' ? 'Polling' : 'Pengumuman',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: event.type == 'poll' 
                                      ? Colors.blue[100] 
                                      : Colors.orange[100],
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 16, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Hapus', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditEventDialog(event);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(event);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(event.description),
                            const SizedBox(height: 8),
                            if (event.type == 'poll' && event.pollOptions != null) ...[
                              const Text(
                                'Opsi Polling:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              ...event.pollOptions!.map((option) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 6),
                                    const SizedBox(width: 8),
                                    Text('${option.text} (${option.votes} suara)'),
                                  ],
                                ),
                              )),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Dibuat: ${_formatDate(event.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (event.endDate != null) ...[
                                  const SizedBox(width: 16),
                                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Berakhir: ${_formatDate(event.endDate!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateEventDialog(),
    ).then((result) {
      if (result == true) {
        _loadEvents();
      }
    });
  }

  void _showEditEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => EditEventDialog(event: event),
    ).then((result) {
      if (result == true) {
        _loadEvents();
      }
    });
  }

  void _showDeleteConfirmation(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Event'),
        content: Text('Yakin ingin menghapus event "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await ApiService.deleteEvent(event.id!);
              if (response['success']) {
                _loadEvents();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'])),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'announcement';
  DateTime? _endDate;
  final List<TextEditingController> _pollOptionControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addPollOption();
    _addPollOption();
  }

  void _addPollOption() {
    setState(() {
      _pollOptionControllers.add(TextEditingController());
    });
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length > 2) {
      setState(() {
        _pollOptionControllers[index].dispose();
        _pollOptionControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Event Baru'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Event',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Event',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'announcement', child: Text('Pengumuman')),
                    DropdownMenuItem(value: 'poll', child: Text('Polling')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                if (_selectedType == 'poll') ...[
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('Tanggal Berakhir: ${_endDate != null ? _formatDate(_endDate!) : 'Belum dipilih'}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectEndDate,
                  ),
                  const SizedBox(height: 16),
                  const Text('Opsi Polling:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ..._pollOptionControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Opsi ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Opsi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_pollOptionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removePollOption(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addPollOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Opsi'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createEvent,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Buat Event'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == 'poll' && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal berakhir untuk polling')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pollOptions = _selectedType == 'poll'
          ? _pollOptionControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList()
          : null;

      final response = await ApiService.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        endDate: _endDate,
        pollOptions: pollOptions,
      );

      if (response['success']) {
        Navigator.pop(context, true);
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
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _pollOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class EditEventDialog extends StatefulWidget {
  final Event event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _endDate = widget.event.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Event',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              if (widget.event.type == 'poll') ...[
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Tanggal Berakhir: ${_endDate != null ? _formatDate(_endDate!) : 'Belum dipilih'}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectEndDate,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateEvent,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateEvent(
        eventId: widget.event.id!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        endDate: _endDate,
      );

      if (response['success']) {
        Navigator.pop(context, true);
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
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
  }
}