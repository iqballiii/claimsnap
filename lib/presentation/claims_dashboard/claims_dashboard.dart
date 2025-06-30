import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/insurance_claim.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth_provider.dart';
import '../../utils/claims_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/claim_card_widget.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';

class ClaimsDashboard extends StatefulWidget {
  const ClaimsDashboard({super.key});

  @override
  State<ClaimsDashboard> createState() => _ClaimsDashboardState();
}

class _ClaimsDashboardState extends State<ClaimsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ClaimsService _claimsService = ClaimsService();

  bool _isLoading = false;
  bool _isSearching = false;
  String _selectedFilter = 'all';
  List<String> _activeFilters = [];
  List<InsuranceClaim> _allClaims = [];
  List<InsuranceClaim> _filteredClaims = [];
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadClaims();
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreClaims();
    }
  }

  Future<void> _loadClaims() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final claims = await _claimsService.getUserClaims(limit: 50);

      setState(() {
        _allClaims = claims;
        _filteredClaims = List.from(claims);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load claims: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _claimsService.getClaimsStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
    }
  }

  Future<void> _loadMoreClaims() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay for pagination
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshClaims() async {
    await _loadClaims();
    await _loadStatistics();
  }

  void _filterClaims(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClaims = List.from(_allClaims);
      } else {
        _filteredClaims = _allClaims.where((claim) {
          final claimNumber = claim.claimNumber.toLowerCase();
          final description = claim.incidentDescription.toLowerCase();
          final status = claim.statusDisplayName.toLowerCase();
          final vehicleInfo = claim.vehicle?.displayName.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return claimNumber.contains(searchQuery) ||
              description.contains(searchQuery) ||
              status.contains(searchQuery) ||
              vehicleInfo.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _applyStatusFilter(String status) {
    setState(() {
      _selectedFilter = status;
      if (status == 'all') {
        _filteredClaims = List.from(_allClaims);
        _activeFilters.clear();
      } else {
        ClaimStatus? filterStatus = _parseFilterStatus(status);
        if (filterStatus != null) {
          _filteredClaims = _allClaims
              .where((claim) => claim.status == filterStatus)
              .toList();
          _activeFilters = [status];
        }
      }
    });
  }

  ClaimStatus? _parseFilterStatus(String status) {
    switch (status) {
      case 'pending':
        return ClaimStatus.submitted;
      case 'approved':
        return ClaimStatus.approved;
      case 'denied':
        return ClaimStatus.denied;
      case 'processing':
        return ClaimStatus.underReview;
      default:
        return null;
    }
  }

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);
      if (_activeFilters.isEmpty) {
        _selectedFilter = 'all';
        _filteredClaims = List.from(_allClaims);
      }
    });
  }

  void _navigateToClaimDetails(InsuranceClaim claim) {
    Navigator.pushNamed(context, '/claim-details-view', arguments: claim);
  }

  void _navigateToCameraCapture() {
    Navigator.pushNamed(context, '/camera-capture-interface');
  }

  void _navigateToProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Name: ${authProvider.currentUserProfile?.fullName ?? 'Unknown'}'),
            SizedBox(height: 1.h),
            Text(
                'Email: ${authProvider.currentUserProfile?.email ?? 'Unknown'}'),
            SizedBox(height: 1.h),
            Text(
                'Role: ${authProvider.currentUserProfile?.roleDisplayName ?? 'Unknown'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/login-screen');
              });
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Text('Settings feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  if (index == 1) _navigateToProfile();
                  if (index == 2) _navigateToSettings();
                },
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Profile'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),

            // Dashboard Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  Container(), // Placeholder for Profile
                  Container(), // Placeholder for Settings
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToCameraCapture,
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.white,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'New Claim',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshClaims,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with statistics
          SliverToBoxAdapter(
            child: DashboardHeaderWidget(
              searchController: _searchController,
              onSearchChanged: _filterClaims,
              onSearchToggle: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filterClaims('');
                  }
                });
              },
              isSearching: _isSearching,
              statistics: _statistics,
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: FilterChipsWidget(
              selectedFilter: _selectedFilter,
              activeFilters: _activeFilters,
              onFilterSelected: _applyStatusFilter,
              onFilterRemoved: _removeFilter,
              claimsCount: _filteredClaims.length,
            ),
          ),

          // Claims List or Empty State
          _filteredClaims.isEmpty && !_isLoading
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    onCreateClaim: _navigateToCameraCapture,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _filteredClaims.length) {
                        return ClaimCardWidget(
                          claim: _filteredClaims[index],
                          onTap: () =>
                              _navigateToClaimDetails(_filteredClaims[index]),
                          onEdit: () =>
                              _navigateToClaimDetails(_filteredClaims[index]),
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Sharing claim ${_filteredClaims[index].claimNumber}'),
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                              ),
                            );
                          },
                        );
                      } else if (_isLoading) {
                        return Container(
                          padding: EdgeInsets.all(4.w),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: _filteredClaims.length + (_isLoading ? 1 : 0),
                  ),
                ),
        ],
      ),
    );
  }
}
