import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class OnBoardingWidget extends StatefulWidget {
  @override
  _OnBoardingWidgetState createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
final int numPages = 3;
final _pageController = PageController(initialPage:  0);
int currentPage = 0;

List<Widget> buildPageIndicator(){
  List<Widget> list = [];
  for(int i = 0; i < numPages; i++){
    list.add(i == currentPage ? indicator(true) : indicator(false));
  }
  return list;
}

Widget indicator(bool isActive){
   return AnimatedContainer(
     duration: Duration(milliseconds: 150),
     margin: EdgeInsets.symmetric(horizontal: 8.0),
     height: 8,
     width: isActive ? 24.0 : 16.0,
     decoration: BoxDecoration(
       color: isActive ? Colors.white : Color(0xFF7B51D3),
       borderRadius: BorderRadius.all(Radius.circular(12))
     ),
     
     );
}

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
          child: Container(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops:[0.1, 0.4, 0.7, 0.9],
            colors: [
              Colors.indigo.shade300,
              Colors.indigo.shade500,
              Colors.indigo.shade600,
              Colors.indigo.shade700
            ]
          )
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[ 
            Container(alignment: Alignment.centerRight, child: FlatButton(onPressed: ()=>print('Hello'), child: Text('Skip',style: TextStyle(color: Colors.white, fontSize: 20.0),)),),
            Container(height: 600, child: 
              PageView(physics: ClampingScrollPhysics(), controller: _pageController, onPageChanged: (int page){
              setState(() {
               currentPage = page;
            });
           },
           children: <Widget>[
             Padding(
               padding: const EdgeInsets.all(40.0),
               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                   Center(child: Container(color: Colors.amber, height: mediaQuery.size.height *.4, width: mediaQuery.size.width *.6,),),
                   SizedBox(height: 30),
                   Center(child: Text("Slide 1 Title here!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),)),
                  SizedBox(height: 15),
                   Center(child: Text("Slide 1 text will be displayed here!", style: TextStyle(color: Colors.white, fontSize: 18,),))
               ],),
             ),
             Padding(
               padding: const EdgeInsets.all(40.0),
               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                   Center(child: Container(color: Colors.deepOrange, height: mediaQuery.size.height *.4, width: mediaQuery.size.width *.6,),),
                   SizedBox(height: 30),
                   Center(child: Text("Slide 2 Title here!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,  fontSize: 20),)),
                  SizedBox(height: 15),
                   Center(child: Text("Slide 2 text will be displayed here!", style: TextStyle(color: Colors.white,  fontSize: 18),))
               ],),
             ),
             Padding(
               padding: const EdgeInsets.all(40.0),
               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                   Center(child: Container(color: Colors.greenAccent, height: 300, width: 300,),),
                   SizedBox(height: 30),
                   Center(child: Text("Slide 3 Title here!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,  fontSize: 20),)),
                  SizedBox(height: 15),
                   Center(child: Text("Slide 3 text will be displayed here!", style: TextStyle(color: Colors.white,  fontSize: 18),))
               ],),
             )
           ],
           ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: buildPageIndicator()),
          currentPage != numPages -1 ?
            Expanded(child: Align(alignment: Alignment.bottomRight, child: FlatButton(onPressed: () => _pageController.nextPage(duration: Duration(milliseconds:  500), curve: Curves.ease), child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Next", style: TextStyle(color: Colors.white, fontSize: 22.0),),
                SizedBox(height: 10.0),
                Icon(Icons.arrow_forward ,color: Colors.white, size: 30.0)
              ],
            ),),))
            :Expanded(child: Align(alignment: Alignment.bottomRight, child: FlatButton(onPressed: () => print('Finish'), child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Finish", style: TextStyle(color: Colors.white, fontSize: 22.0),),
                SizedBox(height: 10.0),
                Icon(Icons.check ,color: Colors.white, size: 30.0)
              ],
            ),),))
         ]),
        ),
        ),
      ),
      bottomSheet: currentPage == numPages - 1 ?
        Container(height: 100, width: double.infinity,
        color: Colors.white,
        child: GestureDetector(
          onTap: () => print(''),
            child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Text("Get Started", style: TextStyle(color: Colors.indigo,fontSize: 20, fontWeight: FontWeight.w600),),
            ),
          ),
        ),        
        ) : Container()
    );
  }
}