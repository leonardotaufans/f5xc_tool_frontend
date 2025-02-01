import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/widgets/user_expansion_tile.dart';
import 'package:flutter/material.dart';
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
            child: UserExpansionTile(model: model.model ?? empty),
          ),
          SizedBox(
            height: 16,
          ),
          Visibility(
            visible: isAdmin,
            child: Text(
              "User List",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Visibility(
              visible: isAdmin,
              child: Wrap(
                children: _buildWidget(users),
              ))
        ],
      ),
    );
  }

  List<Widget> _buildWidget(ListUserResponse model) {
    List<Widget> widgets = [];
    if (model.userList == null) {
      return [];
    }
    List<UserModel> list = model.userList ?? [];
    widgets = list.map((i) => SmallerUserExpansionTile(model: i)).toList();
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
