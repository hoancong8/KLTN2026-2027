// import 'package:bee_note/consts/app_colcor.dart';
// import 'package:bee_note/consts/app_paths.dart';
// import 'package:components/app_text_styles/app_text_styles.dart';
// import 'package:components/app_themes/app_themes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class SearchFormField extends FormField<String> {
//   final TextEditingController? controller;
//   SearchFormField({
//     VoidCallback? onTap,
//     VoidCallback? removeCallBack,
//     FocusNode? focusNode,
//     Key? key,
//     Color? fillColor,
//     String? initialValue,
//     String? labelText,
//     String? hintText,
//     FormFieldSetter<String>? onSaved,
//     FormFieldValidator<String>? validator,
//     bool autoValidate = false,
//     bool enabled = true,
//     bool selected = false,
//     bool readOnly = false,
//     bool enableInteractiveSelection = true,
//     Widget? suffixIcon,
//     Widget? prefixIcon,
//     VoidCallback? actionTap,
//     String? actionLabel,
//     TextCapitalization textCapitalization = TextCapitalization.none,
//     Color? actionColor,
//     AutovalidateMode? autovalidateMode,
//     this.controller,
//     TextInputType? inputType,
//     List<TextInputFormatter>? inputFormatters,
//     int? maxLength,
//     int? maxLine,
//     bool myAutoValidate = false,
//     bool alwaysValidate = false,
//     ValueChanged<String>? onChanged,
//     int? minLines,
//     bool? autoFocus,
//     TextStyle? hintStyle,
//     TextInputAction? textInputAction,
//     EdgeInsets? contentPadding,
//     void Function(String)? onSubmitted,
//     double? height,
//   }) : super(
//          key: key,
//          validator: validator,
//          onSaved: onSaved,
//          initialValue: initialValue,
//          autovalidateMode: alwaysValidate
//              ? AutovalidateMode.always
//              : myAutoValidate
//              ? AutovalidateMode.onUserInteraction
//              : AutovalidateMode.disabled,
//          builder: (FormFieldState field) {
//            SearchFormFieldState state = field as SearchFormFieldState;
//
//            return GestureDetector(
//              onTap: onTap,
//              child: SizedBox(
//                height: height ?? 34,
//                child: Row(
//                  children: [
//                    Expanded(
//                      child: IntrinsicWidth(
//                        child: TextField(
//                          key: key,
//                          textAlignVertical: TextAlignVertical.center,
//                          autocorrect: false,
//                          autofocus: autoFocus ?? false,
//                          enableInteractiveSelection: enableInteractiveSelection,
//                          cursorColor: AppThemes.instance.textLink,
//                          cursorWidth: 2,
//                          textAlign: TextAlign.left,
//                          focusNode: focusNode,
//                          readOnly: readOnly,
//                          minLines: minLines ?? 1,
//                          maxLines: maxLine ?? 1,
//                          controller: state.textEditingController,
//                          style: AppTextStyle.instance.textBody14R,
//                          textInputAction: textInputAction,
//                          keyboardType: inputType ?? TextInputType.text,
//                          textCapitalization: textCapitalization,
//                          onSubmitted: (text) {
//                            if (onSubmitted != null) {
//                              onSubmitted(text);
//                            }
//                          },
//                          inputFormatters: [
//                            ...inputFormatters ?? [],
//                            LengthLimitingTextInputFormatter(maxLength),
//                          ],
//                          onChanged: (text) {
//                            state.didChange(text);
//                            if (onChanged != null) {
//                              onChanged(text);
//                            }
//                          },
//                          decoration: InputDecoration(
//                            filled: true,
//                            fillColor: fillColor ?? AppThemes.instance.bgBase,
//                            hintText: hintText,
//                            hintStyle:
//                                hintStyle ??
//                                AppTextStyle.instance.textBody14R.copyWith(
//                                  color: AppThemes.instance.textTeriary,
//                                ),
//                            labelText: labelText,
//                            contentPadding:
//                                contentPadding ??
//                                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                            prefixIconConstraints: const BoxConstraints(),
//                            suffixIconConstraints: const BoxConstraints(),
//                            prefixIcon: Padding(
//                              padding: const EdgeInsets.only(left: 12, right: 8, top: 7, bottom: 7),
//                              child:
//                                  prefixIcon ??
//                                  SvgPicture.asset(
//                                    AppPaths.ic_profile,
//                                    color: AppThemes.instance.bgDefaultDivider,
//                                    width: 16,
//                                    height: 16,
//                                  ),
//                            ),
//                            enabledBorder: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(4),
//                              borderSide: BorderSide.none,
//                            ),
//                            focusedBorder: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(4),
//                              borderSide: BorderSide.none,
//                            ),
//                            disabledBorder: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(4),
//                              borderSide: BorderSide.none,
//                            ),
//                            suffixIcon: state._showSuffixIcon
//                                ? InkWell(
//                                    onTap: () {
//                                      if (state.textEditingController.text.isNotEmpty) {
//                                        state.textEditingController.clear();
//                                        removeCallBack?.call();
//                                      }
//                                    },
//                                    child: Padding(
//                                      padding: const EdgeInsets.symmetric(
//                                        horizontal: 12,
//                                        vertical: 7,
//                                      ),
//                                      child: SvgPicture.asset(
//                                        AppPaths.ic_qr_app,
//                                        width: 16,
//                                        height: 16,
//                                        color: AppColor.cMainApp,
//                                      ),
//                                    ),
//                                  )
//                                : const SizedBox.shrink(),
//                            enabled: enabled,
//                          ),
//                        ),
//                      ),
//                    ),
//                    if (actionTap != null && actionLabel != null)
//                      InkWell(
//                        onTap: actionTap,
//                        borderRadius: BorderRadius.circular(4),
//                        child: Padding(
//                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//                          child: Center(
//                            child: Text(
//                              actionLabel,
//                              style: AppTextStyle.instance.textCaption12SB.copyWith(
//                                color: actionColor ?? AppThemes.instance.textLink,
//                              ),
//                            ),
//                          ),
//                        ),
//                      ),
//                  ],
//                ),
//              ),
//            );
//          },
//        );
//   @override
//   SearchFormFieldState createState() => SearchFormFieldState();
// }
//
// class SearchFormFieldState extends FormFieldState<String> {
//   late TextEditingController textEditingController;
//   bool _showSuffixIcon = false;
//
//   @override
//   SearchFormField get widget => super.widget as SearchFormField;
//
//   void onChangeObscureText() {
//     setState(() {
//       _showSuffixIcon = textEditingController.text.isNotEmpty;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     textEditingController = widget.controller ?? TextEditingController()
//       ..text = widget.initialValue ?? '';
//     textEditingController.addListener(() {
//       onChangeObscureText();
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     textEditingController.dispose();
//   }
// }
