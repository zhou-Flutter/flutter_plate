import 'package:flutter/material.dart';

class ProgressButton extends StatelessWidget {
  double progress;
  double height;
  double width;
  double borderRadius;
  String text;
  TextStyle textStyle;
  Color bottomColor;
  Color topColor;
  Function()? onTap;

  ProgressButton({
    required this.height,
    required this.progress,
    required this.width,
    this.borderRadius = 10,
    this.text = "",
    this.textStyle = const TextStyle(color: Colors.blue),
    this.bottomColor = Colors.black12,
    this.topColor = Colors.blue,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: bottomColor,
              ),
              child: Center(
                child: Text(
                  text,
                  style: textStyle,
                ),
              ),
            ),
            Positioned(
              child: ClipPath(
                clipper: TrianglePath(progress: progress),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: topColor,
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: textStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TrianglePath extends CustomClipper<Path> {
  double progress;

  TrianglePath({
    this.progress = 0,
  });

  @override
  Path getClip(Size size) {
    var x = size.width * (progress * 0.01);
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(x, 0);
    path.lineTo(x, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
