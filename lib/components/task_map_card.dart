import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:flutter/material.dart';

class TaskMapCard extends StatelessWidget {
  final double? locationX;
  final double? locationY;
  final Task task;

  const TaskMapCard({
    super.key,
    this.locationX,
    this.locationY,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final mapWidth = constraints.maxWidth;
                final mapHeight = 400.0; // Harita yüksekliği sabitlenmiş
                return SizedBox(
                  width: mapWidth,
                  height: mapHeight,
                  child: Stack(
                    children: [
                      Image.network(
                        HttpService.getFile(task.selectedMap.url),
                        width: mapWidth,
                        height: mapHeight,
                        fit: BoxFit.contain,
                      ),
                      if (locationX != null && locationY != null)
                        Positioned(
                          left: (locationX! / 100) * mapWidth,
                          top: (locationY! / 100) * mapHeight,
                          child: Transform.translate(
                            offset: const Offset(-5, -5), // Ortalamak için
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
