// ignore_for_file: deprecated_member_use, prefer_typing_uninitialized_variables

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:flutter_application_4/common/fetch_http_news.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreenRSS extends StatefulWidget {
  @override
  _HomeScreenRSSState createState() => _HomeScreenRSSState();
}

class _HomeScreenRSSState extends State {
  bool _darkTheme = false;
  List _NewsList = [];
  late String _title;
  static const String loadingFeedMsg = 'Loading Feed...';
  static const String feedLoadErrorMsg = 'Error Loading Feed.';
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: !_darkTheme ? ThemeData.light() : ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('SNEWS'),
          actions: [
            Icon(_getAppBarIcon()),
            Switch(
                value: _darkTheme,
                onChanged: (bool value) {
                  setState(() {
                    _darkTheme = !_darkTheme;
                  });
                })
          ],
        ),
        body: FutureBuilder(
          future: _getHttpNews(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                child: ListView.builder(
                    padding: EdgeInsets.only(
                        left: 10.0, top: 10.0, right: 10.0, bottom: 20.0),
                    scrollDirection: Axis.vertical,
                    itemCount: _NewsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Column(children: [
                            Text(
                              '${_NewsList[index].title}',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              '${parseDescription(_NewsList[index].description)}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd – kk:mm').format(
                                    DateTime.parse(
                                        '${_NewsList[index].pubDate}'),
                                  ),
                                ),
                                FloatingActionButton.extended(
                                  heroTag: null,
                                  onPressed: () => openFeed(_NewsList[index].link)
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ReadScreen(
                                  //               urlNews:
                                  //                   '${_NewsList[index].link}',
                                  //             )))
                                  ,
                                  label: Text('Читать'),
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      );
                    }),
              );
            }
          },
        ),
      ),
    );
  }

  _getAppBarIcon() {
    if (_darkTheme) {
      return Icons.brightness_3;
    } else {
      return Icons.brightness_7;
    }
  }

  _getHttpNews() async {
    var response =
        await fetchHttpNews(Uri.parse('https://news.mail.ru/rss/main/91/'));
    var chanel = RssFeed.parse(response.body);
    chanel.items!.forEach((element) {
      _NewsList.add(element);
    });
    return _NewsList;
  }

  

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
        enableJavaScript:true
      );
      return;
    }
    updateTitle(feedOpenErrorMsg);
  }
}
