import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/comment_provider.dart';
import 'package:event_app/providers/auth_provider.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventAndComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchEventAndComments() async {
    if (!mounted) return;

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    try {
      await eventProvider.fetchEvents();
      if (mounted) {
        await commentProvider.fetchCommentsForEvent(widget.eventId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event or comments: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty!')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment.')),
      );
      return;
    }

    try {
      await Provider.of<CommentProvider>(context, listen: false).createComment(
        _commentController.text,
        widget.eventId,
        authProvider.user!.id,
      );
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added!')),
      );
      if (mounted) {
        await Provider.of<CommentProvider>(context, listen: false).fetchCommentsForEvent(widget.eventId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this comment?'),
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
        await Provider.of<CommentProvider>(context, listen: false).deleteComment(commentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully!')),
        );
        if (mounted) {
          await Provider.of<CommentProvider>(context, listen: false).fetchCommentsForEvent(widget.eventId);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final event = eventProvider.events.firstWhereOrNull((e) => e.id == widget.eventId);

    if (eventProvider.isLoading && event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Event Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Event Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.go('/events');
            },
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(24.0),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Event not found or an error occurred.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/events');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 25.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event!.title,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Date: ${DateFormat.yMMMd().add_jm().format(event.date)}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5),
                    ),
                    if (event.creator != null && event.creator!.username != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          'Created by: ${event.creator?.username ?? 'Unknown User'}',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Divider(height: 40, thickness: 1.5),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 15),

            if (commentProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (commentProvider.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading comments: ${commentProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              )
            else if (commentProvider.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('No comments yet. Be the first to comment!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentProvider.comments.length,
              itemBuilder: (ctx, i) {
                final comment = commentProvider.comments[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                              child: Text(
                                comment.author?.username != null && comment.author!.username.isNotEmpty
                                    ? comment.author!.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.author?.username ?? 'Unknown User',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    comment.createdAt != null
                                        ? DateFormat.yMMMd().add_jm().format(comment.createdAt!)
                                        : 'Unknown Date',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if ((authProvider.isAuthenticated && authProvider.user?.id == comment.authorId) || authProvider.isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                                onPressed: () => _deleteComment(comment.id),
                                tooltip: 'Delete Comment',
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          comment.content,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            if (authProvider.isAuthenticated)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(top: 0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Comment',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Your Comment',
                          hintText: 'Type your comment here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
                            onPressed: _submitComment,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                      if (commentProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),

            if (!authProvider.isAuthenticated)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Login to add comments to this event.',
                          style: TextStyle(color: Colors.grey[800], fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension ListEventExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}