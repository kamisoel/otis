import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otis/widgets/file_picker_field.dart';
import 'add_treatment_bloc.dart';
import 'package:otis/model/model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:otis/localization.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:io';

class AddTreatmentPage extends StatefulWidget {
  final User user;

  AddTreatmentPage({Key key, @required this.user}) : super(key: key);

  @override
  _AddTreatmentPageState createState() => _AddTreatmentPageState(user: user);
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final _formKey = GlobalKey<FormState>();
  final User user;

  final _nameController = TextEditingController(text: 'Eigenübung');
  final _infoController = TextEditingController(text: 'Anzahl Wiederholungen:\nAnzahl Sätze:\nAusführungsgeschwindigkeit:\nPausendauer:');

  var dateFormat = DateFormat('dd. MMM. yyyy');

  String _name;
  String _date;
  TreatmentType _type;
  String _information;
  File _video;
  File _report;

  _AddTreatmentPageState({this.user}) : _type = TreatmentType.eigenuebung;

  @override
  void initState() {
    initializeDateFormatting('de_DE', null)
        .then((_) => dateFormat = DateFormat('dd. MMM yyyy', 'de_DE'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pr = ProgressDialog(context, type: ProgressDialogType.Download);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createTreatment),
        /*actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: null,
          )
        ],*/
      ),
      body: BlocListener<AddTreatmentBloc, AddTreatmentState>(
        // in case of error
        listener: (context, state) {
          if (state is AddTreatmentLoading) {
            pr.style(
              message: 'Add treatment...',
              progressWidget: CircularProgressIndicator(),
              borderRadius: 10.0,
              elevation: 10.0,
              progress: 0.0,
              maxProgress: 100.0,
            );
            pr.show();
          } else if (state is VideoCompressionStarted) {
            pr.update(
                progress: 20.0,
                message: "Compressing video...",
            );
          } else if (state is VideoUploadStarted) {
            pr.update(
              progress: 50.0,
              message: "Uploading video...",
            );
          } else if (state is ReportUploadStarted) {
            pr.update(
              progress: 80.0,
              message: "Uploading report...",
            );
          } else if (state is AddTreatmentFailed) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ));
          } else if (state is AddTreatmentSuccess) {
            // Adding successful
            pr.hide();
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    _addButtonPressed() {
      if (_formKey.currentState.validate()) {
        // validate form
        _formKey.currentState.save(); // Save our form now.

        BlocProvider.of<AddTreatmentBloc>(context).add(AddButtonPressed(
          user: user,
          type: _type,
          date: _date,
          name: _name,
          information: _information,
          video: _video,
          report: _report,
        ));
      }
    }

    return BlocBuilder<AddTreatmentBloc, AddTreatmentState>(
        builder: (context, state) => Form(
              key: this._formKey,
              child: ListView(
                children: <Widget>[
                  DropdownButton(
                    items: [
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).gaitAnalysis),
                        value: TreatmentType.laufanalyse,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).exercise),
                        value: TreatmentType.eigenuebung,
                      ),
                    ],
                    value: _type,
                    onChanged: (value) {
                      setState(() {
                        _type = value;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Eigenuebung',
                      labelText: AppLocalizations.of(context).title,
                      suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => setState(() {
                                _nameController.clear();
                              }),
                      ),
                    ),
                    onSaved: (value) => _name = value,
                  ),
                  DateTimeField(
                    format: dateFormat,
                    initialValue: DateTime.now(),
                    decoration: InputDecoration(
                        hintText: '2020-02-02', labelText: AppLocalizations.of(context).date),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2050));
                    },
                    readOnly: true,
                    onSaved: (value) => _date = dateFormat.format(value),
                  ),
                  TextFormField(
                    controller: _infoController,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: 'Weitere Informationen..',
                      labelText: AppLocalizations.of(context).information,
                      suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => setState(() {
                                _infoController.clear();
                              }),
                      ),
                    ),
                    onSaved: (value) => _information = value,
                  ),
                  /*Container(
                margin: EdgeInsets.only(top:20, bottom: 10),
                child:SizedBox(
                  height: 150,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (BuildContext context, int index) => Card(
                      child: Container (
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(25),
                          child:
                            index == 0
                              ? (_pdf.notEmpty? Text('Report check') : Text('Kein Report'))
                              : (_video.notEmpty? Text('Video check') : Text('Kein Video')),
                      ),
                    ),
                  ),
                ),
              ),*/
                  FilePickerField.forVideo(
                    labelText: AppLocalizations.of(context).video,
                    onSaved: (file) => setState(() {
                      _video = file;
                    }),
                  ),
                  FilePickerField.forDocument(
                    labelText: AppLocalizations.of(context).report,
                    fileExtension: 'pdf',
                    onSaved: (file) => setState(() {
                      _report = file;
                    }),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text(
                        AppLocalizations.of(context).createTreatment,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: state is! AddTreatmentLoading
                          ? _addButtonPressed
                          : null,
                      color: Colors.green,
                    ),
                    margin: EdgeInsets.only(top: 20.0),
                  ),
                ],
              ),
            ));
  }
}
