class Articole {

  DateTime createdAt=DateTime(0,0,0,0,0,0);
  String title="";
  String url="";
  String author="";
  String points="";
  String storyText="";
  String numComments="";
  String objectId="";
  bool favorite=false;


  Articole(DateTime createdAt,String title,String url,String author,String points,String storyText,String numComments,String objectId){
    this.createdAt=createdAt;
    this.title=title;
    this.url=url;
    this.author=author;
    this.points=points;
    this.storyText=storyText;
    this.numComments=numComments;
    this.objectId=objectId;
  }

  setFavorite(bool favorite){
    this.favorite=favorite;
  }

  Articole.fromJson(Map<String,dynamic> json):
        createdAt=DateTime.parse(json['createdAt']),
        title=json['title'],
        url=json['url'],
        author=json['author'],
        points=json['points'],
        storyText=json['storyText'],
        numComments=json['numComments'],
        objectId=json['objectId'],
        favorite=json['favorite'];


  Map<String,dynamic> toJson()=>{
    'createdAt': createdAt== null? null :createdAt.toIso8601String(),
    'title': title,
    'url': url,
    'author': author,
    'points': points,
    'storyText': storyText,
    'numComments': numComments,
    'objectId':objectId,
    'favorite': favorite
  };


}