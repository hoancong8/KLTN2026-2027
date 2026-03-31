// import 'package:flutter/material.dart';
// import 'package:bee_note_md01/consts/app_colcor.dart';
// import 'package:bee_note_md01/consts/app_dimens.dart';
// import 'package:bee_note_md01/consts/app_images.dart';
// import 'package:bee_note_md01/consts/app_paths.dart';
// import 'package:bee_note_md01/generated/l10n.dart';
// import 'package:bee_note_md01/routers/app_router_paths.dart';
// import 'package:bee_note_md01/widgets/app_button/app_button.dart';
//
//
// class AppInputWidget extends StatelessWidget {
//   final String? label;
//   final String? content;
//   final bool isRequired;
//   final bool showIcon;
//   final Color? borderColor;
//   final Color? labelBgColor;
//   final Widget? icon;
//   final TextStyle? labelStyle;
//   final TextStyle? contentStyle;
//   const AppInputWidget({
//     Key? key,
//     this.label,
//     this.content,
//     this.borderColor,
//     this.isRequired = false,
//     this.showIcon = true,
//     this.icon,
//     this.labelBgColor,
//     this.labelStyle,
//     this.contentStyle,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: AppThemes.instance.bgSecondary,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(width: 1, color: borderColor ?? AppThemes.instance.bgLightBorder),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           if (label != null)
//             Container(
//               width: 120,
//               height: 40,
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(color: labelBgColor ?? AppThemes.instance.bgBase),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(label!, style: labelStyle ?? AppTextStyle.instance.textBody14R),
//                   if (isRequired)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 4),
//                       child: Text(
//                         '*',
//                         style: AppTextStyle.instance.textCaption12SB.copyWith(
//                           color: AppThemes.instance.bgBorder,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           if (content != null)
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     content ?? "",
//                     style: contentStyle ?? AppTextStyle.instance.textBody14R,
//                   ),
//                 ),
//               ),
//             ),
//           if (showIcon)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Center(
//                 child:
//                     icon ??
//                     Icon(
//                       Icons.keyboard_arrow_down_sharp,
//                       color: AppThemes.instance.bgDefaultDivider,
//                     ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
