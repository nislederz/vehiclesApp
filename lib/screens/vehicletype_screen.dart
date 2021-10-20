import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/vehicle_type.dart';

class VehicleTypeScreen extends StatefulWidget {
  final Token token;
  final VehicleType vehicletype;
  
  VehicleTypeScreen({required this.token, required this.vehicletype});

  @override
  _VehicleTypeScreenState createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
bool _showLoader = false;  
  String _description = '';
  String _descriptionError = '';
  bool _descriptionShowError = false;
  TextEditingController _descriptionController = TextEditingController();  
  
  @override
  void initState() {
    super.initState();
    _description = widget.vehicletype.description;
    _descriptionController.text = _description;    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text( widget.vehicletype.id == 0 ? 'Nueva Tipo de Vehicle':widget.vehicletype.description,),          
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
                _showDescription(),           
                _showButtons(),
            ],
          ),
          _showLoader? LoaderComponent(text: 'Por favor espere...'): Container(),
        ],
      ),
    );
  }

  Widget _showDescription() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: 'Ingresa una descripcion.',
          labelText: 'Descripcion',
          errorText: _descriptionShowError ? _descriptionError: null,
          suffixIcon: Icon(Icons.description),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _description = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text('Guardar.'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states){
                    return Color(0xFF120E43);
                  }
                ),
              ),
              onPressed: () => _save(), 
            ),
          ),
          widget.vehicletype.id == 0 
            ?Container()
            :SizedBox(width:20,),
          widget.vehicletype.id == 0
            ?Container()
            :Expanded(
              child: ElevatedButton(
                child: Text('Borrar'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states){
                      return Color(0xFFB4161B);
                    }
                  ),
                ),
                onPressed: () => _confirmDelete(), 
              ),
            ),
        ],
      ),
    );
  }

  void _save() {
    if(!_validateFields()){
      return;
    }

    widget.vehicletype.id == 0? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
     bool isValid = true;

    if(_description.isEmpty){
      isValid = false;
      _descriptionShowError = true;
      _descriptionError = 'Debes ingresar una descripcion.';
    }   
    else{
      _descriptionShowError = false;
    }

    setState(() {});
    return isValid;    
  }

  _addRecord() async{
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }
    
    Map<String, dynamic> request ={
      'id': widget.vehicletype.id,
      'description': _description,
    };

    Response response = await ApiHelper.post(
      '/api/VehicleTypes/', 
      request, 
      widget.token
    );

    setState(() {
      _showLoader = false;
    });

    if(!response.isSuccess){
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }   

    Navigator.pop(context, 'yes') ;
  }

  _saveRecord() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }
    
    Map<String, dynamic> request ={
      'id': widget.vehicletype.id,
      'description': _description,
    };

    Response response = await ApiHelper.put(
      '/api/VehicleTypes/', 
      widget.vehicletype.id.toString(), 
      request, 
      widget.token
    );

    setState(() {
      _showLoader = false;
    });

    if(!response.isSuccess){
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }   

    Navigator.pop(context, 'yes') ;
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
      context: context,
      title: 'Comfirmacion',
      message: 'Estas seguro de borrar el registro?',
      actions: <AlertDialogAction>[
        AlertDialogAction(key: 'no', label: 'No'),
        AlertDialogAction(key: 'yes', label: 'Si'),
      ]
    );

    if(response == 'yes'){
      _deleteRecord();
    }

  }

  void _deleteRecord() async{
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }
    
    Response response = await ApiHelper.delete(
      '/api/VehicleTypes/', 
      widget.vehicletype.id.toString(), 
      widget.token
    );

    setState(() {
      _showLoader = false;
    });

    if(!response.isSuccess){
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }   

    Navigator.pop(context, 'yes') ;
  }

}