import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camlica_pts/services/toast_service.dart';

class FilePickerNotifier extends StateNotifier<List<XFile>> {
  FilePickerNotifier() : super([]);

  final ImagePicker _picker = ImagePicker();

  Future<void> openGallery() async {
    final List<XFile> pickedImages =
        await _picker.pickMultiImage(requestFullMetadata: true);
    if (pickedImages.isEmpty) {
      return ToastService.error(message: "Lütfen bir resim seçin");
    }
    state = [...state, ...pickedImages];
  }

  Future<void> openCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      return ToastService.error(message: "Lütfen bir resim çekin");
    }
    state = [...state, pickedImage];
  }

  void removeFile(XFile file) {
    state = state.where((f) => f != file).toList();
  }

  void clearFiles() {
    state = [];
  }

  void addFiles(List<XFile> files) {
    state = [...state, ...files];
  }
}

final filePickerProvider =
    StateNotifierProvider<FilePickerNotifier, List<XFile>>((ref) {
  return FilePickerNotifier();
});
