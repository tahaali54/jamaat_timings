import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jamaat_timings/models.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage(
      {Key key,
      @required String pageTitle,
      MosqueDetail mosqueDetail,
      @required bool isUpdate})
      : _pageTitle = pageTitle,
        _isUpdate = isUpdate,
        _mosqueDetail = mosqueDetail,
        super(key: key);

  final String _pageTitle;
  final bool _isUpdate;
  final MosqueDetail _mosqueDetail;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(_pageTitle)),
      body: MosqueDetailForm(_isUpdate, _mosqueDetail),
    );
  }
}

class MosqueDetailForm extends StatefulWidget {
  MosqueDetailForm(this._isUpdate, this._mosqueDetail);
  final bool _isUpdate;
  final MosqueDetail _mosqueDetail;

  @override
  MosqueDetailFormState createState() {
    return MosqueDetailFormState();
  }
}

class MosqueDetailFormState extends State<MosqueDetailForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fajarController = TextEditingController();
  TextEditingController _zuharController = TextEditingController();
  TextEditingController _asarController = TextEditingController();
  TextEditingController _maghribController = TextEditingController();
  TextEditingController _ishaController = TextEditingController();

  TextEditingController _briefAddrCtrl = TextEditingController();
  TextEditingController _addrL1Ctrl = TextEditingController();
  TextEditingController _addrL2Ctrl = TextEditingController();
  TextEditingController _imgUrlCtrl = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _extraController = TextEditingController();
  

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget._isUpdate) {
      _fajarController.text = widget._mosqueDetail.fajr;
      _zuharController.text = widget._mosqueDetail.zuhar;
      _asarController.text = widget._mosqueDetail.asar;
      _maghribController.text = widget._mosqueDetail.maghrib;
      _ishaController.text = widget._mosqueDetail.isha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
          padding: EdgeInsets.only(top: 16.0),
          children: _populateData().toList()),
    );
  }

  String _validateTimings(String value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String _validateAddress(String value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  Iterable<Widget> _populateData() {
    return <Widget>[
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_dawn.png")),
        title: TextFormField(
          controller: _fajarController,
          decoration: InputDecoration(
              labelText: 'Fajr', hintText: 'Enter timings (e.g. 5:30 am)'),
          validator: (value) => _validateTimings(value),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_sun.png")),
        title: TextFormField(
          controller: _zuharController,
          decoration: InputDecoration(
              labelText: 'Zuhar', hintText: 'Enter timings (e.g. 1:30 pm)'),
          validator: (value) => _validateTimings(value),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_cloudy.png")),
        title: TextFormField(
          controller: _asarController,
          decoration: InputDecoration(
              labelText: 'Asar', hintText: 'Enter timings (e.g. 5:15 pm)'),
          validator: (value) => _validateTimings(value),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_sunset.png")),
        title: TextFormField(
          controller: _maghribController,
          decoration: InputDecoration(
              labelText: 'Maghrib', hintText: 'Enter timings (e.g. 6:30 pm)'),
          validator: (value) => _validateTimings(value),
        ),
      ),
      ListTile(
        leading: ImageIcon(AssetImage("assets/ic_moon.png")),
        title: TextFormField(
          controller: _ishaController,
          decoration: InputDecoration(
              labelText: 'Isha', hintText: 'Enter timings (e.g. 10:00 pm)'),
          validator: (value) => _validateTimings(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _extraController,
          decoration: InputDecoration(
              labelText: 'Annoucements', hintText: 'Extra field for announcments'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _briefAddrCtrl,
          decoration: InputDecoration(
              labelText: 'Brief Address', hintText: 'Enter area name'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _addrL1Ctrl,
          decoration: InputDecoration(
              labelText: 'Address Line 1', hintText: 'Enter address specifics'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _addrL2Ctrl,
          decoration: InputDecoration(
              labelText: 'Address Line 2', hintText: 'Enter address broadly'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _imgUrlCtrl,
          decoration: InputDecoration(
              labelText: 'Image URL', hintText: 'Web hosted image url ending with file type'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      widget._isUpdate ? Container() : ListTile(
        title: TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
              labelText: 'Mosque Name', hintText: 'Enter name of mosque'),
          validator: (value) => _validateAddress(value),
        ),
      ),
      ListTile(
        title: widget._isUpdate
            ? new StreamBuilder(
                stream: Firestore.instance.collection('mosques').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  return RaisedButton(
                    textColor: Colors.white,
                    child: Text('Update'),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await _updateMosqueDetails(snapshot, context);
                          },
                  );
                })
            : RaisedButton(
                textColor: Colors.white,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Create'),
              ),
      ),
    ];
  }

  Future _updateMosqueDetails(
      AsyncSnapshot snapshot, BuildContext context) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      DocumentSnapshot ds;
      snapshot.data.documents.forEach((item) {
        if (item['name'] == widget._mosqueDetail.name) ds = item;
      });
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(ds.reference);
        await transaction.update(freshSnap.reference, {
          'fajr': _fajarController.text,
          'zuhar': _zuharController.text,
          'asar': _asarController.text,
          'maghrib': _maghribController.text,
          'isha': _ishaController.text,
        });
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Timings updated')));
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}
