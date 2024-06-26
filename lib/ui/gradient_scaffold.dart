import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/theme_provider.dart';

class GradientScaffold extends StatelessWidget {
  bool extendBodyBehindAppBar, resizeToAvoidBottomInset, isPartiallyAnimated;
  PreferredSizeWidget? appBar;
  Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  Widget? floatingActionButton;
  Gradient? gradient;
  Widget? bottomSheet;
  Color? bgColor;
  bool visibleOnKeyboardOpen;
  bool bypassFocusNode;
  GradientScaffold(
      {this.extendBodyBehindAppBar = false,
      this.resizeToAvoidBottomInset = false,
      this.isPartiallyAnimated = false,
      this.visibleOnKeyboardOpen = false,
      this.appBar,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      required this.body,
      this.gradient,
      this.bottomSheet,
      this.bgColor,
      this.bypassFocusNode = false
      });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeGlobal>(context, listen: false);
    return Scaffold(
      backgroundColor: bgColor ?? theme.scaffoldBG,
      extendBodyBehindAppBar: this.extendBodyBehindAppBar,
      resizeToAvoidBottomInset: this.resizeToAvoidBottomInset,
      appBar: this.appBar,
      floatingActionButton: this.floatingActionButton != null
          ? Visibility(
              child: this.floatingActionButton!,
              // ignore: deprecated_member_use
              visible: (WidgetsBinding.instance.window.viewInsets.bottom <= 0.0 || visibleOnKeyboardOpen),
            )
          : null,
      floatingActionButtonLocation: this.floatingActionButtonLocation,
      body: Stack(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(0),
            child: Container(
              decoration: BoxDecoration(
                image: this.gradient != null
                    ? null
                    : DecorationImage(
                        image:isPartiallyAnimated ?AssetImage("assets/images/ic_partial_animated.jpg") :
                        AssetImage("assets/images/ic_onboarding_bg.jpg"),
                        fit: BoxFit.fill,
                      ),
                gradient: this.gradient == null ? null : this.gradient,
              ),
            ),
          ),
          // isPartiallyAnimated
          //     ? Container(
          //         decoration: BoxDecoration(
          //           gradient: LinearGradient(
          //             begin: Alignment.topCenter,
          //             end: Alignment.bottomCenter,
          //             colors: [
          //               theme.scaffoldBG,
          //               theme.scaffoldBG,
          //               //theme.scaffoldBG,
          //               theme.scaffoldBG.withOpacity(0.01),
          //             ],
          //           ),
          //         ),
          //       )
          //     : Container(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              if(bypassFocusNode){
                return;
              }
              else {
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
            child: this.body,
          ),
        ],
      ),
      bottomSheet: this.bottomSheet,
    );
  }
}

class CustomGradientScaffold extends StatelessWidget {
  bool extendBodyBehindAppBar, resizeToAvoidBottomInset, isPartiallyAnimated;
  PreferredSizeWidget? appBar;
  Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  Widget? floatingActionButton;
  Gradient? gradient;
  Widget? bottomSheet;
  ScrollController? controller;
  double topPadding;
  Color? bgColor;
  double leftPadding;
  String? bgAsset;
  double rightPadding;
  CustomGradientScaffold({
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = false,
    this.isPartiallyAnimated = false,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    required this.body,
    this.gradient,
    this.bottomSheet,
    this.controller,
    this.topPadding = 0,
    this.leftPadding = 20,
    this.rightPadding  = 20,
    this.bgColor,
    this.bgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeGlobal>(context, listen: false);
    return Scaffold(
      backgroundColor: bgColor ?? theme.scaffoldBG,
      extendBodyBehindAppBar: this.extendBodyBehindAppBar,
      resizeToAvoidBottomInset: this.resizeToAvoidBottomInset,
      appBar: this.appBar,
      floatingActionButton: this.floatingActionButton,
      floatingActionButtonLocation: this.floatingActionButtonLocation,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: isPartiallyAnimated
            ? Stack(
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.rotationX(isPartiallyAnimated ? math.pi : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: this.gradient != null
                            ? null
                            : DecorationImage(
                                image: AssetImage(
                                    bgAsset ?? "assets/images/bg_gradient.jpg"),
                                fit: BoxFit.cover,
                              ),
                        gradient: this.gradient == null ? null : this.gradient,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBG!,
                          theme.scaffoldBG!,
                          //theme.scaffoldBG,
                          theme.scaffoldBG!.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                  this.body,
                ],
              )
            : SingleChildScrollView(
                controller: this.controller,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: this.gradient != null
                            ? null
                            : DecorationImage(
                                image: AssetImage(
                                    "assets/images/bg_gradient.jpg"),
                                fit: BoxFit.cover,
                              ),
                        gradient: this.gradient == null ? null : this.gradient,
                      ),
                      height: 570,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: this.topPadding, left: this.leftPadding, right: this.rightPadding),
                      child: this.body,
                    )
                  ],
                ),
              ),
      ),
      bottomSheet: this.bottomSheet,
    );
  }
}
