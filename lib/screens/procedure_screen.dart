import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';

class ProcedureScreen extends StatefulWidget {
  final Token token;
  final Procedure procedure;

  ProcedureScreen({required this.token, required this.procedure});

  @override
  _ProcedureScreenState createState() => _ProcedureScreenState();
}

class _ProcedureScreenState extends State<ProcedureScreen> {
  bool _showLoader = false;

  String _description = '';
  String _descriptionError = '';
  bool _descriptionShowError = false;
  TextEditingController _descriptionController = TextEditingController();

  String _price = '';
  String _priceError = '';
  bool _priceShowError = false;
  TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _description = widget.procedure.description;
    _descriptionController.text = _description;
    _price = widget.procedure.price.toString();
    _priceController.text = _price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.procedure.id == 0
                ? 'Nuevo procedimiento'
                : widget.procedure.description,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                _showDescription(),
                _showPrice(),
                _showButtons(),
              ],
            ),
            _showLoader
                ? LoaderComponet(
                    text: 'Por favor espere...',
                  )
                : Container(),
          ],
        ));
  }

  Widget _showDescription() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: false,
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: 'Ingresa una descripción...',
          labelText: 'Descripción',
          errorText: _descriptionShowError ? _descriptionError : null,
          suffixIcon: Icon(Icons.description),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _description = value;
        },
      ),
    );
  }

  Widget _showPrice() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: false,
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: _priceController,
        decoration: InputDecoration(
          hintText: 'Ingresa un precio...',
          labelText: 'Precio',
          errorText: _priceShowError ? _priceError : null,
          suffixIcon: Icon(Icons.attach_money),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          _price = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showGuardarButton(),
              widget.procedure.id == 0
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              widget.procedure.id == 0 ? Container() : _showBorrarButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showGuardarButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Guardar'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _save(),
      ),
    );
  }

  Widget _showBorrarButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Borrar'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFFB4161B);
          }),
        ),
        onPressed: () => _confirmDelete(),
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.procedure.id == 0 ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
    bool isValid = true;

    if (_description.isEmpty) {
      isValid = false;
      _descriptionShowError = true;
      _descriptionError = 'Debes ingresar una descripción.';
    } else {
      _descriptionShowError = false;
    }

    if (_price.isEmpty && _price == '') {
      isValid = false;
      _priceShowError = true;
      _priceError = 'Debes ingresar el precio.';
    } else {
      double price = double.parse(_price);
      if (price <= 0) {
        isValid = false;
        _priceShowError = true;
        _priceError = 'Debes ingresar un precio mayor a cero.';
      } else {
        _priceShowError = false;
      }
      _priceShowError = false;
    }

    setState(() {});
    return isValid;
  }

  _addRecord() async {
    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {
      'description': _description,
      'price': double.parse(_price),
    };

    Response response =
        await ApiHelper.post('ProceduresAdd', request, widget.token.token);

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

    Navigator.pop(context);
  }

  _saveRecord() async {
    setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request = {
      'id': widget.procedure.id,
      'description': _description,
      'price': double.parse(_price),
    };

    Response response = await ApiHelper.put('ProceduresPut',
        widget.procedure.id.toString(), request, widget.token.token);

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

    Navigator.pop(context);
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
      context: context,
      title: 'Confirmación',
      message: '¿Estás seguro de querer borrar el registro?',
      actions: <AlertDialogAction>[
        AlertDialogAction(key: 'no', label: 'No'),
        AlertDialogAction(key: 'yes', label: 'Si'),
      ],
    );

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
    setState(() {
      _showLoader = true;
    });
    Map<String, dynamic> request = {'id': widget.procedure.id};
    Response response = await ApiHelper.delete('ProceduresDelete',
        widget.procedure.id.toString(), request, widget.token.token);

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

    Navigator.pop(context);
  }
}
