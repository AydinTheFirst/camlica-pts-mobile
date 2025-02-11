import 'package:camlica_pts/components/file_picker_provider.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilePicker extends ConsumerWidget {
  const FilePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(filePickerProvider);

    return Column(
      children: [
        StyledButton(
          onPressed: () => _openBottomSheet(context, ref),
          fullWidth: true,
          child: Text("Dosya Seç"),
        ),
        _buildImages(context, files, ref),
      ],
    );
  }

  Future<void> _openBottomSheet(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Galeriden Seç"),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(filePickerProvider.notifier).openGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Kamerayı Aç"),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(filePickerProvider.notifier).openCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImages(BuildContext context, List<XFile> files, WidgetRef ref) {
    return Column(
      children: files
          .map(
            (file) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 10),
                    Text(file.name)
                  ],
                ),
                IconButton(
                  onPressed: () {
                    ref.read(filePickerProvider.notifier).removeFile(file);
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
