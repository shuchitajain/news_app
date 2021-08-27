import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsapp/secrets.dart';
import '../models/newsitem.dart';
import '../constants.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsWidget extends StatefulWidget {
  late final bool loading;

  @override
  _NewsWidgetState createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  bool loading = true;
  Map news = {};

  Future<void> launchURL(String url) async {
    if (!url.contains('http')) url = 'https://$url';
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Map> getNews() async {
    ///CUSTOM URL HERE
    String url = ApiKey.newsUrl;
    http.Response res = await http.get(Uri.parse(url));
    return jsonDecode(res.body);
  }

  Future<List<NewsItem>> get() async {
    List<NewsItem> newsItem = [];
    news = await getNews();
    for (var element in news["articles"]) {
      if (element["urlToImage"] != null &&
          element["description"] != '' &&
          element["url"] != null) {
        newsItem.add(
          NewsItem(
            element["title"] ?? '',
            element["author"] ?? '',
            element["description"],
            element["urlToImage"],
            DateTime.parse(element["publishedAt"] ?? ''),
            element["url"],
          ),
        );
      }
    }
    return newsItem;
  }

  @override
  void initState() {
    super.initState();
    get();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context)
        .textTheme
        .apply(bodyColor: black, displayColor: grey);

    Widget customCard(
        {required AsyncSnapshot<List<NewsItem>> snapshot, required int index}) {
      return Container(
        height: 550,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: white,
            border: Border.all(color: grey)),
        child: Column(
          children: <Widget>[
            Container(
              height: 330,
              width: double.infinity,
              margin: EdgeInsets.only(top: 8),
              child: GFAvatar(
                shape: GFAvatarShape.standard,
                size: 45,
                backgroundImage: NetworkImage(snapshot.data![index].urlToImage),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 2),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 25,
                    ),
                    Text(snapshot.data![index].title,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headline6!.copyWith(fontSize: 18)),
                    SizedBox(
                      height: 13,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(snapshot.data![index].description,
                            style: textTheme.subtitle2!.copyWith(
                                fontSize: 15, color: Colors.grey[700])),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            print('Launch');
                            launchURL(snapshot.data![index].url);
                          },
                          child: Text(
                            'Go to website',
                            style: TextStyle(
                              color: blue,
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.solidClock,
                                size: 13,
                                color: grey,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                  DateFormat.Hm().format(
                                      snapshot.data![index].publishedAt),
                                  style: textTheme.caption!
                                      .copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return loading
        ? Center(child: Text('Loading...'))
        : FutureBuilder<List<NewsItem>>(
      future: get(),
      builder:
          (BuildContext context, AsyncSnapshot<List<NewsItem>> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return Container(
          height: snapshot.data!.length * 30.0,
          width: double.infinity,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return customCard(snapshot: snapshot, index: index);
              }),
        );
      },
    );
  }
}