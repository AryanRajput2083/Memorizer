import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Memorize'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  bool isLoading = true;
  List<Map> lst = [];
  late Database dbb;

  Widget item(Map mp){
    return Card(
      child: InkWell(
        onTap: (){
          next(mp);
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              width: double.infinity,
              child: Text(mp["title"],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              width: double.infinity,
              child: Text(
                mp["time"],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black12,
                ),
              ),
            )
          ],
        )
      ),
    );
  }
  Widget body(){
    if(isLoading){
      return Center(
        child: Text("Memorize easily",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      );
    }
    else{
      return ListView.builder(
        itemCount: lst.length,
        itemBuilder: (BuildContext context, int i){
          return item(lst[i]);
        },
      );
    }
  }

  Future<void> next(Map mp) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NextPage(map:mp,db:dbb))).then((value){
          getList(dbb);
    });
  }
  void ssd(String ss){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(ss),
        );
      },
    );
  }
  Future<void> getList(Database db) async {
    await db.query("data",orderBy: "id DESC").then((value){
      setState(() {
        lst = value;
        isLoading = false;
      });
    });
  }
  Future<void> getDatabase() async {

    var databasesPath = await getDatabasesPath();
    String path = databasesPath+'/demo.db';

    dbb = await openDatabase(path,version: 1,

      onCreate: (Database db, int version) async {
        await db.execute("create table data(id INTEGER UNIQUE, title VARCHAR, body TEXT, time VARCHAR(30) );").then((value){
          setState(() {
            isLoading = false;
          });
        }).catchError((e){
          ssd(e.toString());
        });
        dbb = db;
      },

      onOpen: (Database db) async {
        dbb = db;
        getList(db);
      }
    );
  }

  @override
  void initState() {
    getDatabase();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Center(
        child: Text("Memorise easily"),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: body(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Map m = {
            "time":"",
            "id"  : 0,
            "title" : "",
            "body"  : ""
          };
          next(m);
        },
        tooltip: 'New',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NextPage extends StatefulWidget{
  const NextPage({super.key, required this.map,required this.db});
  final Map map;
  final Database db;

  @override
  State<NextPage> createState() => _NextState();
}
class _NextState extends State<NextPage> {

  late Database db;
  Map<String,dynamic> mp = {};
  TextEditingController tit = new TextEditingController();
  TextEditingController bod = new TextEditingController();

  Widget body(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: TextField(
            controller: tit,
            decoration: InputDecoration(
                hintText: "Title",
                
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child: TextFormField(
            controller: bod,
            minLines: 1,
            maxLines: 100,
            decoration: InputDecoration(
              hintText: "Enter here"
            ),
          ),
        ),
      ],
    );
  }

  Future<void> save() async {
    mp["title"] = tit.text;
    mp["body"]  = bod.text;
    if(mp["id"]==0)
      mp["id"]    = DateTime.now().millisecondsSinceEpoch;
    mp["time"]  = DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now());
    await db.delete("data",where: "id = ?", whereArgs: [mp["id"]]).whenComplete(() async {
      await db.insert("data", mp).then((value){
        const snkb = SnackBar(content: Text("saved"));
        ScaffoldMessenger.of(context).showSnackBar(snkb);
      });
    });
  }

  @override
  void initState() {
    db = widget.db;
    widget.map.forEach((key, value) { 
      mp[key.toString()] = value;
    });
    tit.text = mp["title"].toString();
    bod.text = mp["body"].toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item"),
      ),

      body: body(),

      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.save,
        ),
        onPressed: (){
          save();
        },
      ),
    );
  }


}