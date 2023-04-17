import 'package:flutter/material.dart';
import 'package:news_app/page/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:news_app/articole_data/articol.dart';

class Preferences extends StatefulWidget {
 final List<Articole> saved;

  @override
  State<Preferences> createState() => _Preferences();
  Preferences({
    Key? key,
    required List<Articole> this.saved,
}): super(key: key);
}

class _Preferences extends State<Preferences> {

  HomePage method=HomePage();


  @override
  void initState() {
    print(widget.saved.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.saved.isEmpty == true
          ? const Center(child: Text('Is empty'))
          : ListView.builder(
          itemCount: widget.saved.length,
          itemBuilder: (context, index) {
            final salvat = widget.saved[index].favorite;
            // getSaveInfo(index);
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: TextButton(
                        onPressed: () async {
                          final url = widget.saved[index].url;
                          if (await canLaunch(url)) {
                            await launch(url);
                            //   final Uri _url = Uri.parse(articole[i].url);
                            //   if (!await launchUrl(_url)) {
                            // throw 'Could not launch $_url';}
                          }
                        },
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(widget.saved[index].title))),
                    subtitle: Text(
                        "Author: ${widget.saved[index].author}     ${widget.saved[index]
                            .createdAt.day}.${widget.saved[index].createdAt
                            .month}.${widget.saved[index].createdAt.year}"),
                    trailing: Icon(
                      Icons.close,
                      color: salvat ? Colors.redAccent : null,
                      semanticLabel: salvat ? 'Remove from saved' : 'Save',
                    ),
                    onTap: () {
                      setState(() {
                        print(widget.saved[index].toString());
                        widget.saved[index].favorite = false;
                        method.saveData(widget.saved[index].objectId, widget.saved[index]
                            .favorite);
                        // saveInfo(index);
                        widget.saved.removeAt(index);
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                          "Number of comms: ${widget.saved[index]
                              .numComments}    Points: ${widget.saved[index].points}")
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}