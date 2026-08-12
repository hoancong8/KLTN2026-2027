// import 'package:bee_note/consts/app_paths.dart';
// import 'package:components/app_text_styles/app_text_styles.dart';
// import 'package:components/app_themes/app_themes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lottie/lottie.dart';
//
// class AppFormTextField extends StatefulWidget {
//   static const int noMaxLength = -1;
//   final String topLabelText;
//   final Color? topLabelTextColor;
//   final String hintText;
//   final Color? hintTextColor;
//   final String? errorText;
//   final Color? errorTextColor;
//   final Color? borderFocusColor;
//   final String? warningText;
//   final Color? warningTextColor;
//   final String? initialValue;
//   final bool autoFocus;
//   // final Color? cursorColor;
//   // final double cursorWidth;
//   final double? scrollPadding;
//   final void Function(String)? onChanged;
//   final void Function()? onDelete;
//   final TextInputType keyboardType;
//   final TextCapitalization textCapitalization;
//   final InputDecoration? decoration;
//   final Widget? suffix;
//   final bool enabled;
//   final FocusNode? focusNode;
//   final TextEditingController? controller;
//   final bool readOnly;
//   final bool isLoading;
//   final Widget? subTitle;
//   final Color? textColor;
//   final Color? disabledColor;
//   final List<TextInputFormatter>? inputFormatters;
//   final int maxLength;
//   final InputCounterWidgetBuilder? buildCounter;
//   final Brightness keyboardAppearance;
//   final TextStyle? style;
//   final TextInputAction textInputAction;
//   final Function(String)? onFieldSubmitted;
//   final String Function(String?)? validator;
//   final AutovalidateMode? autovalidate;
//   final int? maxLines;
//   final Iterable<String>? autofillHints;
//   final bool autocorrect;
//   final FontWeight fontWeight;
//   final int? flexTextFormField;
//   final int flexTopLabel;
//   final double? widthTextFormField;
//   final double? borderRadius;
//   final double? hintSize;
//   final bool requiredField;
//   final CrossAxisAlignment crossAxisAlignment;
//   final bool isDisableClear;
//   final bool? showIconClear;
//   final VoidCallback? clearOnTap;
//   final Color? fillColor;
//   final Color? borderColor;
//   final Widget? suffixTitle;
//   final Offset? marginIconR;
//
//   const AppFormTextField({
//     Key? key,
//     this.initialValue,
//     this.topLabelText = '',
//     this.topLabelTextColor,
//     this.hintText = '',
//     this.hintTextColor,
//     this.marginIconR,
//     this.errorText,
//     this.errorTextColor,
//     this.autoFocus = false,
//     this.requiredField = false,
//     // this.cursorColor,
//     // this.cursorWidth = 1,
//     this.scrollPadding,
//     this.clearOnTap,
//     this.warningText,
//     this.warningTextColor,
//     this.keyboardType = TextInputType.visiblePassword,
//     this.onChanged,
//     this.decoration,
//     this.suffix,
//     this.enabled = true,
//     this.controller,
//     this.focusNode,
//     this.showIconClear,
//     this.readOnly = false,
//     this.isLoading = false,
//     this.textColor,
//     this.disabledColor,
//     this.hintSize,
//     this.borderFocusColor,
//     this.inputFormatters,
//     this.textCapitalization = TextCapitalization.none,
//     this.maxLength = AppFormTextField.noMaxLength,
//     this.buildCounter,
//     this.keyboardAppearance = Brightness.light,
//     this.style,
//     this.borderRadius,
//     this.validator,
//     this.autovalidate,
//     this.maxLines,
//     this.autofillHints,
//     this.autocorrect = true,
//     this.fontWeight = FontWeight.w400,
//     this.subTitle,
//     this.onFieldSubmitted,
//     this.flexTopLabel = 2,
//     this.textInputAction = TextInputAction.next,
//     this.widthTextFormField,
//     this.onDelete,
//     this.flexTextFormField,
//     this.crossAxisAlignment = CrossAxisAlignment.center,
//     this.isDisableClear = true,
//     this.fillColor,
//     this.borderColor,
//     this.suffixTitle,
//   }) : super(key: key);
//
//   @override
//   _AppFormTextFieldState createState() => _AppFormTextFieldState();
// }
//
// class _AppFormTextFieldState extends State<AppFormTextField> {
//   bool _readOnly = false;
//   bool _isLoading = false;
//   late String _initialValue;
//   late String _stateCurrentValue;
//
//   FocusNode? _focusNode;
//
//   TextEditingController _effectiveController = TextEditingController();
//
//   bool get needsCounter => (widget.maxLength != AppFormTextField.noMaxLength);
//
//   int get _currentLength => _effectiveController.value.text.runes.length;
//
//   FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());
//
//
//   @override
//   Widget build(BuildContext context) {
//     _readOnly = widget.readOnly;
//     _isLoading = widget.isLoading;
//     final List<TextInputFormatter> formatters = widget.inputFormatters ?? <TextInputFormatter>[];
//     formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
//
//     Widget counter = _getCounter();
//
//     return Column(
//       children: [
//         Row(
//           children: [
//             Visibility(
//               visible: widget.topLabelText.isNotEmpty,
//               child: Expanded(
//                 flex: widget.flexTopLabel,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         widget.requiredField
//                             ? Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   Text(
//                                     widget.topLabelText,
//                                     style: AppTextStyle.instance.textBody14R,
//                                   ),
//                                   Positioned(
//                                     right: -12,
//                                     top: -10,
//                                     child: Visibility(
//                                       visible: true,
//                                       child: Container(
//                                         alignment: Alignment.centerRight,
//                                         margin: const EdgeInsets.only(top: 5),
//                                         width: 20,
//                                         height: 20,
//                                         child: Text(
//                                           '*',
//                                           style: TextStyle(
//                                             color: AppThemes.instance.bgBorder,
//                                             fontSize: 20,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Text(
//                                 widget.topLabelText,
//                                 style: AppTextStyle.instance.textBody14R.copyWith(
//                                   fontWeight: widget.fontWeight,
//                                   color: widget.topLabelTextColor ?? AppThemes.instance.textTeriary,
//                                 ),
//                               ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 16),
//                           child: widget.subTitle ?? const SizedBox(),
//                         ),
//                       ],
//                     ),
//                     counter,
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Visibility(visible: widget.topLabelText.isNotEmpty, child: SizedBox(height: 8)),
//         Row(
//           crossAxisAlignment: widget.crossAxisAlignment,
//           children: [
//             Expanded(
//               flex: widget.flexTextFormField ?? 3,
//               child: Stack(
//                 children: [
//                   SizedBox(
//                     width: widget.widthTextFormField ?? null,
//                     child: TextFormField(
//                       onChanged: widget.onChanged,
//                       style: widget.style ?? AppTextStyle.instance.textBody14R,
//                       autofocus: widget.autoFocus,
//                       focusNode: widget.focusNode,
//                       decoration: _getEffectiveDecoration(),
//                       cursorColor: AppThemes.instance.textLink,
//                       cursorWidth: 1.5,
//                       maxLines: widget.maxLines,
//                       keyboardType: widget.keyboardType,
//                       cursorHeight: 22,
//                       keyboardAppearance: widget.keyboardAppearance,
//                       controller: _effectiveController,
//                       autofillHints: widget.autofillHints,
//                       autocorrect: widget.autocorrect,
//                       enabled: !_readOnly,
//                       readOnly: _readOnly,
//                       inputFormatters: formatters,
//                       textCapitalization: widget.textCapitalization,
//                       autovalidateMode: widget.autovalidate ?? AutovalidateMode.disabled,
//                       validator: widget.validator,
//                       textInputAction: widget.textInputAction,
//                       onFieldSubmitted: (String value) {
//                         if (widget.onFieldSubmitted != null) {
//                           widget.onFieldSubmitted!(value);
//                         }
//                         if (widget.textInputAction == TextInputAction.next) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                       },
//                       scrollPadding: EdgeInsets.only(bottom: widget.scrollPadding ?? 0),
//                     ),
//                   ),
//                   Positioned(
//                     right: widget.marginIconR?.dx ?? 0,
//                     top: widget.marginIconR?.dy ?? 0,
//                     child: widget.showIconClear == true
//                         ? StreamBuilder<bool>(
//                             stream: showClear,
//                             initialData: false,
//                             builder: (context, snapshot) {
//                               return snapshot.data == true
//                                   ? GestureDetector(
//                                       onTap: () {
//                                         widget.controller?.clear();
//                                       },
//                                       child: const Padding(
//                                         padding: EdgeInsets.all(8),
//                                         child: Icon(Icons.highlight_remove_outlined, size: 20),
//                                       ),
//                                     )
//                                   : const SizedBox();
//                             },
//                           )
//                         : const SizedBox(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   InputDecoration defaultInputDecoration({
//     Color? hintTextColor,
//     Color? errorTextColor,
//     Color? warningTextColor,
//     Color? disabledColor,
//     double? hintSize,
//     bool enabled = true,
//   }) {
//     return InputDecoration(
//       hintStyle: AppTextStyle.instance.textBody14R.copyWith(
//         color: enabled
//             ? hintTextColor ?? AppThemes.instance.textSecondary
//             : disabledColor ?? AppThemes.instance.textTeriary,
//         fontSize: hintSize,
//       ),
//       errorStyle: AppTextStyle.instance.textBody14R.copyWith(
//         color: errorTextColor ?? AppThemes.instance.bgBorder,
//       ),
//       errorMaxLines: 2,
//       errorBorder: UnderlineInputBorder(
//         borderSide: BorderSide(width: 1, color: AppThemes.instance.bgDefaultDivider),
//       ),
//       helperStyle: AppTextStyle.instance.textBody14R.copyWith(
//         color: warningTextColor ?? AppThemes.instance.bgHeader,
//       ),
//       helperMaxLines: 2,
//       isDense: true,
//       filled: true,
//       contentPadding: const EdgeInsets.all(
//         10,
//       ).copyWith(right: widget.showIconClear == true ? 24 : 10),
//       fillColor: widget.fillColor ?? AppThemes.instance.bgSecondary,
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(
//           width: 1,
//           color: widget.borderColor ?? AppThemes.instance.bgLightBorder,
//         ),
//         borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.0),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(
//           width: 1,
//           color: widget.borderFocusColor ?? AppThemes.instance.textLink,
//         ),
//         borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.0),
//       ),
//       floatingLabelBehavior: FloatingLabelBehavior.always,
//       disabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(
//           width: 1,
//           color: widget.borderColor ?? AppThemes.instance.bgLightBorder,
//         ),
//         borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.0),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _focusNode?.dispose();
//     if (widget.controller == null) {
//       _effectiveController.dispose();
//     }
//     widget.controller?.removeListener(() {});
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     _initialValue = widget.initialValue ?? "";
//     _stateCurrentValue = widget.initialValue ?? "";
//
//     if (widget.controller != null) {
//       _effectiveController = widget.controller!;
//     }
//     if (_initialValue.isNotEmpty) {
//       _effectiveController.text = "$_initialValue";
//     }
//
//     _effectiveController.addListener(() {
//       if (_stateCurrentValue != _effectiveController.text) {
//         _stateCurrentValue = _effectiveController.text;
//         if (widget.onChanged != null) {
//           widget.onChanged!(_stateCurrentValue);
//         }
//       }
//
//       if (needsCounter) {
//         setState(() {});
//       }
//     });
//     widget.controller?.addListener(() {
//       if (widget.controller?.text.isEmpty == true) {
//         showClear.add(false);
//       } else {
//         showClear.add(true);
//       }
//     });
//
//     super.initState();
//   }
//
//   Widget _buildSuffix() {
//     return _isLoading
//         ? SizedBox(
//             width: 16.0,
//             height: 16.0,
//             child: Lottie.asset(AppPaths.ic_language, fit: BoxFit.fill),
//           )
//         : Visibility(
//             visible: !widget.isDisableClear,
//             child: GestureDetector(
//               onTap: () {
//                 _effectiveController.clear();
//                 if (widget.onDelete != null) {
//                   widget.onDelete?.call();
//                 }
//               },
//             ),
//           );
//   }
//
//   Widget _getCounter() {
//     if (!needsCounter) {
//       return Container();
//     }
//
//     final int currentLength = _currentLength;
//     if (widget.buildCounter != null) {
//       final bool isFocused = _effectiveFocusNode.hasFocus;
//
//       return Semantics(
//         container: true,
//         liveRegion: isFocused,
//         child: widget.buildCounter!(
//           context,
//           currentLength: currentLength,
//           maxLength: widget.maxLength,
//           isFocused: isFocused,
//         ),
//       );
//     }
//     // Show the maxLength in the counter
//
//     if (widget.maxLength > 0) {
//       String counterText = '$currentLength';
//
//       counterText += '/${widget.maxLength}';
//       final bool isFocused = _effectiveFocusNode.hasFocus;
//
//       return Semantics(
//         container: true,
//         liveRegion: isFocused,
//         child: Text(
//           counterText,
//           style: AppTextStyle.instance.textBody14R.copyWith(color: AppThemes.instance.textTeriary),
//         ),
//       );
//     }
//
//     return Container();
//   }
//
//   InputDecoration _getEffectiveDecoration() {
//     final InputDecoration effectiveDecoration =
//         widget.decoration?.copyWith(enabled: !_readOnly) ??
//         defaultInputDecoration(
//           enabled: !_readOnly,
//           hintTextColor: widget.hintTextColor,
//           disabledColor: widget.disabledColor,
//           hintSize: widget.hintSize,
//         ).copyWith(
//           enabled: !_readOnly,
//           hintText: widget.hintText,
//           errorText: widget.errorText,
//           helperText: widget.warningText,
//           suffix: _readOnly ? null : _buildSuffix(),
//         );
//
//     return effectiveDecoration;
//   }
// }
