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
                const mapHeight = 400.0; // Harita yüksekliği sabitlendi

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: mapWidth,
                    maxHeight: mapHeight,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenMap(task: task),
                        ),
                      );
                    },
                    child: SizedBox(
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
                                offset: const Offset(
                                    -5, -5), // İşaretleyiciyi ortalamak için
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
                    ),
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

class FullScreenMap extends StatelessWidget {
  final Task task;

  const FullScreenMap({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Harita"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapWidth = constraints.maxWidth;
              const mapHeight = 400.0; // Fixed map height

              return SizedBox(
                width: mapWidth,
                height: mapHeight,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      Image.network(
                        HttpService.getFile(task.selectedMap.url),
                        width: mapWidth,
                        height: mapHeight,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        left: (task.locationX! / 100) * mapWidth,
                        top: (task.locationY! / 100) * mapHeight,
                        child: Transform.translate(
                          offset: const Offset(-5, -5),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
