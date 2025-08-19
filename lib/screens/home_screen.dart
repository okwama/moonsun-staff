import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woosh_portal/providers/authProvider.dart';
import 'package:woosh_portal/providers/attendance_provider.dart';
import 'package:woosh_portal/widgets/custom_icon_button.dart';
import 'package:woosh_portal/widgets/custom_button.dart';
import 'package:woosh_portal/providers/notice_provider.dart';
import 'package:woosh_portal/utils/error_utils.dart';
import 'package:woosh_portal/utils/greeting_utils.dart';
import '../models/recent_activity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<RecentActivity> _recentActivities = [];
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAttendance();
      _fetchRecentActivity();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh attendance when app becomes visible
    if (state == AppLifecycleState.resumed) {
      _refreshAttendance();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh attendance when dependencies change (e.g., returning from other screens)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAttendance();
    });
  }

  void _refreshAttendance() {
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.refresh();
  }

  Future<void> _fetchRecentActivity() async {
    setState(() => _loadingActivities = true);
    // Activity service not available in modular backend
    // Return empty activities for now
    if (mounted) {
      setState(() {
        _recentActivities = [];
        _loadingActivities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;
    final isDesktop = screenSize.width >= 1200;
    final isMobile = screenSize.width < 600;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: isMobile ? 40 : 48,
                  height: isMobile ? 40 : 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moonsun',
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Staff Portal',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 12 : 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (isMobile) ...[
              // For mobile: Show only essential buttons with reduced spacing
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<AttendanceProvider>(
                      builder: (context, attendanceProvider, child) {
                        return CustomIconButton(
                          icon: Icons.refresh,
                          onPressed: attendanceProvider.isLoading
                              ? () {}
                              : () => attendanceProvider.refresh(),
                          buttonSize: 36,
                          badge: Consumer<NoticeProvider>(
                            builder: (context, noticeProvider, child) {
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    CustomIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      buttonSize: 36,
                      badge: Consumer<NoticeProvider>(
                        builder: (context, noticeProvider, child) {
                          final unreadCount = noticeProvider.unreadCount;
                          return unreadCount > 0
                              ? Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    CustomIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      buttonSize: 36,
                      badge: Consumer<NoticeProvider>(
                        builder: (context, noticeProvider, child) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // For tablet/desktop: Show all buttons with normal spacing
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<AttendanceProvider>(
                      builder: (context, attendanceProvider, child) {
                        return CustomIconButton(
                          icon: Icons.refresh,
                          onPressed: attendanceProvider.isLoading
                              ? () {}
                              : () => attendanceProvider.refresh(),
                          buttonSize: 48,
                          badge: Consumer<NoticeProvider>(
                            builder: (context, noticeProvider, child) {
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    CustomIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      buttonSize: 48,
                      badge: Consumer<NoticeProvider>(
                        builder: (context, noticeProvider, child) {
                          final unreadCount = noticeProvider.unreadCount;
                          return unreadCount > 0
                              ? Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      buttonSize: 48,
                      badge: Consumer<NoticeProvider>(
                        builder: (context, noticeProvider, child) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              if (user == null) {
                return const Center(child: Text('No user data available'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _refreshAttendance();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? 20
                              : isTablet
                                  ? 32
                                  : 48,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isMobile ? 16 : 24),

                            // Welcome Section
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        GreetingUtils.getGreeting(),
                                        style: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile
                                              ? 24
                                              : isTablet
                                                  ? 28
                                                  : 32,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? 4 : 8),
                                      Text(
                                        user.name,
                                        style: GoogleFonts.inter(
                                          fontSize: isMobile ? 16 : 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: isMobile ? 48 : 56,
                                  height: isMobile ? 48 : 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: isMobile ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // Check-in Status Card
                            _buildCheckInStatusCard(
                                context, isMobile, isTablet),
                            SizedBox(height: isMobile ? 24 : 32),

                            // Schedule Card
                            Container(
                              width: double.infinity,
                              height: isMobile ? 120 : 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.8),
                                  ],
                                  stops: const [0, 1],
                                  begin: const AlignmentDirectional(1, -1),
                                  end: const AlignmentDirectional(-1, 1),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 20 : 24),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Today\'s Schedule',
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: isMobile ? 18 : 20,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 4 : 8),
                                          Text(
                                            '5 meetings • 3 tasks pending',
                                            style: GoogleFonts.inter(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: isMobile ? 14 : 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          CustomButton(
                                            text: 'View All',
                                            onPressed: () {
                                              // TODO: Navigate to schedule
                                            },
                                            height: isMobile ? 28 : 32,
                                            width: isMobile ? 80 : 100,
                                            color: Colors.white,
                                            textColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            borderRadius: 16,
                                            fontSize: isMobile ? 11 : 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.white,
                                      size: isMobile ? 48 : 56,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // Feature Grid
                            GridView.count(
                              padding: EdgeInsets.zero,
                              crossAxisCount: isMobile
                                  ? 2
                                  : isTablet
                                      ? 3
                                      : 4,
                              crossAxisSpacing: isMobile ? 16 : 20,
                              mainAxisSpacing: isMobile ? 16 : 20,
                              childAspectRatio: MediaQuery.of(context)
                                          .size
                                          .width <
                                      400
                                  ? 0.9
                                  : MediaQuery.of(context).size.width < 600
                                      ? 1.0
                                      : MediaQuery.of(context).size.width < 800
                                          ? 1.1
                                          : 1.2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildFeatureCard(
                                  context,
                                  'Clock In/Out',
                                  'Track your hours',
                                  Icons.access_time_rounded,
                                  Theme.of(context).primaryColor,
                                  () {
                                    Navigator.pushNamed(context, '/attendance');
                                  },
                                  isMobile,
                                  isTablet,
                                ),
                                _buildFeatureCard(
                                  context,
                                  'Tasks',
                                  'Manage assignments',
                                  Icons.assignment_turned_in_rounded,
                                  Colors.green,
                                  () {
                                    Navigator.pushNamed(context, '/tasks');
                                  },
                                  isMobile,
                                  isTablet,
                                ),
                                _buildFeatureCard(
                                  context,
                                  'Team',
                                  'Connect with colleagues',
                                  Icons.people_rounded,
                                  Colors.blue,
                                  () {
                                    // TODO: Navigate to team
                                  },
                                  isMobile,
                                  isTablet,
                                ),
                                _buildFeatureCard(
                                  context,
                                  'Leave Request',
                                  'Request time off',
                                  Icons.event_note_rounded,
                                  Colors.orange,
                                  () {
                                    Navigator.pushNamed(
                                      context,
                                      '/leave-request',
                                    );
                                  },
                                  isMobile,
                                  isTablet,
                                ),
                                _buildFeatureCard(
                                  context,
                                  'Out of Office',
                                  'Apply for out of office',
                                  Icons.airplanemode_active,
                                  Colors.deepPurple,
                                  () {
                                    Navigator.pushNamed(
                                        context, '/out-of-office');
                                  },
                                  isMobile,
                                  isTablet,
                                ),
                                if (!isMobile) ...[
                                  _buildFeatureCard(
                                    context,
                                    'Reports',
                                    'View analytics',
                                    Icons.analytics_rounded,
                                    Colors.purple,
                                    () {
                                      // TODO: Navigate to reports
                                    },
                                    isMobile,
                                    isTablet,
                                  ),
                                  _buildFeatureCard(
                                    context,
                                    'Settings',
                                    'App preferences',
                                    Icons.settings_rounded,
                                    Colors.grey,
                                    () {
                                      Navigator.pushNamed(context, '/settings');
                                    },
                                    isMobile,
                                    isTablet,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // Recent Activity Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Activity',
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 20 : 24,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'View All',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                if (_loadingActivities)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else if (_recentActivities.isEmpty)
                                  const Center(
                                      child: Text('No recent activity.'))
                                else
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _recentActivities.length,
                                      separatorBuilder: (context, i) =>
                                          const Divider(),
                                      itemBuilder: (context, i) {
                                        final activity = _recentActivities[i];
                                        IconData icon;
                                        Color iconColor;
                                        switch (activity.type) {
                                          case 'attendance':
                                            icon = Icons.access_time_rounded;
                                            iconColor = Colors.blue;
                                            break;
                                          case 'task':
                                            icon = Icons
                                                .assignment_turned_in_rounded;
                                            iconColor = Colors.green;
                                            break;
                                          case 'notice':
                                            icon = Icons.notifications;
                                            iconColor = Colors.orange;
                                            break;
                                          default:
                                            icon = Icons.info_outline;
                                            iconColor = Colors.grey;
                                        }
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                iconColor.withOpacity(0.15),
                                            child: Icon(icon, color: iconColor),
                                          ),
                                          title: Text(activity.title),
                                          subtitle: Text(activity.subtitle),
                                          trailing: Text(
                                            '${activity.date.hour.toString().padLeft(2, '0')}:${activity.date.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // Help Section
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: isMobile ? 100 : 120,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 20 : 24),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Need Help?',
                                            style: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isMobile ? 16 : 18,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 8 : 12),
                                          Flexible(
                                            child: Text(
                                              'Contact HR or IT Support',
                                              style: GoogleFonts.inter(
                                                fontSize: isMobile ? 12 : 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CustomIconButton(
                                      icon: Icons.help_outline_rounded,
                                      onPressed: () {
                                        // TODO: Navigate to help
                                      },
                                      fillColor: Theme.of(context).primaryColor,
                                      iconColor: Colors.white,
                                      buttonSize: isMobile ? 48 : 56,
                                      borderRadius: 24,
                                      badge: Consumer<NoticeProvider>(
                                        builder:
                                            (context, noticeProvider, child) {
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    bool isMobile,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: isMobile
                      ? 32
                      : isTablet
                          ? 36
                          : 40,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile
                        ? 16
                        : isTablet
                            ? 18
                            : 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isMobile,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 14 : 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInStatusCard(
      BuildContext context, bool isMobile, bool isTablet) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final currentAttendance = attendanceProvider.currentAttendance;
        final status = attendanceProvider.status;
        final isLoading = attendanceProvider.isLoading;

        String statusText;
        Color statusColor;
        IconData statusIcon;

        if (isLoading) {
          statusText = 'Loading...';
          statusColor = Colors.grey;
          statusIcon = Icons.hourglass_empty;
        } else if (currentAttendance == null) {
          statusText = 'Not Checked In';
          statusColor = Colors.grey;
          statusIcon = Icons.access_time;
        } else if (status == 0) {
          statusText = 'Pending';
          statusColor = Colors.orange;
          statusIcon = Icons.pending;
        } else if (status == 1) {
          statusText = 'Checked In';
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (status == 2) {
          statusText = 'Checked Out';
          statusColor = Colors.red;
          statusIcon = Icons.logout;
        } else {
          statusText = 'Unknown Status';
          statusColor = Colors.grey;
          statusIcon = Icons.help;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Status',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 16 : 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Row(
                        children: [
                          if (isLoading)
                            SizedBox(
                              width: isMobile ? 16 : 18,
                              height: isMobile ? 16 : 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                            )
                          else
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: isMobile ? 16 : 18,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 14 : 16,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      if (currentAttendance != null && !isLoading) ...[
                        SizedBox(height: isMobile ? 8 : 12),
                        _buildAttendanceTimeInfo(
                            context, currentAttendance, isMobile),
                      ],
                    ],
                  ),
                ),
                CustomButton(
                  text: isLoading
                      ? 'Loading...'
                      : status == 1
                          ? 'Check Out'
                          : 'Check In',
                  onPressed: isLoading
                      ? () {}
                      : status == 1
                          ? () => _handleCheckOut(context, attendanceProvider)
                          : () => _handleCheckIn(context, attendanceProvider),
                  height: isMobile ? 36 : 40,
                  width: isMobile ? 100 : 120,
                  color: isLoading
                      ? Colors.grey
                      : status == 1
                          ? Colors.red
                          : Colors.green,
                  textColor: Colors.white,
                  borderRadius: 20,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTimeInfo(
      BuildContext context, Map<String, dynamic> attendance, bool isMobile) {
    final checkInTime = attendance['checkInTime'];
    final checkOutTime = attendance['checkOutTime'];
    final totalHours = attendance['totalHours'];

    // Helper function to safely convert to double
    double? safeToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    final safeTotalHours = safeToDouble(totalHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (checkInTime != null) ...[
          Text(
            'Check-in: ${_formatTime(checkInTime)}',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 12 : 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
        if (checkOutTime != null) ...[
          Text(
            'Check-out: ${_formatTime(checkOutTime)}',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 12 : 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
        if (safeTotalHours != null) ...[
          Text(
            'Hours: ${safeTotalHours.toStringAsFixed(2)} hrs',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 12 : 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(String timeString) {
    try {
      debugPrint('🕐 Formatting time: $timeString');

      // Handle ISO format with 'T' separator (UTC time from backend)
      if (timeString.contains('T')) {
        final utcDateTime = DateTime.parse(timeString);
        // Convert UTC to local time (Africa/Nairobi)
        final localDateTime = utcDateTime.toLocal();
        debugPrint('🕐 UTC: $utcDateTime -> Local: $localDateTime');
        debugPrint(
            '🕐 UTC Hour: ${utcDateTime.hour}, Local Hour: ${localDateTime.hour}');
        debugPrint(
            '🕐 UTC Minute: ${utcDateTime.minute}, Local Minute: ${localDateTime.minute}');
        debugPrint('🕐 Timezone offset: ${utcDateTime.timeZoneOffset}');
        debugPrint('🕐 Local timezone: ${DateTime.now().timeZoneName}');
        // Format as HH:MM in local time
        return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
      }

      // Handle space-separated format
      if (timeString.contains(' ')) {
        final timePart = timeString.split(' ')[1];
        return timePart.substring(0, 5); // Get HH:MM part
      }

      // If it's already in HH:MM format, return as is
      if (timeString.length >= 5 && timeString.contains(':')) {
        return timeString.substring(0, 5);
      }

      return timeString;
    } catch (e) {
      debugPrint('❌ Error formatting time: $e for timeString: $timeString');
      return timeString;
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialogWithStackTrace(
      BuildContext context, String title, String errorMessage) {
    // Log the full error details including stack trace
    debugPrint('=== ERROR DIALOG ===');
    debugPrint('Title: $title');
    debugPrint('Error Message: $errorMessage');
    debugPrint('Stack Trace: ${StackTrace.current}');
    debugPrint('===================');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An error occurred while processing your request.',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                errorMessage,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please try again or contact support if the problem persists.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn(
      BuildContext context, AttendanceProvider attendanceProvider) async {
    final success = await attendanceProvider.checkIn();
    if (success && context.mounted) {
      _showSuccessDialog(
        context,
        'Check-in Successful',
        'You have been checked in successfully!',
      );
    } else if (context.mounted && attendanceProvider.errorMessage != null) {
      final errorMessage = attendanceProvider.errorMessage!;
      final errorType = attendanceProvider.errorType;

      // Show device-specific dialog for device approval errors
      if (errorType == 'device_approval' ||
          errorType == 'device_registration') {
        ErrorUtils.showDeviceApprovalError(
          context,
          message: errorMessage,
          onContactAdmin: () {
            // TODO: Implement contact admin functionality
            debugPrint('Contact admin functionality to be implemented');
          },
        );
        // Clear the error after showing the dialog
        attendanceProvider.clearError();
      } else {
        // Show error dialog for all other errors
        _showErrorDialogWithStackTrace(
          context,
          'Check-in Failed',
          errorMessage,
        );
        // Clear the error after showing the dialog
        attendanceProvider.clearError();
      }
    }
  }

  Future<void> _handleCheckOut(
      BuildContext context, AttendanceProvider attendanceProvider) async {
    debugPrint('🎯 _handleCheckOut called');

    final success = await attendanceProvider.checkOut();

    debugPrint('🎯 Checkout result: $success');
    debugPrint('🎯 Context mounted: ${context.mounted}');
    debugPrint('🎯 Error message: ${attendanceProvider.errorMessage}');

    if (success && context.mounted) {
      debugPrint('🎯 Showing success dialog');
      _showSuccessDialog(
        context,
        'Check-out Successful',
        'You have been checked out successfully!',
      );
    } else if (context.mounted && attendanceProvider.errorMessage != null) {
      debugPrint('🎯 Showing error dialog');
      final errorMessage = attendanceProvider.errorMessage!;
      final errorType = attendanceProvider.errorType;

      // Show device-specific dialog for device approval errors
      if (errorType == 'device_approval' ||
          errorType == 'device_registration') {
        ErrorUtils.showDeviceApprovalError(
          context,
          message: errorMessage,
          onContactAdmin: () {
            // TODO: Implement contact admin functionality
            debugPrint('Contact admin functionality to be implemented');
          },
        );
        // Clear the error after showing the dialog
        attendanceProvider.clearError();
      } else {
        // Show error dialog with stack trace for all other errors
        _showErrorDialogWithStackTrace(
          context,
          'Check-out Failed',
          errorMessage,
        );
        // Clear the error after showing the dialog
        attendanceProvider.clearError();
      }
    } else {
      debugPrint(
          '🎯 No success and no error message - this might be the issue');
    }
  }
}
