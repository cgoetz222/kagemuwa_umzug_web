import 'package:flutter/material.dart';
import 'package:kagemuwa_umzug_common/helper/kagemuwa_styles.dart';

class CardMenuItemWidget extends StatefulWidget {
  final double size;
  final Color color;
  final String description;
  final IconData iconData;

  const CardMenuItemWidget({
    super.key, required this.size, required this.description, required this.iconData, required this.color,
  });

  @override
  State<CardMenuItemWidget> createState() => _CardMenuItemWidgetState();
  //_CardMenuItemWidgetState createState() => _CardMenuItemWidgetState();
}

class _CardMenuItemWidgetState extends State<CardMenuItemWidget> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Card(
        margin: const EdgeInsets.all(20),
        shape:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: widget.color,
        child: Column(
          children: <Widget> [
            Container(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: widget.size / 4.0,
//                backgroundColor: Colors.white.withOpacity(0.4),
                backgroundColor: Colors.white.withValues(),
                child: Icon(widget.iconData, size: widget.size / 2.5, color: Colors.black45,),
              ),
            ),
            SizedBox(height: widget.size / 15.0),
            Text(widget.description, textAlign: TextAlign.center, style: KAGEMUWAStyles.menuCardStyle, textScaler: TextScaler.linear(widget.size / 250.0),),
          ],
        ),
      ),
    );
  }
}