import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';

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
        child: Column(
          spacing: 20,
          children: [
            Welcome(),
            Posts(),
          ],
        ),
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

class Posts extends HookWidget {
  const Posts({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = useQuery(["posts"], getPosts);

    if (posts.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (posts.isError) {
      return Center(child: Text("Bir hata oluştu: ${posts.error}"));
    }

    if (posts.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Durum güncellemeleri bulunamadı"),
              IconButton(
                onPressed: () {
                  posts.refetch();
                },
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      );
    }

    final postsData = posts.data!;

    logger.i("postsData: $postsData");

    return RefreshIndicator(
      onRefresh: () => posts.refetch(),
      child: Column(
        children: [
          Text(
            "Gönderiler",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: postsData.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postsData[index].title),
                      Text(postsData[index].body),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
