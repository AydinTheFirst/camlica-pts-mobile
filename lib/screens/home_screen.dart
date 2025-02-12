import 'dart:async';

import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fquery/fquery.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Posts(),
      ),
    );
  }
}

class Welcome extends HookWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = useQuery(["user"], getProfile);

    if (user.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (user.error != null) {
      return Center(
        child: Text("Bir hata oluştu: ${user.error}"),
      );
    }

    if (user.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text("Kullanıcı bilgileri bulunamadı"),
                    SizedBox(height: 10),
                    Text(
                      "Lütfen giriş yapın eğer giriş yaptıysanız sağ taraftaki butona tıklayarak sayfayı yenileyin",
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  user.refetch();
                },
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      );
    }

    final userData = user.data!;

    return RefreshIndicator(
      onRefresh: () => user.refetch(),
      child: Column(
        children: [
          Text(
            "Hoşgeldin ${userData.firstName} ${userData.lastName}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${userData.firstName} ${userData.lastName}"),
                              Text(userData.phone.toString()),
                              Text(userData.email)
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final postsProvider = FutureProvider<dynamic>((ref) async {
  final data = await HttpService.fetcher("/posts");
  return data;
});

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
      data: (data) {
        final posts = data.map((e) => Post.fromJson(e)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(postsProvider);
            return Future.value();
          },
          child: Column(
            children: [
              Text(
                "Bildirimler",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => showPost(posts[index]),
                    child: Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 10,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.notifications),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    Text(
                                      posts[index].title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(posts[index].body),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(formatDate(posts[index].createdAt)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
