import 'package:flutter/material.dart';
import '../services/out_of_office_service.dart';
import '../models/out_of_office.dart';

class OutOfOfficeScreen extends StatefulWidget {
  const OutOfOfficeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OutOfOfficeScreenState createState() => _OutOfOfficeScreenState();
}

class _OutOfOfficeScreenState extends State<OutOfOfficeScreen> {
  List<OutOfOffice> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final data = await OutOfOfficeService.getMyRequests();
    setState(() {
      requests = data;
      loading = false;
    });
  }

  void _showApplyModal() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OutOfOfficeApplyForm(),
    );
    if (result == true) {
      _fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Out of Office',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyModal,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'New Request',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading requests...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : requests.isEmpty
                ? _buildEmptyState()
                : _buildRequestsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No out of office requests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the button below to create your first request',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final req = requests[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        req.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _statusBadge(req.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req.reason,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      req.date.toLocal().toString().split(' ')[0],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(int status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case 0:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 1:
        color = Colors.green;
        text = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case 2:
        color = Colors.red;
        text = 'Declined';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class OutOfOfficeApplyForm extends StatefulWidget {
  const OutOfOfficeApplyForm({super.key});

  @override
  State<OutOfOfficeApplyForm> createState() => _OutOfOfficeApplyFormState();
}

class _OutOfOfficeApplyFormState extends State<OutOfOfficeApplyForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String reason = '';
  DateTime? date;
  bool loading = false;
  String? dateError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const Text(
                'New Out of Office Request',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Vacation, Sick Leave, Personal Day',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (v) => title = v,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Brief description of your request',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                onChanged: (v) => reason = v,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a reason' : null,
              ),
              
              const SizedBox(height: 20),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: dateError != null ? Colors.red : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: dateError != null ? Colors.red : Colors.grey[600],
                  ),
                  title: Text(
                    date == null ? 'Select Date' : date!.toLocal().toString().split(' ')[0],
                    style: TextStyle(
                      color: dateError != null ? Colors.red : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: date == null 
                      ? Text(
                          'Tap to choose your out of office date',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        date = picked;
                        dateError = null;
                      });
                    }
                  },
                ),
              ),
              
              if (dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    dateError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 52,
                child: loading
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Submitting request...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          print('Apply button pressed');
                          if (!_formKey.currentState!.validate() || date == null) {
                            print('Form not valid or date not picked');
                            setState(() {
                              dateError = date == null ? 'Please select a date.' : null;
                            });
                            if (date == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please select a date.'),
                                  backgroundColor: Colors.red[600],
                                ),
                              );
                            }
                            return;
                          }
                          setState(() => loading = true);
                          final success = await OutOfOfficeService.apply(title, reason, date!);
                          setState(() => loading = false);
                          if (success) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Request submitted successfully!'),
                                backgroundColor: Colors.green[600],
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to submit request. Please try again.'),
                                backgroundColor: Colors.red[600],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
              ),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}