import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:flutter/material.dart';

class MapClickTracker extends StatefulWidget {
  final Function({
    required Map<String, double> position,
  }) onPositionSelected;
  final TaskMap selectedMap;

  const MapClickTracker({
    super.key,
    required this.onPositionSelected,
    required this.selectedMap,
  });

  @override
  createState() => _MapClickTrackerState();
}

class _MapClickTrackerState extends State<MapClickTracker> {
  Offset? _selectedPosition;
  final GlobalKey _imageKey =
      GlobalKey(); // Image widget'ını takip etmek için key

  void _handleTap(BuildContext context, TapDownDetails details) {
    final RenderBox box =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localOffset =
        box.globalToLocal(details.globalPosition); // Doğru local koordinatı al

    // Image'ın ekrandaki gerçek genişlik ve yüksekliğini al
    final Size imageSize = box.size;

    // Yüzde hesaplamasını doğru yapmak için
    final double percentX = (localOffset.dx / imageSize.width) * 100;
    final double percentY = (localOffset.dy / imageSize.height) * 100;

    setState(() {
      _selectedPosition = localOffset;
    });

    widget.onPositionSelected(position: {
      'x': percentX,
      'y': percentY,
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: GestureDetector(
        onTapDown: (details) => _handleTap(context, details),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Image.network(
                  HttpService.getFile(widget.selectedMap.url),
                  key:
                      _imageKey, // Key ekleyerek RenderBox'a ulaşmamızı sağladık
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                if (_selectedPosition != null)
                  Positioned(
                    left: _selectedPosition!.dx - 12,
                    top: _selectedPosition!.dy - 24,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
