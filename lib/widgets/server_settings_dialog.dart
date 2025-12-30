import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  final _controller = TextEditingController();
  bool _isLoading = true;
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
  }

  Future<void> _loadCurrentIp() async {
    final currentIp = await SettingsService.getServerIp();
    _controller.text = currentIp;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      // Simpan IP sementara untuk test
      final originalIp = await SettingsService.getServerIp();
      await SettingsService.setServerIp(_controller.text.trim());
      
      // Test koneksi dengan memanggil API
      final users = await ApiService.getUsers();
      
      // Kembalikan IP asli jika test gagal
      if (users.isEmpty) {
        await SettingsService.setServerIp(originalIp);
        setState(() {
          _testResult = 'Koneksi gagal - Server tidak merespon';
        });
      } else {
        setState(() {
          _testResult = 'Koneksi berhasil - Ditemukan ${users.length} user';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Koneksi gagal - Error: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pengaturan Server'),
      content: _isLoading
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Masukkan IP Address server:'),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'IP Address',
                    hintText: '192.168.1.100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    child: _isTesting
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Testing...'),
                            ],
                          )
                        : const Text('Test Koneksi'),
                  ),
                ),
                if (_testResult != null)
                  const SizedBox(height: 8),
                if (_testResult != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _testResult!.contains('berhasil')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _testResult!.contains('berhasil')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        color: _testResult!.contains('berhasil')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            await SettingsService.resetServerIp();
            Navigator.pop(context, true);
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final ip = _controller.text.trim();
                  if (ip.isNotEmpty) {
                    await SettingsService.setServerIp(ip);
                    Navigator.pop(context, true);
                  }
                },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}