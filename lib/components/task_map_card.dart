import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:flutter/material.dart';

class TaskMapCard extends StatelessWidget {
  final Task task;

  const TaskMapCard({
    super.key,
    required this.task,
  });

  Widget buildFullscreenMap(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Harita"),
      ),
      body: InteractiveViewer(
        minScale: 0.1,
        maxScale: 5,
        child: TaskMapCard(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => buildFullscreenMap(context),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Resmin oranını korumak için
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                // x ve y yüzde cinsinden geldiği için genişlik/yükseklik ile çarpıyoruz
                final double? x = task.locationX != null
                    ? width * (task.locationX! / 100)
                    : null;
                final double? y = task.locationY != null
                    ? height * (task.locationY! / 100)
                    : null;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        HttpService.getFile(task.selectedMap.url),
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (x != null && y != null)
                      Positioned(
                        left: x,
                        top: y,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
