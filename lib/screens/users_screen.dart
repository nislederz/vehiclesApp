import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/document_type.dart';
import 'package:vehicles_app/models/procedure.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screens/user_screen.dart';

class UsersScreen extends StatefulWidget {
  final Token token; 

  const UsersScreen({ required this.token });

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _showLoader = false;
  String _search = '';
  bool _isFiltered = false;

  @override
  void initState() {    
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
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

  Future<Null> _getUsers() async{
    setState(() {
      _showLoader= true;  
    });

    Response response = await ApiHelper.getUsers(widget.token.token);

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
      _users = response.result;
    });

  }

  Widget _getContent() {
    return _users.length == 0
      ? _noContent()
      : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
          ? 'No hay usuarios con se criterio de busqueda.'
          : 'No hay usuarios registradas.',
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
      onRefresh: _getUsers,
      child: ListView(
        children: _users.map((e){
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
                          e.fullName,
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
          title: Text('Filtrar Usuarios.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras del nombre del usuario.'),    
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
      _getUsers();
    });
  }

  void _filter() {
    if(_search.isEmpty){
      return;
    }
    List<User> filteredList = [];
    for(var user in _users){
      if(user.fullName.toLowerCase().contains(_search.toLowerCase())){
        filteredList.add(user);
      }
    }

    setState(() {
      _users = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context, 
        MaterialPageRoute(
          builder: (context) => UserScreen(
            token: widget.token, 
            user: User(
              firstName: '', 
              lastName: '', 
              documentType: DocumentType(id: 0, description: ''), 
              document: '', 
              address: '', 
              imageId: '', 
              imageFullPath: '', 
              userType: 1, 
              fullName: '', 
              vehicles: [], 
              vehiclesCount: 0, 
              id: '', 
              userName: '', 
              email: '', 
              phoneNumber: ''
            )
          )
        )
    );

    if(result == 'yes'){
      _getUsers();
    }
  }

  void _goEdit(User user) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UserScreen(
          token: widget.token, 
          user: user,
        )
      )
    );
    
    if(result == 'yes'){
      _getUsers();
    }
  }

}