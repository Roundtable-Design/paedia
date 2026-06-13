import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'manual_model.dart';
export 'manual_model.dart';

class ManualWidget extends StatefulWidget {
  const ManualWidget({super.key});

  static String routeName = 'Manual';
  static String routePath = '/manual';

  @override
  State<ManualWidget> createState() => _ManualWidgetState();
}

class _ManualWidgetState extends State<ManualWidget> {
  late ManualModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManualModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                0.0,
                valueOrDefault<double>(
                  FFAppConstants.MedPadding.toDouble(),
                  0.0,
                ),
                0.0,
                0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        valueOrDefault<double>(
                          FFAppConstants.MedPadding.toDouble(),
                          0.0,
                        ),
                        valueOrDefault<double>(
                          FFAppConstants.MedPadding.toDouble(),
                          0.0,
                        ),
                        valueOrDefault<double>(
                          FFAppConstants.MedPadding.toDouble(),
                          0.0,
                        ),
                        valueOrDefault<double>(
                          FFAppConstants.SmallPadding.toDouble(),
                          0.0,
                        )),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Manuals ',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                          ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            tabletLandscape: false,
                            desktop: false,
                          ))
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0,
                                  0.0,
                                  0.0,
                                  valueOrDefault<double>(
                                    FFAppConstants.SmallPadding.toDouble(),
                                    0.0,
                                  )),
                              child: Text(
                                '*Paedia [pideya] (to discipline, to train children, the rearing of a child) ',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            tabletLandscape: false,
                            desktop: false,
                          ))
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  valueOrDefault<double>(
                                    FFAppConstants.SmallPadding.toDouble(),
                                    0.0,
                                  ),
                                  0.0,
                                  valueOrDefault<double>(
                                    FFAppConstants.SmallPadding.toDouble(),
                                    0.0,
                                  ),
                                  0.0),
                              child: Text(
                                'Here you will find the manual for your 90-day journey. It is important you read this thoroughly before day 1 to prepare yourself for the journey ahead of you. ',
                                textAlign: TextAlign.justify,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0,
                                valueOrDefault<double>(
                                  FFAppConstants.SmallPadding.toDouble(),
                                  0.0,
                                ),
                                0.0,
                                valueOrDefault<double>(
                                  FFAppConstants.SmallPadding.toDouble(),
                                  0.0,
                                )),
                            child: Text(
                              '*Paedia [pideya] (to discipline, to train children, the rearing of a child) ',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(valueOrDefault<double>(
                      FFAppConstants.SmallPadding.toDouble(),
                      0.0,
                    )),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(ParticipantManualWidget.routeName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                2.0,
                              ),
                            )
                          ],
                          borderRadius:
                              BorderRadius.circular(valueOrDefault<double>(
                            FFAppConstants.BorderRadius.toDouble(),
                            0.0,
                          )),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(valueOrDefault<double>(
                            FFAppConstants.SmallPadding.toDouble(),
                            0.0,
                          )),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.how_to_reg_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              Text(
                                'Participant Manual',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(valueOrDefault<double>(
                      FFAppConstants.SmallPadding.toDouble(),
                      0.0,
                    )),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(AccessoryManualWidget.routeName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                2.0,
                              ),
                            )
                          ],
                          borderRadius:
                              BorderRadius.circular(valueOrDefault<double>(
                            FFAppConstants.BorderRadius.toDouble(),
                            0.0,
                          )),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(valueOrDefault<double>(
                            FFAppConstants.SmallPadding.toDouble(),
                            0.0,
                          )),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.handyman,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              Text(
                                'Accessory Manual',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (responsiveVisibility(
                    context: context,
                    phone: false,
                    tablet: false,
                    tabletLandscape: false,
                    desktop: false,
                  ))
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(valueOrDefault<double>(
                            FFAppConstants.SmallPadding.toDouble(),
                            0.0,
                          )),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context
                                  .pushNamed(ParticipantManualWidget.routeName);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(
                                    valueOrDefault<double>(
                                  FFAppConstants.BorderRadius.toDouble(),
                                  0.0,
                                )),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  FFAppConstants.SmallPadding.toDouble(),
                                  0.0,
                                )),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          valueOrDefault<double>(
                                            FFAppConstants.SmallPadding
                                                .toDouble(),
                                            0.0,
                                          )),
                                      child: Icon(
                                        Icons.how_to_reg_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 65.0,
                                      ),
                                    ),
                                    Text(
                                      'Participant manual',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(valueOrDefault<double>(
                            FFAppConstants.SmallPadding.toDouble(),
                            0.0,
                          )),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context
                                  .pushNamed(AccessoryManualWidget.routeName);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(
                                    valueOrDefault<double>(
                                  FFAppConstants.BorderRadius.toDouble(),
                                  0.0,
                                )),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  FFAppConstants.SmallPadding.toDouble(),
                                  0.0,
                                )),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          valueOrDefault<double>(
                                            FFAppConstants.SmallPadding
                                                .toDouble(),
                                            0.0,
                                          )),
                                      child: Icon(
                                        Icons.handyman,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 65.0,
                                      ),
                                    ),
                                    Text(
                                      'Accessory manual',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
