// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vehicles_app/components/loader_component.dart';

import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/procedure_screen.dart';

class ProceduresScreen extends StatefulWidget {
  final Token token;

  ProceduresScreen({required this.token});

  @override
  _ProceduresScreenState createState() => _ProceduresScreenState();
}

class _ProceduresScreenState extends State<ProceduresScreen> {
  List<Procedure> _procedures = [];
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procedimientos'),
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponet(
                text: 'Por favor espere...',
              )
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcedureScreen(
                token: widget.token,
                procedure: Procedure(id: 0, description: '', price: 0),
              ),
            ),
          );
        },
      ),
    );
  }

  void _getProcedures() async {
    setState(() {
      _showLoader = true;
    });
    var url = Uri.parse(
        '${Constans.apiUrl}?function=Procedures&access_key=${Constans.accessKey}');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${widget.token.token}'
      },
    );
    setState(() {
      _showLoader = false;
    });
    var body = response.body;
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        _procedures.add(Procedure.fromJson(item));
      }
    }
    //print(_procedures);
  }

  Widget _getContent() {
    return _procedures.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Text(
        'No hay procedimientos',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _getListView() {
    return ListView(
      children: _procedures.map((e) {
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProcedureScreen(
                    token: widget.token,
                    procedure: e,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.description,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        '${NumberFormat.currency(symbol: '\$').format(e.price)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
