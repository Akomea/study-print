import 'package:flutter/material.dart';

class DisabledGradientButton extends StatefulWidget {
  final String buttonText;
  final dynamic onPressed;

  const DisabledGradientButton({Key? key, required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  State<DisabledGradientButton> createState() => _DisabledGradientButton();
}

class _DisabledGradientButton extends State<DisabledGradientButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient:  LinearGradient(
                colors: [
                  Color(0xff0DAB76).withOpacity(0.2),
                  Color(0xff408E91).withOpacity(0.2),

                ]
            )
        ),
        child: Center(
          child: Text(
              widget.buttonText,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto')),
        ),
      ),
    );
  }
}