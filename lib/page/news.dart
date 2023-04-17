import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news_app/method/filter_function.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../articole_data/articol.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class News extends StatefulWidget {

  @override
  State<News> createState() => _News();
  const News({
    Key? key,
    required this.saved,
  }): super(key: key);

   final List<Articole> saved;
}

class _News extends State<News> {
  String stringResponse = '0';
  Map mapResponse = {};
  List<Articole> articole = [];
  List<Articole> filtred = [];
  HomePage method= HomePage();

  late bool initial;

  Future apiCall() async {
    http.Response response;
    response = await http
        .get(Uri.parse('https://hn.algolia.com/api/v1/search?tags=front_page'));

    if (response.statusCode == 200) {
      setState(() {
        mapResponse = json.decode(response.body);
        for (int i = 0; i < mapResponse['hits'].length; i++) {
          articole.add(
            Articole(
                DateTime.parse(mapResponse['hits'][i]['created_at']),
                mapResponse['hits'][i]['title'].toString(),
                mapResponse['hits'][i]['url'].toString(),
                mapResponse['hits'][i]['author'].toString(),
                mapResponse['hits'][i]['points'].toString(),
                mapResponse['hits'][i]['storyText'].toString(),
                mapResponse['hits'][i]['num_comments'].toString(),
                mapResponse['hits'][i]['objectID'].toString()),
          );
        }
        filtred = List.from(articole);
      });

      getSaveData();
      // getSaveInfo();
    }
  }

  void getSaveData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < articole.length; i++) {
        articole[i].favorite = (preferences.containsKey(articole[i].objectId)
            ? preferences.getBool(articole[i].objectId)
            : false)!;
      }
    });
  }

  void isSaved(bool salvat, int i) {
    if (salvat) {
      setState(() {
        widget.saved.remove(filtred[i]);
        filtred[i].favorite = false;
      });
      method.saveData(filtred[i].objectId, filtred[i].favorite);
    } else {
      setState(() {
        filtred[i].favorite = true;
        widget.saved.add(filtred[i]);
      });
      method.saveData(filtred[i].objectId, filtred[i].favorite);
      // // saveInfo(_saved.indexOf(filtred[i]));
      // print(widget.saved.indexOf(filtred[i]));
    }
  }

  @override
  void initState() {
    apiCall();
    getSaveData();
    // filtred=List.from(articole);
    super.initState();
  }



  Widget searchBar() {
    return SizedBox(
        height: 40,
        width: 310,
        child: TextField(
          decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search)),
          onChanged: (string) {
            setState(() {
              filtred = articole
                  .where((element) => (element.title
                      .toLowerCase()
                      .contains(string.toLowerCase())))
                  .toList();
            });
          },
        ));
  }

  Widget launchSiteButton(int i) {
    return TextButton(
        onPressed: () async {
          final url = filtred[i].url;

          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          }
        },
        child:
            Align(alignment: Alignment.topLeft, child: Text(filtred[i].title)));
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(4.0)),
          Row(children: <Widget>[
           searchBar(),
            IconButton(
              onPressed: sort,
              icon: const Icon(Icons.sort),
              tooltip: "Sort the news",
            )
          ]),

          const SizedBox(
            height: 5.0,
          ),
          Expanded(
            child: mapResponse.isEmpty == false
                ? ListView.builder(
                itemCount: filtred.length,
                itemBuilder: (context, i) {
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          title: launchSiteButton(i),
                          subtitle: Text(
                              "Author: ${filtred[i].author}     "
                                  "${filtred[i].createdAt.day}."
                                  "${filtred[i].createdAt.month}."
                                  "${filtred[i].createdAt.year}"),
                          trailing: Icon(
                            filtred[i].favorite
                                ? Icons.star
                                : Icons.star_border,
                            color:
                            filtred[i].favorite ? Colors.amber : null,
                            semanticLabel:
                            filtred[i].favorite ? 'Remove from saved' : 'Save',
                          ),
                          onTap: () {
                           isSaved(filtred[i].favorite,i);
                            //getSaveData(i);
                          },
                        ),
                            Text("Number of comms: ${filtred[i].numComments}    "
                                "Points: ${filtred[i].points}")
                      ],
                    ),
                  );
                })
                : const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  void sort() {
    List sortByPoint = ["The most", "The least"];
    List sortByData = ["Latest", "The oldest"];
    String? selectedPoints;
    String? selectedData;
    DateTime now = DateTime.now();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Sort and Filtre'),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Text(
                      'Filter by publication date:  ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.4)),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: <Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                     ElevatedButton(onPressed: (){
                       setState(() {
                         filtred.clear();
                         filtred = List.from(articole);
                       });
                     }, child: Text("All the news")),
                      const SizedBox(
                        width: 8,
                      ),
                    ElevatedButton(onPressed: (){
                      setState(() {
                        filtred.clear();
                        for (int i = 0; i < articole.length; i++) {
                          if (DateTime(articole[i].createdAt.year,
                              articole[i].createdAt.month, 0)
                              .day +
                              articole[i].createdAt.day ==
                              DateTime(now.year, now.month, 0).day + now.day) {
                            filtred.add(articole[i]);
                          }
                        }
                      });
                    }, child: Text("Today")),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          filtred.clear();
                          for (int i = 0; i < articole.length; i++) {
                            if (((DateTime(now.year, now.month, 0).day + now.day) -
                                (DateTime(articole[i].createdAt.year,
                                    articole[i].createdAt.month, 0)
                                    .day +
                                    articole[i].createdAt.day)) ==
                                1) {
                              filtred.add(articole[i]);
                            }
                          }
                        });
                      }, child: Text("Yesterday"))
                     ,
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          filtred.clear();
                          for (int i = 0; i < articole.length; i++) {
                            if (((DateTime(now.year, now.month, 0).day + now.day) -
                                (DateTime(articole[i].createdAt.year,
                                    articole[i].createdAt.month, 0)
                                    .day +
                                    articole[i].createdAt.day)) ==
                                1) {
                              filtred.add(articole[i]);
                            }
                          }
                        });
                      }, child: Text("Older than 2 days")),
                      SizedBox(
                        width: 8,
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Text(
                      'Filter by the number of points:  ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.4)),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    scrollDirection: Axis.horizontal,
                    child: Expanded(
                      child: Row(children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        FilterButton(articole: articole, filtred: filtred, text: "All the news"),
                        SizedBox(
                          width: 8,
                        ),
                       FilterButton(articole: articole, filtred: filtred, text: "0 - 100"),
                        SizedBox(
                          width: 8,
                        ),
                        FilterButton(articole: articole, filtred: filtred, text: "100 - 250"),
                        SizedBox(
                          width: 8,
                        ),
                       FilterButton(articole: articole, filtred: filtred, text: "250 - 500"),
                        SizedBox(
                          width: 8,
                        ),
                        FilterButton(articole: articole, filtred: filtred, text: "more than 500"),
                        SizedBox(
                          width: 8,
                        )
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                      child: Text(
                        'Sort by publication date:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.4)),
                      ),
                    ),



                    SizedBox(
                      width: 10,
                    ),
                    DropdownButton(
                        value: selectedData,
                        items: sortByData.map((valueItem) {
                          return DropdownMenuItem(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedData = val.toString();
                            if (val.toString().compareTo("Latest") == 0) {
                              filtred.clear();
                              DateTime now = DateTime.now();
                              for (int i = 0; i < articole.length; i++) {
                                if (DateTime(articole[i].createdAt.year,
                                    articole[i].createdAt.month, 0)
                                    .day +
                                    articole[i].createdAt.day ==
                                    DateTime(now.year, now.month, 0).day +
                                        now.day) {
                                  filtred.add(articole[i]);
                                }
                              }
                              for (int i = 0; i < articole.length; i++) {
                                print((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(articole[i].createdAt.year,
                                        articole[i].createdAt.month, 0)
                                        .day +
                                        articole[i].createdAt.day));
                                if (((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(
                                        articole[i].createdAt.year,
                                        articole[i].createdAt.month,
                                        0)
                                        .day +
                                        articole[i].createdAt.day)) ==
                                    1) {
                                  filtred.add(articole[i]);
                                }
                              }
                              for (int i = 0; i < articole.length; i++) {
                                if ((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(
                                        articole[i].createdAt.year,
                                        articole[i].createdAt.month,
                                        0)
                                        .day +
                                        articole[i].createdAt.day) >=
                                    2) {
                                  filtred.add(articole[i]);
                                }
                              }
                            } else {
                              filtred.clear();
                              DateTime now = DateTime.now();
                              for (int i = 0; i < articole.length; i++) {
                                if ((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(
                                        articole[i].createdAt.year,
                                        articole[i].createdAt.month,
                                        0)
                                        .day +
                                        articole[i].createdAt.day) >=
                                    2) {
                                  filtred.add(articole[i]);
                                }
                              }
                              for (int i = 0; i < articole.length; i++) {
                                print((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(articole[i].createdAt.year,
                                        articole[i].createdAt.month, 0)
                                        .day +
                                        articole[i].createdAt.day));
                                if (((DateTime(now.year, now.month, 0).day +
                                    now.day) -
                                    (DateTime(
                                        articole[i].createdAt.year,
                                        articole[i].createdAt.month,
                                        0)
                                        .day +
                                        articole[i].createdAt.day)) ==
                                    1) {
                                  filtred.add(articole[i]);
                                }
                              }
                              for (int i = 0; i < articole.length; i++) {
                                if (DateTime(articole[i].createdAt.year,
                                    articole[i].createdAt.month, 0)
                                    .day +
                                    articole[i].createdAt.day ==
                                    DateTime(now.year, now.month, 0).day +
                                        now.day) {
                                  filtred.add(articole[i]);
                                }
                              }
                            }
                          });
                        })
                  ]),
                  SizedBox(
                    height: 30,
                  ),
                  Row(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                      child: Text(
                        'Sort by points:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.4)),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    DropdownButton(
                        value: selectedPoints,
                        items: sortByPoint.map((valueItem) {
                          return DropdownMenuItem(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPoints = val as String;
                            if (val.toString().compareTo("The most") == 0) {
                              filtred.clear();
                              filtred = List.from(articole);
                            } else {
                              filtred.clear();
                              for (int i = articole.length - 1; i >= 0; i--) {
                                filtred.add(articole[i]);
                              }
                            }
                          });
                        })
                  ]),
                ],
              ));
        },
      ),
    );
  }
}