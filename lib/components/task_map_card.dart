import 'package:flutter/material.dart';

class TaskMapCard extends StatelessWidget {
  final double? locationX;
  final double? locationY;

  const TaskMapCard({super.key, this.locationX, this.locationY});

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
                      Image.asset(
                        'assets/map.jpeg',
                        width: mapWidth,
                        height: mapHeight,
                        fit: BoxFit.cover,
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
