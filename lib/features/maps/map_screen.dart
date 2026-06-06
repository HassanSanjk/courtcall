// features/maps/map_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:courtcall/repositories/firebase/firebase_map_repository.dart';
import 'map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapViewModel _viewModel;
  GoogleMapController? _mapController;

  // Default camera position — Kuala Lumpur
  static const _initialPosition = CameraPosition(
    target: LatLng(3.1390, 101.6869),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel(
      repo: FirebaseMapRepository(),
    );
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers {
    return _viewModel.sessions.map((session) {
      return Marker(
        markerId: MarkerId(session['id']),
        position: LatLng(session['lat'], session['lng']),
        onTap: () => _viewModel.selectSession(session),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => _viewModel.clearSelection(),
          ),

          // ── Top Bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _MapIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search,
                              color: Color(0xFF9CA3AF), size: 18),
                          SizedBox(width: 8),
                          Text('Search venues...',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Loading Indicator ───────────────────────────────────────────
          if (_viewModel.isLoading)
            const Center(child: CircularProgressIndicator()),

          // ── Session Count Chip ──────────────────────────────────────────
          if (!_viewModel.isLoading)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_viewModel.sessions.length} venues nearby',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // ── Session Preview Card ────────────────────────────────────────
          if (_viewModel.selectedSession != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _SessionPreviewCard(
                session: _viewModel.selectedSession!,
                onClose: _viewModel.clearSelection,
                onTap: () {
                  // TODO: Navigate to session detail screen
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Session Preview Card ──────────────────────────────────────────────────────

class _SessionPreviewCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const _SessionPreviewCard({
    required this.session,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Venue image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/venue_placeholder.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${session['name']}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text('${session['court']} · ${session['time']}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text('RM ${session['price'].toStringAsFixed(0)} / person',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D7A3E))),
                ],
              ),
            ),

            // Close button
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close,
                  color: Color(0xFF9CA3AF), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map Icon Button ───────────────────────────────────────────────────────────

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
      ),
    );
  }
}