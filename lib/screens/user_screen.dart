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
import 'package:vehicles_app/models/user.dart';

class UserScreen extends StatefulWidget {
  final Token token;
  final User user;

  const UserScreen({ required this.token, required this.user });

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showLoader = false;  

  String _firstName = '';
  String _firstNameError = '';
  bool _firstNameShowError = false;
  TextEditingController _firstNameController = TextEditingController();  

  String _lastName = '';
  String _lastNameError = '';
  bool _lastNameShowError = false;
  TextEditingController _lastNameController = TextEditingController();  

  DocumentType _documentType = DocumentType(id: 0, description: '');
  List<DocumentType> _documentTypes = [];

  String _document = '';
  String _documentError = '';
  bool _documentShowError = false;
  TextEditingController _documentController = TextEditingController();  

  String _adress = '';
  String _adressError = '';
  bool _adressShowError = false;
  TextEditingController _adressController = TextEditingController();  

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController(); 

  String _phoneNumber = '';
  String _phoneNumberError = '';
  bool _phoneNumberShowError = false;
  TextEditingController _phoneNumberController = TextEditingController();  
  
  @override
  void initState() {
    super.initState();
    _firstName = widget.user.firstName;
    _firstNameController.text = _firstName;    

    _lastName = widget.user.lastName;
    _lastNameController.text = _lastName;  

    _documentType = widget.user.documentType; 

    _document = widget.user.document;
    _documentController.text = _document;  

    _adress = widget.user.address;
    _adressController.text = _adress;  

    _email = widget.user.email;
    _emailController.text = _email;  

    _phoneNumber = widget.user.phoneNumber;
    _phoneNumberController.text = _phoneNumber;  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text( widget.user.id.isEmpty? 'Nuevo Usuario':widget.user.fullName,),          
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                  _showPhoto(),           
                  _showFirstName(),   
                  _showLastName(),  
                  _showDocumentType(),                         
                  _showDocument(),     
                  _showEmail(), 
                  _showAddress(), 
                  _showPhoneNumber(), 
                  _showButtons(),
              ],
            ),
          ),
          _showLoader? LoaderComponent(text: 'Por favor espere...'): Container(),
        ],
      ),
    );
  }

  Widget _showFirstName() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _firstNameController,
        decoration: InputDecoration(
          hintText: 'Ingrese nombres...',
          labelText: 'Nombres',
          errorText: _firstNameShowError ? _firstNameError: null,
          suffixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _firstName = value;
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
          widget.user.id.isEmpty
            ?Container()
            :SizedBox(width:20,),
          widget.user.id.isEmpty
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

    widget.user.id.isEmpty ? _addRecord() : _saveRecord();
  }

  bool _validateFields() {
     bool isValid = true;

    if(_firstName.isEmpty){
      isValid = false;
      _firstNameShowError = true;
      _firstNameError = 'Debes ingresar almenos un nombre.';
    }   
    else{
      _firstNameShowError = false;
    }

    setState(() {});
    return isValid;    
  }

  _addRecord() async{
    setState(() {
      _showLoader = true;
    });
    
    Map<String, dynamic> request ={
      'firstName': _firstName,
    };

    Response response = await ApiHelper.post(
      '/api/Users/', 
      request, 
      widget.token.token
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
    
    Map<String, dynamic> request ={
      'id': widget.user.id,
      'firstName': _firstName,
    };

    Response response = await ApiHelper.put(
      '/api/Users/', 
      widget.user.id, 
      request, 
      widget.token.token
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
    
    Response response = await ApiHelper.delete(
      '/api/Users/', 
      widget.user.id, 
      widget.token.token
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

  Widget _showPhoto() {
    return Container(
      margin: EdgeInsets.only(top: 15,),
      child: widget.user.id.isEmpty
      ?Image(
        image: AssetImage('assets/alto_ahi_loca.jpg'),
        width: 160,
        height: 160,
      )
      :ClipRRect(
        borderRadius: BorderRadius.circular(80),
        child: FadeInImage(
          placeholder: AssetImage('assets/alto_ahi_loca.jpg'),
          //image: NetworkImage(widget.user.imageFullPath), //TODOS
          image: AssetImage('assets/alto_ahi_loca.jpg'),
          width: 160,
          height: 160,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _showLastName() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _lastNameController,
        decoration: InputDecoration(
          hintText: 'Ingrese apellidos...',
          labelText: 'Apellidos',
          errorText: _lastNameShowError ? _lastNameError: null,
          suffixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _lastName = value;
        },
      ),
    );
  }

  Widget _showDocumentType() {
    return Container(

    );
  }

  Widget _showDocument() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _documentController,
        decoration: InputDecoration(
          hintText: 'Ingresa documento...',
          labelText: 'Documento',
          errorText: _documentShowError ? _documentError: null,
          suffixIcon: Icon(Icons.assignment_ind),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _document = value;
        },
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa el Email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError: null,
          suffixIcon: Icon(Icons.mail),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _email = value;
        },
      ),
    );
  }

  Widget _showAddress() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.streetAddress,
        controller: _adressController,
        decoration: InputDecoration(
          hintText: 'Ingresa tu direccion...',
          labelText: 'Direccion',
          errorText: _adressShowError ? _adressError: null,
          suffixIcon: Icon(Icons.home),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _adress = value;
        },
      ),
    );
  }

  Widget _showPhoneNumber() {
     return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.phone,
        controller: _phoneNumberController,
        decoration: InputDecoration(
          hintText: 'Ingresa tu telefono...',
          labelText: 'Telefono',
          errorText: _phoneNumberShowError ? _phoneNumberError: null,
          suffixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value){
          _phoneNumber = value;
        },
      ),
    );
  }

}