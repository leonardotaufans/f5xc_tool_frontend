import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/query_helper/user_query.dart';
import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/model/generic_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:flutter/material.dart';

class SmallerUserExpansionTile extends StatelessWidget {
  final UserModel model;
  final UserModel myself;

  const SmallerUserExpansionTile(
      {super.key, required this.model, required this.myself});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Card(
          child: UserExpansionTile(
        model: model,
        myself: myself,
      )),
    );
  }
}

class UserExpansionTile extends StatelessWidget {
  const UserExpansionTile(
      {super.key, required this.model, required this.myself});

  final UserModel myself;
  final UserModel model;

  @override
  Widget build(BuildContext context) {
    bool isEditingAllowed =
        (model.username ?? "false") == (myself.username ?? "true") ||
            (myself.role == "admin");
    return ExpansionTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: model.role == "admin" ? Colors.red.shade300 : Colors.blue.shade300,
            maxRadius: 20,
            minRadius: 8,
            child: model.role == "admin"
                ? Icon(Icons.security, color: Colors.white,)
                : Icon(Icons.person_outline, color: Colors.white)),
        title: Text(model.fullName ??
            "Authentications are missing. You need to logout and login again."),
        subtitle: Text((model.role ?? UserRole.guest).toUpperCase()),
        children: [
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.person),
            ),
            onTap: isEditingAllowed
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UserUpdate(
                            userModel: myself,
                            position: UpdateUserRows.fullName,
                            username: model.username ?? "",
                            currentValue: model.fullName,
                          );
                        });
                  }
                : null,
            title: Text('Full Name'),
            subtitle: Text(model.fullName ?? ""),
          ),
          ListTile(
            onTap: isEditingAllowed
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UserUpdate(
                            userModel: myself,
                            position: UpdateUserRows.role,
                            username: model.username ?? "",
                            currentValue: model.role,
                          );
                        });
                  }
                : null,
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.supervised_user_circle_outlined),
            ),
            title: Text('Role'),
            subtitle: Text(model.role ?? "guest"),
          ),
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.alternate_email),
            ),
            title: Text('Username'),
            subtitle: Text(model.username ?? ""),
          ),
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.email),
            ),
            title: Text('Email'),
            subtitle: Text(model.email ?? ""),
            onTap: isEditingAllowed
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UserUpdate(
                            userModel: myself,
                            position: UpdateUserRows.email,
                            username: model.username ?? "",
                            currentValue: model.email,
                          );
                        });
                  }
                : null,
          ),
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.business),
            ),
            title: Text('Organization'),
            subtitle: Text(model.organization ?? ""),
            onTap: isEditingAllowed
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UserUpdate(
                            userModel: myself,
                            position: UpdateUserRows.company,
                            username: model.username ?? "",
                            currentValue: model.organization,
                          );
                        });
                  }
                : null,
          ),
          ListTile(
            leading: AdjustedCircleAvatar(
              backgroundColor:
                  (model.isActive ?? false) ? Colors.green : Colors.red,
              child: (model.isActive ?? false)
                  ? Icon(Icons.verified)
                  : Icon(Icons.warning),
            ),
            title: Text('User Status'),
            subtitle: Text((model.isActive ?? false)
                ? "Email Verified.\nUser has verified their email."
                : "Email not verified. \nTap to resend email verification."),
            onTap: (model.isActive ?? false) ? null : () {},
          ),
          ListTile(
            leading: AdjustedCircleAvatar(child: Icon(Icons.calendar_month)),
            title: Text('Registration Date'),
            subtitle: Text(RequestHelper().dateTimeFromEpoch(
                model.registrationDate ?? 0, 'Asia/Singapore')),
          ),
          ListTile(
            leading: AdjustedCircleAvatar(child: Icon(Icons.group_add)),
            title: Text('Registered by'),
            subtitle: Text(model.registeredBy ?? ""),
          ),
          ListTile(
            leading: AdjustedCircleAvatar(child: Icon(Icons.password)),
            trailing: Icon(Icons.navigate_next),
            title: Text('Update Password'),
            onTap: isEditingAllowed
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UserUpdate(
                            userModel: myself,
                            position: UpdateUserRows.password,
                            username: model.username ?? "",
                            currentValue: '',
                          );
                        });
                  }
                : null,
          )
        ]);
  }
}

class UserUpdate extends StatefulWidget {
  final String? currentValue;
  final String position;
  final String username;
  final UserModel userModel;

  const UserUpdate(
      {super.key,
      required this.position,
      required this.username,
      this.currentValue,
      required this.userModel});

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  late TextEditingController _controller;
  late TextEditingController _secondController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "${widget.currentValue}");
    _secondController = TextEditingController(text: "${widget.currentValue}");
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: buildTitle(),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.2,
        child: updateWidget(),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (_controller.text.isEmpty) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Value cannot be empty.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Dismiss'),
                            )
                          ],
                        ));
              }
              NoResponseModel req = await UserQueryHelper().updateUser(
                  position: widget.position,
                  username: widget.username,
                  valueChanged: _controller.text);
              if (req.statusCode > 200) {
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Update ${widget.position} Failed'),
                          content: Text('${req.statusMessage}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Dismiss'),
                            )
                          ],
                        );
                      });
                }
              } else {
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (innerContext) {
                        return AlertDialog(
                          title: Text('Update ${widget.position}'),
                          content: Text(
                              "${widget.username}'s ${widget.position} has been updated."),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(innerContext);
                                  Navigator.pop(context);
                                },
                                child: Text('Close'))
                          ],
                        );
                      });
                }
              }
            },
            child: Text('Submit'))
      ],
    );
  }

  buildTitle() {
    switch (widget.position) {
      case UpdateUserRows.fullName:
        return Text('Full Name');
      case UpdateUserRows.role:
        return Text('Role');
      case UpdateUserRows.email:
        return Text('Email');
      case UpdateUserRows.company:
        return Text('Company');
      case UpdateUserRows.password:
        return Text('Password');
      case UpdateUserRows.userStatus:
        return Text('User Status');
      default:
        return Text('Default');
    }
  }

  Widget updateWidget() {
    switch (widget.position) {
      case UpdateUserRows.fullName:
        return ListView(
          shrinkWrap: true,
          children: [
            Text('Enter a new name'),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  label: Text('Full Name'), border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        );
      case UpdateUserRows.password:
        return ListView(
          children: [
            Text('Enter your new password'),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: InputDecoration(
                  label: Text('Password'), border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _secondController,
              obscureText: true,
              decoration: InputDecoration(
                  label: Text('Verify Password'), border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
          ],
        );
      case UpdateUserRows.company:
        return ListView(
          shrinkWrap: true,
          children: [
            Text('Enter Company/Organization Name'),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  label: Text('Company/Organization Name'),
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        );
      case UpdateUserRows.email:
        return ListView(
          shrinkWrap: true,
          children: [
            Text('Enter email'),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  label: Text('Email'), border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),

            //todo: email verification and make user need to verify email
          ],
        );
      case UpdateUserRows.role:
        return ListView(
          shrinkWrap: true,
          children: [
            Text("Choose ${widget.username}'s new role"),
            SizedBox(
              height: 16,
            ),
            DropdownMenu(
                controller: _controller,
                width: MediaQuery.of(context).size.width * 0.2,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: UserRole.admin, label: 'admin'),
                  DropdownMenuEntry(value: UserRole.guest, label: 'guest'),
                ]),
            SizedBox(
              height: 16,
            ),
          ],
        );
      default:
        return Text('Default');
    }
  }
}

class AdjustedCircleAvatar extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AdjustedCircleAvatar(
      {super.key,
      required this.child,
      this.backgroundColor,
      this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        maxRadius: 20,
        minRadius: 8,
        foregroundColor: foregroundColor ?? Colors.white70,
        backgroundColor: backgroundColor ?? Colors.blueGrey.withAlpha(100),
        child: child);
  }
}
