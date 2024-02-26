import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('user_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  final _userBox = Hive.box('user_box');

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    final data = _userBox.keys.map((key) {
      final user = _userBox.get(key);
      return {
        "key": key,
        "name": user["name"],
        "number": user["number"],
        "gender": user["gender"]
      };
    }).toList();
    setState(() {
      _users = data.reversed.toList();
      print(_users.length);
    });
  }

  Future<void> _createUser(Map<String, dynamic> newUser) async {
    await _userBox.add(newUser);
    _refreshUsers();
  }

  Future<void> _updateUser(int userKey, Map<String, dynamic> user) async {
    await _userBox.put(userKey, user);
    _refreshUsers();
  }

  Future<void> _deleteUser(int userKey) async {
    await _userBox.delete(userKey);
    _refreshUsers();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User has been Deleted')));
  }

  void _showForm(BuildContext ctx, int? userKey) async {
    if (userKey != null) {
      final existingUser =
          _users.firstWhere((element) => element['key'] == userKey);
      _nameController.text = existingUser['name'];
      _numberController.text = existingUser['number'];
      _genderController.text = existingUser['gender'];
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(hintText: 'Number'),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(hintText: 'Gender'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (userKey == null) {
                  _createUser({
                    "name": _nameController.text,
                    "number": _numberController.text,
                    "gender": _genderController.text
                  });
                }
                if (userKey != null) {
                  _updateUser(userKey, {
                    'name': _nameController.text.trim(),
                    'number': _numberController.text.trim(),
                    'gender': _genderController.text.trim()
                  });
                }
                _nameController.text = "";
                _numberController.text = "";
                _genderController.text = "";
                Navigator.of(context).pop();
              },
              child: Text(userKey == null ? 'Create New' : 'Update'),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsForm(BuildContext ctx, int? userKey) async {
    final existingUser =
        _users.firstWhere((element) => element['key'] == userKey);

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        width: double.infinity,
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Details',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            SizedBox(
              height: 15,
            ),
            Text("Name: ${existingUser['name']}",style: TextStyle(fontSize: 20),),
            SizedBox(
              height: 10,
            ),
            Text("Number: ${existingUser['number']}",style: TextStyle(fontSize: 20),),
            SizedBox(
              height: 10,
            ),
            Text("Gender: ${existingUser['gender']}",style: TextStyle(fontSize: 20),),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('User_CRUD'),
      ),
      body: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (_, index) {
            final currentUser = _users[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(currentUser['name'],style: TextStyle(fontSize: 18),),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showForm(context, currentUser['key']),
                    ),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteUser(currentUser['key'])),
                  ],
                ),
                onTap: () => _showDetailsForm(context, currentUser['key']),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}