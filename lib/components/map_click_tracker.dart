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
  final TransformationController _transformationController =
      TransformationController();

  void _handleTap(BuildContext context, TapDownDetails details) {
    // Get tap position within the InteractiveViewer
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    // Apply inverse of current transformation to get original offset
    final Matrix4 inverseMatrix =
        Matrix4.inverted(_transformationController.value);
    final Offset originalOffset =
        MatrixUtils.transformPoint(inverseMatrix, localOffset);

    setState(() {
      _selectedPosition = originalOffset;
    });

    // Use the widget's size (you may want this to be your image/container's size)
    final Size size = box.size;
    final double percentX = (originalOffset.dx / size.width) * 100;
    final double percentY = (originalOffset.dy / size.height) * 100;

    widget.onPositionSelected(position: {
      'x': percentX,
      'y': percentY,
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(20.0),
      minScale: 0.5,
      maxScale: 4.0,
      child: Stack(
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
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
