import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'participant_manual_model.dart';
export 'participant_manual_model.dart';

class ParticipantManualWidget extends StatefulWidget {
  const ParticipantManualWidget({super.key});

  static String routeName = 'ParticipantManual';
  static String routePath = '/participantManual';

  @override
  State<ParticipantManualWidget> createState() =>
      _ParticipantManualWidgetState();
}

class _ParticipantManualWidgetState extends State<ParticipantManualWidget> {
  late ParticipantManualModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ParticipantManualModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(currentUserReference!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: SpinKitDoubleBounce(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 50.0,
                ),
              ),
            ),
          );
        }

        final participantManualUsersRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 54.0,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.safePop();
                },
              ),
              title: Text(
                'Participant Manual',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
              ),
              actions: [],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: SafeArea(
              top: true,
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
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
                                  'Men’s Paedia Manual ',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            Text(
                              'Here you will find the manual for your 90-day journey. It is important you read this thoroughly before day 1 to prepare yourself for the journey ahead of you. ',
                              textAlign: TextAlign.start,
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
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(valueOrDefault<double>(
                        FFAppConstants.SmallPadding.toDouble(),
                        0.0,
                      )),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
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
                            FFAppConstants.MedPadding.toDouble(),
                            0.0,
                          )),
                          child: StreamBuilder<List<ParticipantManualRecord>>(
                            stream: queryParticipantManualRecord(
                              queryBuilder: (participantManualRecord) =>
                                  participantManualRecord
                                      .where(Filter.or(
                                        Filter(
                                          'gender',
                                          isEqualTo:
                                              participantManualUsersRecord
                                                  .gender,
                                        ),
                                        Filter(
                                          'gender',
                                          isEqualTo: valueOrDefault<String>(
                                            'both',
                                            'both',
                                          ),
                                        ),
                                      ))
                                      .orderBy('Position'),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: SpinKitDoubleBounce(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 50.0,
                                    ),
                                  ),
                                );
                              }
                              List<ParticipantManualRecord>
                                  listViewParticipantManualRecordList =
                                  snapshot.data!;

                              return ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount:
                                    listViewParticipantManualRecordList.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.0),
                                itemBuilder: (context, listViewIndex) {
                                  final listViewParticipantManualRecord =
                                      listViewParticipantManualRecordList[
                                          listViewIndex];
                                  return Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          valueOrDefault<double>(
                                            FFAppConstants.SmallPadding
                                                .toDouble(),
                                            0.0,
                                          )),
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        color: Color(0x00000000),
                                        child: ExpandableNotifier(
                                          initialExpanded: false,
                                          child: ExpandablePanel(
                                            header: Text(
                                              listViewParticipantManualRecord
                                                  .title,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.interTight(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                            collapsed: Container(),
                                            expanded: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        FFAppConstants
                                                                .SmallPadding
                                                            .toDouble(),
                                                        0.0,
                                                      ),
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        FFAppConstants
                                                                .MedPadding
                                                            .toDouble(),
                                                        0.0,
                                                      )),
                                              child: custom_widgets
                                                  .HtmlTextDisplay(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 100.0,
                                                htmlContent:
                                                    listViewParticipantManualRecord
                                                        .text,
                                              ),
                                            ),
                                            theme: ExpandableThemeData(
                                              tapHeaderToExpand: true,
                                              tapBodyToExpand: true,
                                              tapBodyToCollapse: true,
                                              headerAlignment:
                                                  ExpandablePanelHeaderAlignment
                                                      .center,
                                              hasIcon: true,
                                              iconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
