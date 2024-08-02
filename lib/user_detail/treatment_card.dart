import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_detail_bloc.dart';
import 'package:otis/model/model.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:otis/localization.dart';

class TreatmentCard extends StatefulWidget {
  final Treatment treatment;
  final bool userMode;

  TreatmentCard({Key key, @required this.treatment, this.userMode = false})
      : super(key: key);

  @override
  _TreatmentCardState createState() =>
      _TreatmentCardState(treatment: treatment, userMode: userMode);

  static empty(BuildContext context) => _card(
        child: ListTile(
          leading: Icon(MdiIcons.emoticonSadOutline),
          title: Text(AppLocalizations.of(context).noTreatments),
        ),
      );
}

class _TreatmentCardState extends State<TreatmentCard> {
  final Treatment treatment;
  final bool userMode;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  Future<void> _videoInitialized;

  _TreatmentCardState({@required this.treatment, @required this.userMode});

  bool get _hasVideo => treatment.videos[0].notEmpty;

  bool get _hasPdf => treatment.pdf.notEmpty;

  @override
  void initState() {
    if (_hasVideo) {
      final video = treatment.videos[0];
      _videoInitialized = initVideoPlayer(video.url);
    }
    super.initState();
  }

  Future<void> initVideoPlayer(url) async {
      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          //aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          looping: true,
          autoInitialize: true,
          //placeholder: Center(child: Image.network(src)),
        );
        _chewieController.setVolume(0);
      });
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      child: ExpansionTile(
        onExpansionChanged: _onExpansionChanged,
        title: Text(
            '${treatment.date} - ${treatment.name ?? treatment.readableType}'),
        leading: _treatmentIcon(treatment),
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context).information),
            subtitle: Text(treatment.information),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).video),
            subtitle: _hasVideo
                ? FutureBuilder(
                    future: _videoInitialized,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                            child: CircularProgressIndicator());
                      return
                        AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: Chewie(
                            controller: _chewieController,
                          )
                        );

                    },
                  )
                : Text(AppLocalizations.of(context).noVideo),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).report),
            subtitle: Container(
              alignment: Alignment.topLeft,
              child: _hasPdf
                  ? TextButton.icon(
                      icon: Icon(Icons.file_download),
                      label: Text(AppLocalizations.of(context).showPdf),
                      onPressed: () =>
                          _pdfButtonPressed(context, treatment.pdf),
                    )
                  : Text(AppLocalizations.of(context).noReport),
            ),
          ),
          if (!userMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton.icon(
                    onPressed: null, //() => _editPressed(context),
                    icon: Icon(Icons.edit),
                    label: Text(AppLocalizations.of(context).edit)),
                TextButton.icon(
                    onPressed: () => _deletePressed(context),
                    icon: Icon(Icons.delete),
                    label: Text(AppLocalizations.of(context).delete),
                )
              ],
            )
        ],
      ),
    );
  }

  void _editPressed(BuildContext context) {
    final bloc = BlocProvider.of<UserDetailBloc>(context);
    //TODO show edit mask
    //bloc.dispatch(UpdateTreatment(treatment: treatment));
  }

  void _deletePressed(BuildContext context) {
    final bloc = BlocProvider.of<UserDetailBloc>(context);
    bloc.add(DeleteTreatment(treatment: treatment));

    final snackBar = SnackBar(
      content: Text(AppLocalizations.of(context).treatmentDeleted),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: AppLocalizations.of(context).undo,
        onPressed: () {
          _chewieController.pause();
          bloc.add(AddTreatment(treatment: treatment));
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _pdfButtonPressed(BuildContext context, Attachment pdf) async {
    final repository = RepositoryProvider.of<Repository>(context);
    final file = await repository.downloadPdf(pdf.url);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: PDFViewerScaffold(
              appBar: AppBar(
                title: Text(pdf.title),
              ),
              path: file.path,
            )));
  }

  Icon _treatmentIcon(Treatment treatment) =>
      Icon((treatment.type == TreatmentType.eigenuebung)
          ? MdiIcons.dumbbell
          : Icons.directions_run);

  void _onExpansionChanged(bool isExpanded) {
    if (_hasVideo && _videoPlayerController.value.isInitialized) {
      if (isExpanded) _chewieController..seekTo(Duration.zero);
      //..play();

      if (!isExpanded) _chewieController.pause();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

Widget _card({@required Widget child}) => Card(
    margin: EdgeInsets.all(12.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    ));
