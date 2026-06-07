// features/maps/map_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:courtcall/repositories/firebase/firebase_map_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/session_repository.dart';
import '../player/rsvp_confirmation/rsvp_confirmation_screen.dart';
import 'map_viewmodel.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        repo: FirebaseMapRepository(),
      ),
      child: const _MapBody(),
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody();

  Set<Marker> _buildMarkers(MapViewModel vm) {
    return vm.sessions.map((session) {
      return Marker(
        markerId: MarkerId(session['id']),
        position: LatLng(session['lat'], session['lng']),
        onTap: () => vm.selectSession(session),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final markers = _buildMarkers(vm);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.1390, 101.6869),
              zoom: 13,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {},
            onTap: (_) => vm.clearSelection(),
          ),

          // ── Top Bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _MapIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
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
                            children: [
                              Icon(Icons.search,
                                  color: AppColors.onSurfaceVariant, size: 18),
                              const SizedBox(width: 8),
                              Text('Search venues...',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ── Filter Chips ──────────────────────────────────────
                  if (!vm.isLoading && vm.availableSports.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected: vm.selectedSport == null,
                              onTap: vm.clearFilters,
                            ),
                            ...vm.availableSports.map((sport) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _FilterChip(
                                label: sport,
                                selected: vm.selectedSport == sport,
                                onTap: () => vm.setSportFilter(sport),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  // ── Price Slider ──────────────────────────────────────
                  if (!vm.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 18, color: AppColors.onSurfaceVariant),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                overlayShape: SliderComponentShape.noOverlay,
                                activeTrackColor: AppColors.darkNavy,
                                inactiveTrackColor: AppColors.darkNavy.withValues(alpha: 0.15),
                                thumbColor: AppColors.darkNavy,
                              ),
                              child: Slider(
                                value: vm.maxPrice == 0
                                    ? vm.maxAvailablePrice
                                    : vm.maxPrice,
                                min: vm.minAvailablePrice,
                                max: vm.maxAvailablePrice,
                                onChanged: vm.setMaxPrice,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              vm.maxPrice == 0
                                  ? 'All'
                                  : 'RM ${vm.maxPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Loading Indicator ───────────────────────────────────────────
          if (vm.isLoading)
            const Center(child: CircularProgressIndicator()),

          // ── Session Count Chip ──────────────────────────────────────────
          if (!vm.isLoading)
            Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${vm.sessions.length} venues nearby',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // ── Session Preview Card ────────────────────────────────────────
          if (vm.selectedSession != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _SessionPreviewCard(
                session: vm.selectedSession!,
                onClose: vm.clearSelection,
                onTap: () async {
                  final sessionId = vm.selectedSession!['id'] as String;
                  final nav = Navigator.of(context);
                  final repo = context.read<SessionRepository>();
                  final session = await repo.getSession(sessionId);
                  if (session == null) return;
                  if (!context.mounted) return;
                  nav.push(
                    MaterialPageRoute(
                      builder: (_) => RsvpConfirmationScreen(session: session),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.darkNavy : AppColors.outline,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.darkNavy.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Session Preview Card ──────────────────────────────────────────────────────

Widget _buildVenueThumbnail(String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Image.asset(
        'assets/images/venue_placeholder.png',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
  return Image.asset(
    'assets/images/venue_placeholder.png',
    width: 48,
    height: 48,
    fit: BoxFit.cover,
  );
}

String _sportEmoji(String? sport) {
  switch (sport?.toLowerCase()) {
    case 'futsal':
      return '⚽';
    case 'badminton':
      return '🏸';
    case 'basketball':
      return '🏀';
    case 'volleyball':
      return '🏐';
    default:
      return '⚽';
  }
}

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
          color: AppColors.surface,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _buildVenueThumbnail(session['imageUrl'] as String?),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_sportEmoji(session['sport'] as String?),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('${session['name']}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${session['court']} · ${session['time']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('RM ${session['price'].toStringAsFixed(0)} / person',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenBright)),
                ],
              ),
            ),

            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close,
                  color: AppColors.textSecondary, size: 20),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}