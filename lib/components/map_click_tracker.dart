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

  void _handleTap(BuildContext context, TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      _selectedPosition = localOffset;
    });

    final localPosition = box.globalToLocal(details.globalPosition);
    final size = box.size;
    final percentX = (localPosition.dx / size.width) * 100;
    final percentY = (localPosition.dy / size.height) * 100;

    widget.onPositionSelected(position: {
      'x': percentX,
      'y': percentY,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) => _handleTap(context, details),
          child: Image.network(
            HttpService.getFile(widget.selectedMap.url),
            fit: BoxFit.contain,
          ),
        ),
        if (_selectedPosition != null)
          Positioned(
            left: _selectedPosition!.dx,
            top: _selectedPosition!.dy,
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 24,
            ),
          ),
      ],
    );
  }
}
