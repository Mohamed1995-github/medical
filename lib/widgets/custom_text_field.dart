import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isEnabled;
  final int maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isEnabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          enabled: isEnabled,
          maxLines: maxLines,
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            hintStyle: TextStyle(color: lightTextColor),
          ),
        ),
      ],
    );
  }

  // Factory constructors pour les cas d'utilisation courants
  factory CustomTextField.phoneNumber({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    bool isEnabled = true,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      hint: hint ?? 'Entrez votre numéro de téléphone',
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      isEnabled: isEnabled,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }

  factory CustomTextField.password({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    bool isEnabled = true,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      hint: hint ?? 'Entrez votre mot de passe',
      controller: controller,
      obscureText: obscureText,
      prefixIcon: Icons.lock,
      suffixIcon: obscureText ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: toggleVisibility,
      validator: validator,
      isEnabled: isEnabled,
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }
}
