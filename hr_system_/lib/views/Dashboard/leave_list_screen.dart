import 'package:flutter/material.dart';
import 'package:hr_system_/models/Dashboard/leave_request_list_model.dart';
import '../../controllers/Dashboard/leave_list_controller.dart';
import '../employee_nav_bar.dart';

class LeavesListView extends StatefulWidget {
  const LeavesListView({Key? key}) : super(key: key);

  @override
  State<LeavesListView> createState() => _LeavesListViewState();
}

class _LeavesListViewState extends State<LeavesListView> {
  final controller = LeaveListController();

  late Future<List<LeaveRequestModel>> futureRequests;
  int _selectedIndex = 1;

  String selectedSort = 'startDate-desc';

  final sortOptions = {
    'startDate-asc': 'Start Date ↑',
    'startDate-desc': 'Start Date ↓',
    'endDate-asc': 'End Date ↑',
    'endDate-desc': 'End Date ↓',
    'leaveType-asc': 'Leave Type ↑',
    'leaveType-desc': 'Leave Type ↓',
    'status-asc': 'Status ↑',
    'status-desc': 'Status ↓',
  };

  @override
  void initState() {
    super.initState();
    _refreshRequests();
  }

  void _refreshRequests() {
    final parts = selectedSort.split('-');
    final sortBy = parts[0];
    final order = parts[1];

    setState(() {
      futureRequests = controller.fetchLeaveRequests(
        sortBy: sortBy,
        order: order,
      );
    });
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade500;
      case 'rejected':
        return Colors.red.shade400;
      case 'pending':
      default:
        return Colors.orange.shade600;
    }
  }

  IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline;
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        String tempSelection = selectedSort;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text("Sort Options"),
          content: DropdownButtonFormField<String>(
            value: tempSelection,
            dropdownColor: Colors.white,

            items:
                sortOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
            onChanged: (val) {
              if (val != null) {
                tempSelection = val;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedSort = tempSelection;
                  _refreshRequests();
                });
                Navigator.pop(ctx);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${_weekdayName(now.weekday)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.blueGrey.shade600),
                    tooltip: "Sort",
                    onPressed: _showSortDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<LeaveRequestModel>>(
                future: futureRequests,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No leave requests found.",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 17,
                        ),
                      ),
                    );
                  }
                  final requests = snapshot.data!;
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final req = requests[i];
                      return _leaveCard(req);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _leaveCard(LeaveRequestModel req) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showDetailsDialog(req),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.blue.shade50,
                child: Icon(
                  Icons.event_note,
                  color: Colors.blue.shade600,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.leaveType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 15,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${_formatDate(req.startDate)} - ${_formatDate(req.endDate)}",
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (req.comments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.message,
                              size: 15,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                req.comments,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade500,
                                  fontSize: 13.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          statusIcon(req.status),
                          color: statusColor(req.status),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          req.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: statusColor(req.status),
                            fontSize: 14.5,
                          ),
                        ),
                        if (req.documentUrl != null &&
                            req.documentUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => Dialog(
                                        child: Image.network(
                                          "http://192.168.1.128/${req.documentUrl}",
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image,
                                                size: 54,
                                              ),
                                        ),
                                      ),
                                );
                              },
                              child: Icon(
                                Icons.attach_file,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(LeaveRequestModel req) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("Request Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowDetail("Leave Type", req.leaveType),
                _rowDetail("From", _formatDate(req.startDate)),
                _rowDetail("To", _formatDate(req.endDate)),
                _rowDetail("Status", req.status),
                if (req.comments.isNotEmpty)
                  _rowDetail("Comment", req.comments),
                if (req.documentUrl != null && req.documentUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        "http://192.168.1.128/${req.documentUrl}",
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 70),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _rowDetail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String _weekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }
}
