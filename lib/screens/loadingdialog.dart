import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingAlertDialog extends StatelessWidget {
  final String message;
  const LoadingAlertDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 12.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(message),
        ],
      ),
    );
  }
}
