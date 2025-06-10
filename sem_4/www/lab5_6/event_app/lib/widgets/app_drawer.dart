import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:event_app/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  authProvider.isAuthenticated
                      ? 'Welcome, ${authProvider.user?.username}'
                      : 'Event App',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                if (authProvider.isAuthenticated)
                  Text(
                    'Role: ${authProvider.user?.role}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              context.go('/events');
              Navigator.pop(context);
            },
          ),
          if (authProvider.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Create Event'),
              onTap: () {
                context.go('/events/create');
                Navigator.pop(context);
              },
            ),
          if (authProvider.isAdmin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                context.go('/users');
                Navigator.pop(context);
              },
            ),
          if (authProvider.isAdmin)
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register Admin'),
              onTap: () {
                context.go('/register-admin');
                Navigator.pop(context);
              },
            ),
          const Divider(),
          if (authProvider.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authProvider.logout();
                context.go('/login');
                Navigator.pop(context);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                context.go('/login');
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}