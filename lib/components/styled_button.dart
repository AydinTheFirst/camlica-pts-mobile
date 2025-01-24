import 'package:flutter/material.dart';

enum Variants { primary, secondary, success, danger, warning, info }

enum Shapes { rounded, circle, none }

class StyledButton extends StatelessWidget {
  StyledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = Variants.primary,
    this.shape = Shapes.rounded,
    this.isDisabled = false,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final void Function() onPressed;
  final Widget child;
  final Variants variant;
  final Shapes shape;

  final bool isDisabled;
  final bool isLoading;
  final bool fullWidth;

  final Map<Variants, Color> colors = {
    Variants.primary: Colors.blueAccent,
    Variants.secondary: Colors.grey,
    Variants.success: Colors.green,
    Variants.danger: Colors.red,
    Variants.warning: Colors.orange,
    Variants.info: Colors.blue,
  };

  final Map<Variants, Color> textColor = {
    Variants.primary: Colors.white,
    Variants.secondary: Colors.black,
    Variants.success: Colors.white,
    Variants.danger: Colors.white,
    Variants.warning: Colors.black,
    Variants.info: Colors.white,
  };

  final Map<Shapes, double> borderRadius = {
    Shapes.rounded: 8,
    Shapes.circle: 100,
    Shapes.none: 0,
  };

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled
          ? null
          : () {
              if (isLoading) return;
              onPressed();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : colors[variant],
        foregroundColor: isDisabled ? Colors.black : textColor[variant],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius[shape]!),
        ),
        minimumSize: Size(fullWidth ? double.infinity : 120, 40),
        maximumSize: Size(double.infinity, 40),
      ),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          : child,
    );
  }
}
