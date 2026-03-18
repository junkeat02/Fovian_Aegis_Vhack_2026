import 'package:flutter/material.dart';

class DataContainer extends StatelessWidget{
  final Widget child;
  final Color backgroundColor;
  final double horPadding;
  final double vertPadding;
  final double horMargin;
  final double vertMargin;
  final double borRadius;

  const DataContainer({
    super.key,
    required this.child,
    this.backgroundColor = const Color.fromARGB(255, 59, 59, 191),
    this.horPadding = 10,
    this.vertPadding = 10,
    this.horMargin = 10,
    this.vertMargin = 10,
    this.borRadius = 20,
    });

  @override
  Widget build(BuildContext context){
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vertPadding, horizontal: horPadding),
        margin: EdgeInsets.symmetric(vertical: vertMargin, horizontal: horMargin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borRadius)
        ),
        child: child
        ),
    );
  }
}