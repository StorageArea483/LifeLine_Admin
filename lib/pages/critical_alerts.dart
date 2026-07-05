import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_line_admin/pages/admin_dasboard.dart';
import 'package:life_line_admin/providers/critical_alerts_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/global/page_message.dart';
import 'package:life_line_admin/widgets/global/page_navigation.dart';
import 'package:life_line_admin/widgets/nav_bar.dart';

class CriticalAlerts extends ConsumerStatefulWidget {
  const CriticalAlerts({super.key});

  @override
  ConsumerState<CriticalAlerts> createState() => _CriticalAlertsState();
}

class _CriticalAlertsState extends ConsumerState<CriticalAlerts> {
  final MapController _mapController = MapController();
  FirebaseFirestore? _victimFirestore;

  // project-life-line database credentials
  static const FirebaseOptions _victimFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyByihQ3YBdrJUrAAxFSX3257fUMa0AJ6uo',
    appId: '1:503939690280:android:aff06bb9fb777faf792a1d',
    messagingSenderId: '503939690280',
    projectId: 'project-life-line',
    storageBucket: 'project-life-line.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndFetch();
    });
  }

  Future<void> _initializeAndFetch() async {
    try {
      await _initSecondaryFirebase();
      await _fetchOngoingOperations();
    } catch (e) {
      if (mounted) {
        pageMessage(
          'Failed to load ongoing operations, please retry',
          context,
          AppColors.error,
        );
      }
    }
  }

  Future<void> _initSecondaryFirebase() async {
    FirebaseApp victimApp;
    try {
      victimApp = Firebase.app('project-life-line');
    } catch (_) {
      victimApp = await Firebase.initializeApp(
        name: 'project-life-line',
        options: _victimFirebaseOptions,
      );
    }
    _victimFirestore = FirebaseFirestore.instanceFor(app: victimApp);
  }

  Future<void> _fetchOngoingOperations() async {
    if (_victimFirestore == null) return;

    try {
      final snapshot = await _victimFirestore!.collection('users').get();

      final victimLocations = <Map<String, dynamic>>[];
      final rescuerLocations = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final requestAccepted = data['requestAccepted'];
        if (requestAccepted != 'accepted') continue;

        final rawVictimLat = data['latitude'];
        final rawVictimLng = data['longitude'];
        final rawRescuerLat = data['rescuerLatitude'];
        final rawRescuerLng = data['rescuerLongitude'];

        final double? victimLat = rawVictimLat;
        final double? victimLng = rawVictimLng;
        final double? rescuerLat = rawRescuerLat;
        final double? rescuerLng = rawRescuerLng;

        final hasValidVictimLocation =
            victimLat != null &&
            victimLng != null &&
            victimLat != 0.0 &&
            victimLng != 0.0;
        final hasValidRescuerLocation =
            rescuerLat != null &&
            rescuerLng != null &&
            rescuerLat != 0.0 &&
            rescuerLng != 0.0;

        if (!hasValidVictimLocation || !hasValidRescuerLocation) continue;

        victimLocations.add({
          doc.id: {'victimLatitude': victimLat, 'victimLongitude': victimLng},
        });

        rescuerLocations.add({
          doc.id: {
            'rescuerLatitude': rescuerLat,
            'rescuerLongitude': rescuerLng,
          },
        });
      }

      if (mounted) {
        ref
            .read(criticalAlertsProvider.notifier)
            .setVictimLocations(victimLocations);
        ref
            .read(criticalAlertsProvider.notifier)
            .setRescuerLocations(rescuerLocations);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      drawer: buildDrawer(context),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  child: const NavBar(),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: _buildHeader(),
                ),
                Expanded(child: _buildFullMap()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMaroon.withValues(alpha: 0.05),
            AppColors.accentRose.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMaroon.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    pageNavigation(const AdminDashboard(), context);
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ongoing Operations',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final victimLocations = ref.watch(
                      criticalAlertsProvider.select((v) => v.victimLocations),
                    );
                    return Text(
                      '${victimLocations.length} active operation${victimLocations.length != 1 ? 's' : ''} in progress',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(34.1688, 73.2215), // Default: Abbottabad
        initialZoom: 11,
        minZoom: 1,
        maxZoom: 18,
        interactionOptions: InteractionOptions(
          flags:
              InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.lifeline.admin.app',
        ),
        Consumer(
          builder: (context, ref, child) {
            return _buildVictimMarkers(ref);
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            return _buildRescuerMarkers(ref);
          },
        ),
      ],
    );
  }

  Widget _buildVictimMarkers(WidgetRef ref) {
    final victimLocations = ref.watch(
      criticalAlertsProvider.select((v) => v.victimLocations),
    );
    final markers = <Marker>[];

    for (final entry in victimLocations) {
      for (final data in entry.values) {
        final lat = data['victimLatitude'] as double?;
        final lng = data['victimLongitude'] as double?;
        if (lat == null || lng == null) continue;

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 32),
          ),
        );
      }
    }

    return MarkerLayer(markers: markers);
  }

  Widget _buildRescuerMarkers(WidgetRef ref) {
    final rescuerLocations = ref.watch(
      criticalAlertsProvider.select((v) => v.rescuerLocations),
    );
    final markers = <Marker>[];

    for (final entry in rescuerLocations) {
      for (final data in entry.values) {
        final lat = data['rescuerLatitude'] as double?;
        final lng = data['rescuerLongitude'] as double?;
        if (lat == null || lng == null) continue;

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 30,
            height: 30,
            child: const Icon(
              Icons.navigation,
              color: AppColors.primaryMaroon,
              size: 24,
            ),
          ),
        );
      }
    }

    return MarkerLayer(markers: markers);
  }
}
