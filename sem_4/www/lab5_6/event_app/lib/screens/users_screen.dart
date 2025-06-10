import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Dodano import go_router
import 'package:provider/provider.dart';
import 'package:event_app/providers/user_provider.dart';
import 'package:event_app/widgets/app_drawer.dart';
import 'package:event_app/providers/auth_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }

  Future<void> _refreshUsers() async {
    await Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Users (Admin Panel)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          if (authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.white),
              onPressed: () {
                GoRouter.of(context).push('/users/register-admin');
              },
              tooltip: 'Register New Admin',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 50),
              const SizedBox(height: 10),
              Text(
                'Error loading users: ${userProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _refreshUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      )
          : userProvider.users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined, color: Colors.grey[400], size: 50),
            const SizedBox(height: 10),
            const Text(
              'No users found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: userProvider.users.length,
          itemBuilder: (ctx, i) {
            final user = userProvider.users[i];
            final isCurrentUser = authProvider.user?.id == user.id;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: user.role == 'admin' ? Colors.blue.shade100 : Colors.grey.shade100,
                  child: Icon(
                    user.role == 'admin' ? Icons.shield_rounded : Icons.person_rounded,
                    color: user.role == 'admin' ? Colors.blue.shade700 : Colors.grey.shade700,
                  ),
                ),
                title: Text(
                  user.username,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Role: ${user.role == 'admin' ? 'Administrator' : 'Regular User'}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                trailing: isCurrentUser
                    ? Tooltip(
                  message: 'You cannot delete your own admin account.',
                  child: Icon(Icons.account_circle_rounded, color: Colors.blueAccent[400], size: 28),
                )
                    : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete user "${user.username}"? This action cannot be undone.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      try {
                        await Provider.of<UserProvider>(context, listen: false).deleteUser(user.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User deleted successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete user: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  tooltip: 'Delete User',
                  visualDensity: VisualDensity.compact,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}