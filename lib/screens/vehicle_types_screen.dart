import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';

import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/vehicle_type.dart';
import 'package:vehicles_app/screens/brand_screen.dart';
import 'package:vehicles_app/screens/vehicle_type_screen.dart';

class VehicleTypesScreen extends StatefulWidget {
  final Token token;

  VehicleTypesScreen({required this.token});

  @override
  _VehicleTypesScreenState createState() => _VehicleTypesScreenState();
}

class _VehicleTypesScreenState extends State<VehicleTypesScreen> {
  List<VehicleType> _vehicleTypes = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipos de Vehículos'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
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
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getBrands() async {
    setState(() {
      _showLoader = true;
    });

    Response response = await ApiHelper.getVehicleTypes(widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ],
      );
      return;
    }
    setState(() {
      _vehicleTypes = response.result;
    });
  }

  Widget _getContent() {
    return _vehicleTypes.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Text(
        _isFiltered
            ? 'No hay marcas con ese criterio de busqueda'
            : 'No hay marcas registrados.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getBrands,
      child: ListView(
        children: _vehicleTypes.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
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
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar tipos de vehiculos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Escriba las primeras letras de la marca'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Criterio de búsqueda...',
                    labelText: 'Buscar',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _search = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => _filter(),
                child: Text('Filtrar'),
              ),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getBrands();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<VehicleType> filteredList = [];
    for (var vehicleType in _vehicleTypes) {
      if (vehicleType.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(vehicleType);
      }
    }
    setState(() {
      _vehicleTypes = filteredList;
      _isFiltered = true;
    });
    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleTypeScreen(
          token: widget.token,
          vehicleType: VehicleType(id: 0, description: ''),
        ),
      ),
    );
    if (result == 'yes') {
      _getBrands();
    }
  }

  void _goEdit(VehicleType vehicleType) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleTypeScreen(
          token: widget.token,
          vehicleType: vehicleType,
        ),
      ),
    );
    if (result == 'yes') {
      _getBrands();
    }
  }
}
