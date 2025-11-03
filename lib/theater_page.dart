import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class TheaterPage extends StatefulWidget {
  const TheaterPage({super.key});

  static const routeName = '/theater';

  @override
  State<TheaterPage> createState() => _TheaterPageState();
}

class _TheaterPageState extends State<TheaterPage> {
  String? _city;
  String? _error;
  bool _loading = false;

  final _theaters = const [
    'XI CINEMA',
    'PONDOK KELAPA 21',
    'CGV',
    'CINEPOLIS',
    'CP MALL',
    'HERMES',
  ];

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Layanan lokasi nonaktif';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        setState(() => _error = 'Izin lokasi ditolak');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _error = 'Izin lokasi ditolak permanen');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      String city =
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          city = p.locality?.isNotEmpty == true
              ? p.locality!
              : (p.subAdministrativeArea ?? city);
        }
      } catch (_) {}
      setState(() => _city = city);
    } catch (e) {
      setState(() => _error = 'Gagal memuat lokasi');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('THEATER'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loading
                        ? 'Mencari lokasi…'
                        : _error != null
                        ? _error!
                        : (_city ?? 'Lokasi belum diketahui'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _loadCity,
                  tooltip: 'Muat ulang lokasi',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._theaters.map((name) => _TheaterTile(title: name)),
        ],
      ),
    );
  }
}

class _TheaterTile extends StatelessWidget {
  final String title;
  const _TheaterTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.keyboard_arrow_down),
        onTap: () {},
      ),
    );
  }
}
