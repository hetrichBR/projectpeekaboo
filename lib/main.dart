import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:projectpeekaboo/widgets/onboarding_screen.dart';
import 'package:tflite/tflite.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        accentColor: Colors.indigoAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Project Peekaboo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum InputType{
    gallery,
    camera
}
bool moreDetails = false;

class _MyHomePageState extends State<MyHomePage> {
  File _storedImage;
  bool isLoading = true;
  List output;
  String imageResult = "";
  double benignPercentage = 0.0;
  double malignantPercentage = 0.0;
  InputType imageSource;
  TapGestureRecognizer _pressGestureRecognizer;

  @override
  void initState(){
     super.initState();
     _pressGestureRecognizer = TapGestureRecognizer()
       ..onTap = openACSSite;
     loadModel().then((value){
       setState(() {
         isLoading = false;
       });
     });
  }

  void openACSSite(){
      launch('https://www.cancer.org/cancer/melanoma-skin-cancer/detection-diagnosis-staging/signs-and-symptoms.html');
  }

  loadModel() async{
    await Tflite.loadModel(model: "assets/model/model_unquant.tflite", labels: "assets/model/labels.txt");
  }

  Future<void> _getImage(InputType inputType) async {
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(source: inputType == InputType.camera ? ImageSource.camera : ImageSource.gallery );
    setState(() {
      imageSource = inputType;
      _storedImage = File(imageFile.path);
      isLoading = true;
    });
    analyzeImage();
  }

  analyzeImage() async
  {
    //mean:  stdDev: threshold: value above threshold indicates must be this sure to label image
    var result = await Tflite.runModelOnImage(path: _storedImage.path, numResults: 2, imageMean: 127.5, imageStd: 127.5, threshold: .5, asynch: true);
    print(result);
    setState(() {
      isLoading = false;
      output = result;
    });
    if(output[0]["index"] == 0)
    {
       imageResult = "Benign";
       benignPercentage = output[0]["confidence"];
       malignantPercentage = 1 - output[0]["confidence"];
       if(malignantPercentage < .001)
         malignantPercentage = 0.0;
    }
    else{
       imageResult = "Malignant";
       malignantPercentage = output[0]["confidence"];
       benignPercentage = 1 - output[0]["confidence"];
       if(benignPercentage < .001)
         benignPercentage = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
   var mediaQuery = MediaQuery.of(context);
   return OnBoardingWidget();
   /* return Scaffold(
      appBar: AppBar(   
        title: Text(widget.title),
        actions: <Widget>[IconButton(icon:Icon(Icons.info_outline),onPressed: (){},)],
      ),
      body: Container(  
        color: Colors.indigo.shade50,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5),
        child: isLoading == true ? CircularProgressIndicator(): Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(child: Container( padding: EdgeInsets.all(5), height: MediaQuery.of(context).size.height *.06, child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Icon(Icons.info, color: Theme.of(context).accentColor), SizedBox(width: 5,), !moreDetails ? Text('Follow the guidelines to get accurate results.') : RichText(text: TextSpan(text: 'For more info on diagnosis visit ', style: TextStyle(color: Colors.black, fontFamily: 'Roboto'), children: <TextSpan>[TextSpan(text: 'The ACS Website', style: TextStyle(color: Colors.purpleAccent, fontFamily: 'Roboto'), recognizer: _pressGestureRecognizer)]))]))),
            if(moreDetails == false)Card(
              elevation: 5,
                color: Colors.white,
                child: Container(width: mediaQuery.size.width, height: mediaQuery.size.height *.4, decoration: BoxDecoration(border: Border.all(width: 0, color: Theme.of(context).primaryColor), borderRadius: BorderRadius.all(Radius.circular(5))),
                child: _storedImage != null 
                ? Image.file(_storedImage, fit: imageSource == InputType.gallery ?  BoxFit.cover : BoxFit.cover, width: double.infinity,)
                : Center(child: IconButton(icon: Icon(Icons.camera_alt, color: Colors.blueGrey, size: 40,), onPressed: () => {_getImage(InputType.camera)},))  
                ),
            ),
              //Text(_storedImage == null ? 'Result' : "${this.imageResult}"), 
              _storedImage != null 
              ? Card(
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.only(top: 5),
                    height: moreDetails ? mediaQuery.size.height *.33: mediaQuery.size.height *.36,
                    child: Column(children: <Widget>[
                      Text('Results', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor),),
                      SizedBox(height: mediaQuery.size.height *.012,),
                       Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                              new CircularPercentIndicator(
                              radius: 130.0,
                              lineWidth: 13.0,
                              animation: true,
                              percent: benignPercentage,
                              center: new Text(
                                "${(benignPercentage * 100).toStringAsFixed(1)}%",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, fontFamily: 'Roboto'),
                              ),
                              footer: new Text(
                                "Benign",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0, fontFamily: 'Roboto'),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: benignPercentage > .9 ? Colors.green : Theme.of(context).primaryColor,
                            ),
                              new CircularPercentIndicator(
                              radius: 130.0,
                              lineWidth: 13.0,
                              animation: true,
                              percent: malignantPercentage,
                              center: new Text(
                                "${(malignantPercentage * 100).toStringAsFixed(1)}%",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0, fontFamily: 'Roboto'),
                              ),
                              footer: new Text(
                                "Malignant",
                                style:
                                    new TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0, fontFamily: 'Roboto'),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: malignantPercentage > .9 ? Colors.red: Theme.of(context).accentColor,
                          )
                          ],
                       ),
                       SizedBox(height: mediaQuery.size.height *.015,),
                     _storedImage != null ? Container(height: 20, child: FlatButton( onPressed: (){setState(() {moreDetails = !moreDetails;});}, child: !moreDetails ? Text('More Details') : Text('Less Details'), textColor: Colors.indigoAccent,)) : Container(),
                    ],),
                  ),
              ) 
              : Container(),
             if(moreDetails)Card(child: Container( padding: EdgeInsets.only(top: 5), width: mediaQuery.size.width, height: mediaQuery.size.height * .4, child: Column(children: <Widget>[
             Text('Signs of Melanoma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor),),
             SizedBox(height: 12),
             Container(padding: EdgeInsets.only(left: 10), child: Row(children: <Widget>[RichText(text: TextSpan(text: 'A', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.w500), children: <TextSpan>[TextSpan(text: 'symmetry', style: TextStyle(fontSize: 20)), TextSpan(text: ' Halves of mole do not match.', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: 'Roboto'))]))],),),
             SizedBox(height: 12),
             Container(padding: EdgeInsets.only(left: 10), child: Row(children: <Widget>[RichText(text: TextSpan(text: 'B', style: TextStyle(fontSize: 30, color: Colors.orange, fontWeight: FontWeight.w500), children: <TextSpan>[TextSpan(text: 'order', style: TextStyle(fontSize: 20)),TextSpan(text: ' Edges are notched or blurred.', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: 'Roboto'))]))],),),
             SizedBox(height: 12),
             Container(padding: EdgeInsets.only(left: 10), child: Row(children: <Widget>[RichText(text: TextSpan(text: 'C', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.w500), children: <TextSpan>[TextSpan(text: 'olor', style: TextStyle(fontSize: 20)), TextSpan(text: ' Color is not the same all over.', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: 'Roboto'))]))],),),
             SizedBox(height: 12),
             Container(padding: EdgeInsets.only(left: 10), child: Row(children: <Widget>[RichText(text: TextSpan(text: 'D', style: TextStyle(fontSize: 30, color: Colors.orange, fontWeight: FontWeight.w500), children: <TextSpan>[TextSpan(text: 'iameter', style: TextStyle(fontSize: 20)), TextSpan(text: ' Spot is larger thab 1/4in (6mm).', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: 'Roboto'))])),],),),
             SizedBox(height: 12),
             Container(padding: EdgeInsets.only(left: 10), child: Row(children: <Widget>[RichText(text: TextSpan(text: 'E', style: TextStyle(fontSize: 30, color: Colors.red,fontWeight: FontWeight.w500), children: <TextSpan>[TextSpan(text: 'volving', style: TextStyle(fontSize: 20)), TextSpan(text: ' Mole changes size, shape or color.', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: 'Roboto'))]))],),),
             SizedBox(height: 20),
             Container( padding: EdgeInsets.only(left: 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children:<Widget>[Icon(Icons.info_outline, color: Colors.amber,size: 16,), SizedBox(width: 5,), Text('Not all Melanomas fit this criteria', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),)]))

              
             ],),),)
            ],)
      ),
       floatingActionButton: SpeedDial(
          // both default to 16
          marginRight: 18,
          visible: !moreDetails,
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          // this is ignored if animatedIcon is non null
          // child: Icon(Icons.add),
         // visible: _dialVisible,
          // If true user is forced to close dial manually 
          // by tapping main button and overlay is not rendered.
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          tooltip: 'Speed Dial',
          heroTag: 'speed-dial-hero-tag',
          backgroundColor: Theme.of(context).accentColor,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera_alt),
              backgroundColor: Theme.of(context).accentColor,
              label: 'Camera',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _getImage(InputType.camera)
            ),
            SpeedDialChild(
              child: Icon(Icons.image),
              backgroundColor: Theme.of(context).accentColor,
              label: 'Gallery',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _getImage(InputType.gallery)
            ),
          ],
        ),
    );
  */
  }

  @override void dispose(){
    super.dispose();
    Tflite.close();
    _pressGestureRecognizer.dispose();

  }
}
