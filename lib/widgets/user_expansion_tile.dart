import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:flutter/material.dart';

class SmallerUserExpansionTile extends StatelessWidget {
  final UserModel model;

  const SmallerUserExpansionTile({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.23,
      child: Card(child: UserExpansionTile(model: model)),
    );
  }
}

class UserExpansionTile extends StatelessWidget {
  const UserExpansionTile({
    super.key,
    required this.model,
  });

  final UserModel model;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        dense: true,
        leading: CircleAvatar(
          maxRadius: 20,
          minRadius: 8,
          child: Text(
            RequestHelper().getInitialsFromName(model.fullName ?? "Not found"),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(model.fullName ??
            "Authentications are missing. You need to logout and login again."),
        subtitle: Text((model.role ?? UserRole.guest).toUpperCase()),
        children: [
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.person),
            ),
            onTap: () {}, //todo: update full name
            title: Text('Full Name'),
            subtitle: Text(model.fullName ?? ""),
          ),
          ListTile(
            onTap: () {}, //todo: update role
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.person),
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
            onTap: () {},
          ),
          ListTile(
            leading: AdjustedCircleAvatar(
              child: Icon(Icons.business),
            ),
            title: Text('Company'),
            subtitle: Text(model.organization ?? ""),
            onTap: () {},
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
            onTap: () {},
          )
        ]);
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
