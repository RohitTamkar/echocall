import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:echocall/models/call_log.dart';
import 'package:echocall/services/call_log_service.dart';
import 'package:echocall/services/export_service.dart';
import 'package:echocall/theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final CallLogService _callLogService = CallLogService();
  final TextEditingController _nameSearchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<CallLog> _allCallLogs = [];
  List<CallLog> _filteredCallLogs = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String _selectedDepartment = '';
  String _selectedDirection = '';
  DateTime? _startDate;
  DateTime? _endDate;

    final List<String> _departments = ['', "Software", "Account", "Sales","Software Support","Hardware Support","HR"];
  final List<String> _directions = ['', 'incoming', 'outgoing'];

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _callLogService.getFilteredCallLogs();
      setState(() {
        _allCallLogs = logs;
        _filteredCallLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load call logs: $e');
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _callLogService.getFilteredCallLogs(
        startDate: _startDate,
        endDate: _endDate,
        nameFilter: _nameSearchController.text.trim(),
        departmentFilter: _selectedDepartment.isEmpty ? null : _selectedDepartment,
        directionFilter: _selectedDirection.isEmpty ? null : _selectedDirection,
      );
      setState(() {
        _filteredCallLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to apply filters: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _nameSearchController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _selectedDepartment = '';
      _selectedDirection = '';
      _startDate = null;
      _endDate = null;
      _filteredCallLogs = _allCallLogs;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(date);
        } else {
          _endDate = date;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(date);
        }
      });
    }
  }

  Future<void> _exportToPdf() async {
    setState(() => _isExporting = true);
    try {
      await ExportService.exportToPdf(_filteredCallLogs);
      _showSuccess('PDF exported successfully');
    } catch (e) {
      _showError('Failed to export PDF: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      await ExportService.exportToExcel(_filteredCallLogs);
      _showSuccess('Excel exported successfully');
    } catch (e) {
      _showError('Failed to export Excel: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: LightModeColors.dashboardDanger),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: LightModeColors.dashboardSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightModeColors.dashboardSidebarBackground,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildFiltersSection(),
            const SizedBox(height: 24),
            // Constrain table height to allow vertical scrolling
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // adjust as needed
              child: _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: LightModeColors.lightAppBarBackground,
      elevation: 0,
      title: Text(
        'Admin Dashboard',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: LightModeColors.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else ...[
          // const SizedBox(width: 16),
          _buildExportButton(Icons.picture_as_pdf, 'Export PDF', _exportToPdf),
          const SizedBox(width: 16),
          // _buildExportButton(Icons.table_view, 'Export Excel', _exportToExcel),
          // const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildExportButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18,color: Colors.white),
        label: Text(tooltip.split(' ').last),
        style: ElevatedButton.styleFrom(
          backgroundColor: LightModeColors.lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }


  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightModeColors.dashboardCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightModeColors.dashboardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          'Filters',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: LightModeColors.lightOnSurface,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(24),
        backgroundColor: LightModeColors.dashboardCardBackground,
        collapsedIconColor: LightModeColors.lightOnSurface,
        iconColor: LightModeColors.lightPrimary,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200,
                child: _buildTextField(
                  controller: _nameSearchController,
                  label: 'Search by Name/Number',
                  prefixIcon: Icons.search,
                ),
              ),
              SizedBox(
                width: 160,
                child: _buildDateField(
                  controller: _startDateController,
                  label: 'Start Date',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(
                width: 160,
                child: _buildDateField(
                  controller: _endDateController,
                  label: 'End Date',
                  onTap: () => _selectDate(context, false),
                ),
              ),
              SizedBox(
                width: 140,
                child: _buildDropdown(
                  value: _selectedDepartment,
                  label: 'Department',
                  items: _departments,
                  onChanged: (value) =>
                      setState(() => _selectedDepartment = value ?? ''),
                ),
              ),
              SizedBox(
                width: 140,
                child: _buildDropdown(
                  value: _selectedDirection,
                  label: 'Direction',
                  items: _directions,
                  onChanged: (value) =>
                      setState(() => _selectedDirection = value ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_list, size: 18,color: Colors.white),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightModeColors.lightPrimary,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightModeColors.lightOnSurface,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Widget _buildFiltersSection() {
  //   return Container(
  //     margin: const EdgeInsets.all(24),
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: LightModeColors.dashboardCardBackground,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: LightModeColors.dashboardBorder),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Filters',
  //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //             fontWeight: FontWeight.w600,
  //             color: LightModeColors.lightOnSurface,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Wrap(
  //           spacing: 16,
  //           runSpacing: 16,
  //           children: [
  //             SizedBox(
  //               width: 200,
  //               child: _buildTextField(
  //                 controller: _nameSearchController,
  //                 label: 'Search by Name/Number',
  //                 prefixIcon: Icons.search,
  //               ),
  //             ),
  //             SizedBox(
  //               width: 160,
  //               child: _buildDateField(
  //                 controller: _startDateController,
  //                 label: 'Start Date',
  //                 onTap: () => _selectDate(context, true),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 160,
  //               child: _buildDateField(
  //                 controller: _endDateController,
  //                 label: 'End Date',
  //                 onTap: () => _selectDate(context, false),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 140,
  //               child: _buildDropdown(
  //                 value: _selectedDepartment,
  //                 label: 'Department',
  //                 items: _departments,
  //                 onChanged: (value) => setState(() => _selectedDepartment = value ?? ''),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 140,
  //               child: _buildDropdown(
  //                 value: _selectedDirection,
  //                 label: 'Direction',
  //                 items: _directions,
  //                 onChanged: (value) => setState(() => _selectedDirection = value ?? ''),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         Row(
  //           children: [
  //             ElevatedButton.icon(
  //               onPressed: _applyFilters,
  //               icon: const Icon(Icons.filter_list, size: 18),
  //               label: const Text('Apply Filters'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: LightModeColors.lightPrimary,
  //                 foregroundColor: Colors.white,
  //                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             OutlinedButton.icon(
  //               onPressed: _clearFilters,
  //               icon: const Icon(Icons.clear, size: 18),
  //               label: const Text('Clear'),
  //               style: OutlinedButton.styleFrom(
  //                 foregroundColor: LightModeColors.lightOnSurface,
  //                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item.isEmpty ? null : item,
        child: Text(item.isEmpty ? 'All' : item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatsCards() {
    final totalCalls = _filteredCallLogs.length;
    final incomingCalls = _filteredCallLogs.where((log) => log.direction == 'incoming').length;
    final outgoingCalls = _filteredCallLogs.where((log) => log.direction == 'outgoing').length;
    final totalDuration = _filteredCallLogs.fold<int>(0, (sum, log) => sum + log.durationSeconds);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Calls', totalCalls.toString(),
                  LightModeColors.dashboardInfo, Icons.phone)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Incoming', incomingCalls.toString(),
                  LightModeColors.dashboardSuccess, Icons.call_received)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Outgoing', outgoingCalls.toString(),
                  LightModeColors.dashboardWarning, Icons.call_made)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Duration',
                  Duration(seconds: totalDuration).toString().split('.').first,
                  LightModeColors.lightTertiary, Icons.access_time)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LightModeColors.dashboardCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightModeColors.dashboardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: color.withValues(alpha: 0.1),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   // child: Icon(icon, color: color, size: 16),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightModeColors.lightOnSurface,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LightModeColors.lightOnSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredCallLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_disabled,
              size: 64,
              color: LightModeColors.lightOnSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No call logs found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: LightModeColors.lightOnSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: LightModeColors.dashboardCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightModeColors.dashboardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Call Logs (${_filteredCallLogs.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightModeColors.lightOnSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadCallLogs,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(
                      LightModeColors.dashboardSidebarBackground),
                  columns: const [
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Receiver', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Direction', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Number', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('SIM', style: TextStyle(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  rows: _filteredCallLogs.map((log) => DataRow(cells: [
                    DataCell(Text(log.name)),
                    DataCell(Text(log.receiverName)),
                    DataCell(_buildDirectionChip(log.direction)),
                    DataCell(Text(log.receiverMobileNo)),
                    DataCell(_buildDepartmentChip(log.department)),
                    DataCell(Text(log.formattedDuration)),
                    DataCell(Text(log.simLabel)),
                    DataCell(Text(DateFormat('dd/MM/yy HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(log.createdAt)))),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionChip(String direction) {
    final isIncoming = direction.toLowerCase() == 'incoming';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isIncoming ? LightModeColors.dashboardSuccess : LightModeColors.dashboardWarning)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncoming ? Icons.call_received : Icons.call_made,
            size: 12,
            color: isIncoming ? LightModeColors.dashboardSuccess : LightModeColors.dashboardWarning,
          ),
          const SizedBox(width: 4),
          Text(
            direction.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isIncoming ? LightModeColors.dashboardSuccess : LightModeColors.dashboardWarning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentChip(String department) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LightModeColors.dashboardInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        department,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: LightModeColors.dashboardInfo,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameSearchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}