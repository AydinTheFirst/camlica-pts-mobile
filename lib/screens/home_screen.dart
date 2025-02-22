import 'dart:async';

import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Posts(),
    );
  }
}

class Posts extends ConsumerWidget {
  const Posts({super.key});

  void showPost(Post post) {
    // show dialog
    Get.dialog(
      AlertDialog(
        title: Text(post.title),
        content: Text(post.body),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Kapat"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return posts.when(
      error: (error, stack) => Text('Error: $error'),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      data: (posts) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(postsProvider);
            return Future.value();
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: Icon(Icons.message),
                title: Text(post.title),
                subtitle: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(posts[index].body),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(formatFullDate(post.createdAt)),
                      ],
                    ),
                  ],
                ),
                onTap: () => showPost(posts[index]),
              );
            },
          ),
        );
      },
    );
  }
}
