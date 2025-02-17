import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/query_helper/user_query.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/generic_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/widgets/user_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late UserResponse model = UserResponse(statusCode: 204);
  late ListUserResponse users = ListUserResponse(statusCode: 204);
  UserModel empty = UserModel(
      role: UserRole.guest,
      email: '',
      fullName: '',
      isActive: false,
      organization: '',
      registeredBy: '',
      registrationDate: 0,
      username: '');

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (model.statusCode == 401) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Login'),
                  )
                ],
                content: Text("You need to log back in to continue."),
              );
            });
      }
    });
    bool isAdmin = model.statusCode == 200 &&
        model.model != null &&
        model.model!.role == UserRole.admin;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: ListView(
        shrinkWrap: false,
        children: [
          Text(
            "You're logged in as",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 8,
          ),
          //todo: add empty view above this card
          Card(
            child: UserExpansionTile(
              model: model.model ?? empty,
              myself: model.model ?? empty,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Visibility(
            visible: isAdmin,
            child: Row(
              children: [
                Text(
                  "User List",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Visibility(
              visible: isAdmin,
              child: Wrap(
                children: _buildWidget(users, model.model ?? empty),
              ))
        ],
      ),
    );
  }

  List<Widget> _buildWidget(ListUserResponse model, UserModel myself) {
    List<Widget> widgets = [
      Card(
          child: IconButton(
              iconSize: 36,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return NewUserDialog();
                    });
              },
              icon: Icon(Icons.add)))
    ];
    if (model.userList == null) {
      return [];
    }
    List<UserModel> list = model.userList ?? [];
    widgets.addAll(list
        .map((i) => SmallerUserExpansionTile(
              model: i,
              myself: myself,
            ))
        .toList());
    return widgets;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
      setState(() {
        model = value;
      });
    });
    getAllUsers().then((value) {
      setState(() {
        users = value;
      });
    });
  }

  Future<UserResponse> getCurrentUser() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    UserResponse auth = await SqlQueryHelper().getMyself(bearer);
    return auth;
  }

  Future<ListUserResponse> getAllUsers() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    ListUserResponse users = await SqlQueryHelper().getUsers(bearer);
    return users;
  }
}

class NewUserDialog extends StatefulWidget {
  const NewUserDialog({super.key});

  @override
  State<NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<NewUserDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;
  late TextEditingController _orgController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _roleController = TextEditingController();
    _emailController = TextEditingController();
    _orgController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: Text('Create User'),
      content: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.8,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Username
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("^[a-zA-Z0-9._-]+"))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty.';
                  }
                  if (value.length < 5) {
                    return 'Username cannot be shorter than 5 characters.';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                maxLines: 1,
                maxLength: 30,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                controller: _usernameController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                    label: Text('Username'),
                    hintText: "Username (5-20 characters, only hyphens (-), "
                        "underscores (_) and dots (.) allowed.[A-z._-]"),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (!value.contains('@')) {
                    return "Email format is invalid";
                  }
                  return null;
                },
                inputFormatters: [],
                maxLines: 1,
                maxLength: 50,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    hintText: "Email Address",
                    label: Text('Email')),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                maxLines: 1,
                maxLength: 100,
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                    label: Text('Password')),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
                maxLines: 1,
                maxLength: 100,
                keyboardType: TextInputType.text,
                controller: _fullNameController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    label: Text('Full Name')),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Organization cannot be empty';
                  }
                  return null;
                },
                maxLines: 1,
                maxLength: 100,
                keyboardType: TextInputType.text,
                controller: _orgController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                    label: Text('Organization')),
              ),
              DropdownMenu(
                  width: size.width * 0.8,
                  leadingIcon: Icon(Icons.group),
                  initialSelection: 'guest',
                  controller: _roleController,
                  label: Text("User Role"),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                        value: 'guest', label: 'guest'.toUpperCase()),
                    DropdownMenuEntry(
                        value: 'admin', label: 'admin'.toUpperCase()),
                  ])
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              UserCreate user = UserCreate(
                  username: _usernameController.text,
                  fullName: _fullNameController.text,
                  role: _roleController.text,
                  email: _emailController.text,
                  isActive: false,
                  organization: _orgController.text,
                  password: _passwordController.text);
              NoResponseModel query = await UserQueryHelper().createUser(user);
              if (query.statusCode > 399) {
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('User Creation Failed'),
                          content: Text(
                              'Error found while creating user: ${query.statusMessage}'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'))
                          ],
                        );
                      });
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            }
          },
          child: Text('Submit'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
