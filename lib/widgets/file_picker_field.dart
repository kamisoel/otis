import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class FilePickerField extends FormField<File> {

  final Future<File> Function(BuildContext context, int option) onShowPicker;

  final Icon resetIcon;
  final Icon uploadIcon;
  final Icon addedIcon;

  final String labelText;
  final List<String> optionLabels;
  final List<Icon> optionIcons;

  FilePickerField({
    @required this.onShowPicker,

    // From super
    Key key,
    FormFieldSetter<File> onSaved,
    bool enabled = true,
    InputDecoration decoration,

    // Features
    this.resetIcon = const Icon(Icons.close),
    this.uploadIcon = const Icon(Icons.file_upload),
    this.addedIcon = const Icon(Icons.check),
    this.labelText = "",
    this.optionLabels = const [],
    this.optionIcons = const [],
  }) : super(
            key: key,
            autovalidate: false,
            enabled: enabled ?? true,
            onSaved: onSaved,
            initialValue: null,
            builder: (FormFieldState<File> state) {
              bool hasValue = state.value != null;

              return Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        labelText,
                        style: Theme.of(state.context).textTheme.caption,
                      ),
                      Row(
                        children: [
                          if(hasValue && state.value.path.endsWith('mp4'))
                            FutureBuilder(
                              future: VideoCompress.getFileThumbnail(
                                state.value.path,
                                quality: 30,
                              ),
                              builder: (context, snap) => snap.hasData
                                  ? Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Image.file(
                                        snap.data,
                                        height: 100,
                                        width: 80,
                                      ))
                                  : CircularProgressIndicator(),
                            )
                          else
                            Card(
                              child: TextButton(
                                //padding: EdgeInsets.all(30),
                                child: hasValue
                                    ? addedIcon
                                    : uploadIcon,
                                onPressed: () async {
                                  final option = await _showOptionDialog(
                                      state.context, optionLabels, optionIcons);
                                  final file =
                                      await onShowPicker(state.context, option);
                                  state.didChange(file);
                                },
                              ),
                            ),
                          if (hasValue)
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Pfad',
                                  suffixIcon: IconButton(
                                      icon: resetIcon,
                                      onPressed: () {
                                        state.reset();
                                      }),
                                ),
                                controller: TextEditingController(
                                    text: state.value.path.split("/").last),
                                readOnly: true,
                              ),
                            )
                        ],
                      ),
                    ],
                  ));
              /*return RaisedButton.icon(
          icon: hasValue? thumbIcon(state.value) : emptyIcon,
          label: label,
          onPressed: () => onShowPicker(state.context),
        );*/
            });

  FilePickerField.forDocument({
    String fileExtension,
    FormFieldSetter<File> onSaved,
    String labelText = "",
  }) : this(
            labelText: labelText,
            onSaved: onSaved,
            onShowPicker: (BuildContext context, int option) async {
                  var result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [fileExtension]);
                  return File(result.files.single.path);
                });

  FilePickerField.forVideo({
    String labelText = "",
    FormFieldSetter<File> onSaved,
  }) : this(
            labelText: labelText,
            onSaved: onSaved,
            optionLabels: const ["Kamera", "Galerie"],
            optionIcons: const [
              Icon(Icons.camera_enhance),
              Icon(Icons.add_photo_alternate)
            ],
            onShowPicker: (BuildContext context, int option) async {
              if (option < 0) return null;
              final _picker = ImagePicker();
              final _source = [ImageSource.camera, ImageSource.gallery][option];
              var video = await _picker.getVideo(source: _source);
              // TODO better solution necessary
              //if (source == ImageSource.camera && video.path.endsWith(".MOV"))
              //  video = await video.rename(video.path.replaceAll('.MOV', '.mp4'));
              return File(video.path);
            });

  static Future<int> _showOptionDialog(
      BuildContext context, List<String> labels, List<Icon> icons) async {
    if (labels.isEmpty) return -1;
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 120.0,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < labels.length; i++)
                    TextButton.icon(
                      icon: icons[i],
                      label: Text(labels[i]),
                      onPressed: () {
                        Navigator.pop(context, i);
                      },
                    ),
                ],
              ));
        });
  }
}
