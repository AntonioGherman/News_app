import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:news_app/articole_data/articol.dart';

class FilterButton extends StatelessWidget {
  FilterButton(
      {Key? key,
      required this.articole,
      required this.filtred,
      required this.text})
      : super(key: key);

  List<Articole> articole;
  List<Articole> filtred;
  final String text;

  void chooseSortFunction(String text) {
    DateTime now = DateTime.now();

    switch (text) {
      case "All the news":
        {
          filtred.clear();
          filtred = List.from(articole);
          break;
        }
      case "Today":
        {
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
          break;
        }
      case "Yesterday":
        {
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
          break;
        }
      case "Older than 2 days":
        {
          filtred.clear();
          for (int i = 0; i < articole.length; i++) {
            if ((DateTime(now.year, now.month, 0).day + now.day) -
                    (DateTime(articole[i].createdAt.year,
                                articole[i].createdAt.month, 0)
                            .day +
                        articole[i].createdAt.day) >=
                2) {
              filtred.add(articole[i]);
            }
          }
          break;
        }
      case "0 - 100":
        {
          filtred.clear();
          for (int i = 0; i < articole.length; i++) {
            if (int.parse(articole[i].points) <= 100) {
              filtred.add(articole[i]);
            }
          }
          break;
        }
      case "100 - 250":
        {
          filtred.clear();
          for (int i = 0; i < articole.length; i++) {
            if (int.parse(articole[i].points) >= 100 &&
                int.parse(articole[i].points) <= 250) {
              filtred.add(articole[i]);
            }
          }
          break;
        }
      case "250 - 500":
        {
          filtred.clear();
          for (int i = 0; i < articole.length; i++) {
            if (int.parse(articole[i].points) >= 250 &&
                int.parse(articole[i].points) <= 500) {
              filtred.add(articole[i]);
            }
          }
          break;
        }
      case "more than 500":
        {
          filtred.clear();
          for (int i = 0; i < articole.length; i++) {
            if (int.parse(articole[i].points) >= 500) {
              filtred.add(articole[i]);
            }
          }
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          chooseSortFunction(text);
        },
        child: Text(text));
  }
}
