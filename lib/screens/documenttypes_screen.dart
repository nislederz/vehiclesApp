import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vehicles_app/screens/brand_screen.dart';
import 'package:vehicles_app/screens/procedure_screen.dart';

import 'documenttype_screen.dart';

class DocumentTypesScreen extends StatefulWidget {
  final Token token;  

  DocumentTypesScreen({required this.token});

  @override
  _DocumentTypesScreenState createState() => _DocumentTypesScreenState();
}

class _DocumentTypesScreenState extends State<DocumentTypesScreen> {
  List<DocumentType> _documenttypes = [];
  bool _showLoader = false;
  String _search = '';
  bool _isFiltered = false;

  @override
  void initState() {    
    super.initState();
    _getDocumentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipos de Documento'),
         actions: <Widget>[
          _isFiltered
          ? IconButton(
            onPressed: _removeFilter,
             icon: Icon(Icons.filter_none)
          )
          : IconButton(
            onPressed: _showFilter,
             icon: Icon(Icons.filter_alt)
          )
        ],     
      ),
      body: Center(
        child: _showLoader? LoaderComponent(text: 'Por favor espere...',) :_getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getDocumentTypes() async{
    setState(() {
      _showLoader= true;  
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

    Response response = await ApiHelper.getDocumentTypes();

    setState(() {
      _showLoader= false;
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

    setState(() {
      _documenttypes = response.result;
    });

  }

  Widget _getContent() {
    return _documenttypes.length == 0
      ? _noContent()
      : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
          ? 'No hay documentos con se criterio de busqueda.'
          : 'No hay documentos registradas.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getDocumentTypes,
      child: ListView(
        children: _documenttypes.map((e){
          return Card(
            child: InkWell(
              onTap: ()=> _goEdit(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        Icon(Icons.arrow_forward_ios)
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
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Filtrar Documentos.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras del tipo de documento.'),    
              SizedBox(height: 10,),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Criterio de busqueda...',
                  labelText: 'Buscar',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value){
                  _search = value;                                      
                },
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar')
            ),
            TextButton(
              onPressed: () => _filter(),
              child: Text('Filtrar')
            )
          ],
        );
      }
    );
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
      _getDocumentTypes();
    });
  }

  void _filter() {
    if(_search.isEmpty){
      return;
    }
    List<DocumentType> filteredList = [];
    for(var documenttypes in _documenttypes){
      if(documenttypes.description.toLowerCase().contains(_search)){
        filteredList.add(documenttypes);
      }
    }

    setState(() {
      _documenttypes = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context, 
        MaterialPageRoute(
          builder: (context) => DocumentTypeScreen(
            token: widget.token, 
            documenttype: DocumentType(description: '', id: 0,), 
          )
        )
    );

    if(result == 'yes'){
      _getDocumentTypes();
    }
  }

  void _goEdit(DocumentType documentType) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DocumentTypeScreen(
          token: widget.token, 
          documenttype: documentType,
        )
      )
    );
    
    if(result == 'yes'){
      _getDocumentTypes();
    }
  }

}