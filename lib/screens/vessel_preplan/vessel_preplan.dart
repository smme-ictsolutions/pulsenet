import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/menu.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/vessel_preplan/requirements_tab.dart';
import 'package:customer_portal/screens/vessel_preplan/transhipment_tab.dart';
import 'package:customer_portal/screens/vessel_preplan/vessel_tab.dart';
import 'package:customer_portal/screens/vessel_preplan/volume_tab.dart';
import 'package:customer_portal/shared/approval_wrapper.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class VesselPreplanForm extends StatefulWidget {
  const VesselPreplanForm({
    super.key,
    required this.subscribeData,
    required this.imageData,
    required this.sector,
    required this.title,
    required this.mobiAppData,
    required this.pendingApprovals,
  });
  final UserSubscribeData subscribeData;
  final List<ImageData> imageData;
  final String title, sector;
  final MobiAppData mobiAppData;
  final List<Approvals> pendingApprovals;

  @override
  State<VesselPreplanForm> createState() => _VesselPreplanFormState();
}

class _VesselPreplanFormState extends State<VesselPreplanForm>
    with SingleTickerProviderStateMixin {
  final _formVesselKey = GlobalKey<FormState>(),
      _formVolumesKey = GlobalKey<FormState>(),
      _formRequirementsKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  bool loading = false, _isEdit = false, _isApproved = false;
  final List<PrePlanModel> _transactionData = [];

  void _checkApprovedStatus() {
    _isApproved =
        widget.pendingApprovals
            .where((element) => element.user == widget.subscribeData.email)
            .first
            .modules
            .where((module) => module == widget.title)
            .isEmpty;
    setState(() {});
  }

  void _resetFormValues() {
    appData.myVesselNameSelection = "";
    appData.myVoyageNumberSelection = "";
    appData.myVesselETASelection = DateTime.now();
    appData.myStartOperationsSelection = DateTime.now();
  }

  void _setResetGlobalValues() {
    appData.myPortSelection = "";
    appData.myVesselNameSelection = "";
    appData.myVoyageNumberSelection = "";
    appData.myStakeholderSelection = "";
    appData.myStevedoreSelection = "";
    appData.myBerthSelection = "";
    appData.myVesselTypeSelection = "";
    appData.myShippingLineSelection = "";
    appData.myBerthSuitability = "";
    appData.myDischargeSequenceSelection = "";
    appData.myLoadSequenceSelection = "";
    appData.myVolumeCommentsSelection = "";
    appData.myMafiListSelection = "";
    appData.mySideRampSelection = "No";
    appData.myPanelingTypeSelection = "Electronic";
    appData.checkboxHeavies = false;
    appData.checkboxMafi = false;
    appData.checkboxStatics = false;
    appData.checkboxTracks = false;
    appData.checkboxUsed = false;
    appData.checkboxNewImports = false;
    appData.checkboxNewExports = false;
    appData.myImportNewSelection = 0;
    appData.myExportNewSelection = 0;
    appData.myImportRubberHeaviesSelection = 0;
    appData.myExportRubberHeaviesSelection = 0;
    appData.myImportUsedHeaviesSelection = 0;
    appData.myImportStaticsNonMafiSelection = 0;
    appData.myExportStaticsNonMafiSelection = 0;
    appData.myImportUsedStaticsSelection = 0;
    appData.myImportMafiWithCargoSelection = 0;
    appData.myExportMafiWithCargoSelection = 0;
    appData.myImportStaticsMafiSelection = 0;
    appData.myExportStaticsMafiSelection = 0;
    appData.myImportUsedSelection = 0;
    appData.myExportUsedSelection = 0;
    appData.myImportHeaviesTracksSelection = 0;
    appData.myExportHeaviesTracksSelection = 0;
    appData.myDirectRestowSelection = 0;
    appData.myIndirectRestowSelection = 0;
    appData.myStevedoreDriversSelection = 0;
    appData.myStevedorePilotsSelection = 0;
    appData.myExportLanesSelection = 0;
    appData.myImportLanesSelection = 0;
    appData.myReverseStowTimeSelection = 0;
    appData.mySecureMainDeckSelection = 0;
    appData.myBunkerTimeSelection = 0;
    appData.myClearMainDeckSelection = 60;
    appData.myBreakStowSelection = 10;
    appData.myunlashingUnitsSelection = 60;
    appData.myDirectRestowTimeSelection = 0;
    appData.myIndirectRestowTimeSelection = 0;
    appData.myPanelingTimeSelection = 60;
  }

  void _setEditFormValues() {
    appData.myVesselETASelection =
        _transactionData.first.vesselDetails.vesselETA;
    appData.myStartOperationsSelection =
        _transactionData.first.vesselDetails.startOperations;
    appData.myBerthSelection = _transactionData.first.vesselDetails.berthCode;
    appData.myVesselNameSelection =
        _transactionData.first.vesselDetails.vesselName;
    appData.myVoyageNumberSelection =
        _transactionData.first.vesselDetails.voyage;
    appData.myPortSelection = _transactionData.first.vesselDetails.port;
    appData.myStakeholderSelection =
        _transactionData.first.vesselDetails.stakeholder;
    appData.myStevedoreSelection =
        _transactionData.first.vesselDetails.stevedore;
    appData.myVesselTypeSelection =
        _transactionData.first.vesselDetails.vesselType;
    appData.myShippingLineSelection =
        _transactionData.first.vesselDetails.shippingLine;
    appData.myBerthSuitability =
        _transactionData.first.vesselDetails.berthSuitability;
    appData.myPanelingTypeSelection =
        _transactionData.first.preparationDetails.paneling;
    appData.myClearMainDeckSelection =
        _transactionData.first.preparationDetails.clearMainDeck;
    appData.myBreakStowSelection =
        _transactionData.first.preparationDetails.breakStow;
    appData.myunlashingUnitsSelection =
        _transactionData.first.preparationDetails.unlashingUnits;
    appData.myDirectRestowTimeSelection =
        _transactionData.first.preparationDetails.directRestow;
    appData.myIndirectRestowTimeSelection =
        _transactionData.first.preparationDetails.indirectRestow;
    appData.myPanelingTimeSelection =
        _transactionData.first.preparationDetails.panelingTime;
    appData.myImportNewSelection =
        _transactionData.first.volumeDetails.importNew;
    appData.myExportNewSelection =
        _transactionData.first.volumeDetails.exportNew;
    appData.myImportRubberHeaviesSelection =
        _transactionData.first.volumeDetails.importRubberHeavies;
    appData.myExportRubberHeaviesSelection =
        _transactionData.first.volumeDetails.exportRubberHeavies;
    appData.myImportUsedHeaviesSelection =
        _transactionData.first.volumeDetails.importUsedHeavies;
    appData.myImportStaticsNonMafiSelection =
        _transactionData.first.volumeDetails.importStaticsNonMafi;
    appData.myExportStaticsNonMafiSelection =
        _transactionData.first.volumeDetails.exportStaticsNonMafi;
    appData.myImportUsedStaticsSelection =
        _transactionData.first.volumeDetails.importUsedStatics;
    appData.myImportMafiWithCargoSelection =
        _transactionData.first.volumeDetails.importMafiWithCargo;
    appData.myExportMafiWithCargoSelection =
        _transactionData.first.volumeDetails.exportMafiWithCargo;
    appData.myImportStaticsMafiSelection =
        _transactionData.first.volumeDetails.importStaticsMafi;
    appData.myExportStaticsMafiSelection =
        _transactionData.first.volumeDetails.exportStaticsMafi;
    appData.myImportUsedSelection =
        _transactionData.first.volumeDetails.importUsed;
    appData.myExportUsedSelection =
        _transactionData.first.volumeDetails.exportUsed;
    appData.myImportHeaviesTracksSelection =
        _transactionData.first.volumeDetails.importHeaviesTracks;
    appData.myExportHeaviesTracksSelection =
        _transactionData.first.volumeDetails.exportHeaviesTracks;
    appData.myDischargeSequenceSelection =
        _transactionData.first.requirementDetails.dischargeSequence;
    appData.myLoadSequenceSelection =
        _transactionData.first.requirementDetails.loadSequence;
    appData.myVolumeCommentsSelection =
        _transactionData.first.requirementDetails.volumeComments;
    appData.myMafiListSelection =
        _transactionData.first.requirementDetails.mafiList;
    appData.myDirectRestowSelection =
        _transactionData.first.requirementDetails.directRestows;
    appData.myIndirectRestowSelection =
        _transactionData.first.requirementDetails.indirectRestows;
    appData.myStevedoreDriversSelection =
        _transactionData.first.requirementDetails.stevedoreDrivers;
    appData.myStevedorePilotsSelection =
        _transactionData.first.requirementDetails.stevedorePilots;

    appData.myExportLanesSelection =
        _transactionData.first.requirementDetails.exportLanes;
    appData.myImportLanesSelection =
        _transactionData.first.requirementDetails.importLanes;
    appData.myReverseStowTimeSelection =
        _transactionData.first.requirementDetails.reverseStowTime;
    appData.mySecureMainDeckSelection =
        _transactionData.first.requirementDetails.secureMainDeck;
    appData.myBunkerTimeSelection =
        _transactionData.first.requirementDetails.bunkerTime;
    appData.mySideRampSelection =
        _transactionData.first.requirementDetails.sideRamp;
    appData.checkboxHeavies =
        _transactionData.first.requirementDetails.parallelHeavies;
    appData.checkboxMafi =
        _transactionData.first.requirementDetails.parallelMafis;
    appData.checkboxStatics =
        _transactionData.first.requirementDetails.parallelStatics;
    appData.checkboxTracks =
        _transactionData.first.requirementDetails.parallelTracks;
    appData.checkboxUsed =
        _transactionData.first.requirementDetails.parallelUsed;
    appData.checkboxNewImports =
        _transactionData.first.requirementDetails.parallelImportNew;
    appData.checkboxNewExports =
        _transactionData.first.requirementDetails.parallelExportNew;
  }

  @override
  void initState() {
    _setResetGlobalValues();
    _checkApprovedStatus();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 1:
            if (!_formVesselKey.currentState!.validate()) {
              _tabController.index = 0;
            } else {
              appData.vesselDetails = VesselModel(
                berthCode: appData.myBerthSelection,
                vesselName: appData.myVesselNameSelection,
                voyage: appData.myVoyageNumberSelection,
                port: appData.myPortSelection,
                stakeholder: appData.myStakeholderSelection,
                stevedore: appData.myStevedoreSelection,
                vesselType: appData.myVesselTypeSelection,
                shippingLine: appData.myShippingLineSelection,
                vesselETA: appData.myVesselETASelection,
                startOperations: appData.myStartOperationsSelection,
                endOperations: appData.myStartOperationsSelection,
                departureTime: appData.myStartOperationsSelection,
                berthSuitability: appData.myBerthSuitability,
              );
              appData.preparationDetails = VesselPreparation(
                paneling: appData.myPanelingTypeSelection,
                clearMainDeck: appData.myClearMainDeckSelection,
                breakStow: appData.myBreakStowSelection,
                unlashingUnits: appData.myunlashingUnitsSelection,
                directRestow: appData.myDirectRestowTimeSelection,
                indirectRestow: appData.myIndirectRestowTimeSelection,
                panelingTime: appData.myPanelingTimeSelection,
              );
            }
          case 2:
            if (!_formVolumesKey.currentState!.validate()) {
              _tabController.index = 1;
            } else {
              appData.volumeDetails = VolumesModel(
                importNew: appData.myImportNewSelection,
                exportNew: appData.myExportNewSelection,
                importRubberHeavies: appData.myImportRubberHeaviesSelection,
                exportRubberHeavies: appData.myExportRubberHeaviesSelection,
                importUsedHeavies: appData.myImportUsedHeaviesSelection,
                importStaticsNonMafi: appData.myImportStaticsNonMafiSelection,
                exportStaticsNonMafi: appData.myExportStaticsNonMafiSelection,
                importUsedStatics: appData.myImportUsedStaticsSelection,
                importMafiWithCargo: appData.myImportMafiWithCargoSelection,
                exportMafiWithCargo: appData.myExportMafiWithCargoSelection,
                importStaticsMafi: appData.myImportStaticsMafiSelection,
                exportStaticsMafi: appData.myExportStaticsMafiSelection,
                importUsed: appData.myImportUsedSelection,
                exportUsed: appData.myExportUsedSelection,
                importHeaviesTracks: appData.myImportHeaviesTracksSelection,
                exportHeaviesTracks: appData.myExportHeaviesTracksSelection,
              );
            }
          case 3:
            if (!_formRequirementsKey.currentState!.validate()) {
              _tabController.index = 2;
            } else {
              appData.requirementDetails = RequirementsModel(
                dischargeSequence: appData.myDischargeSequenceSelection,
                loadSequence: appData.myLoadSequenceSelection,
                volumeComments: appData.myVolumeCommentsSelection,
                mafiList: appData.myMafiListSelection,
                directRestows: appData.myDirectRestowSelection,
                indirectRestows: appData.myIndirectRestowSelection,
                stevedoreDrivers: appData.myStevedoreDriversSelection,
                stevedorePilots: appData.myStevedorePilotsSelection,
                exportLanes: appData.myExportLanesSelection,
                importLanes: appData.myImportLanesSelection,
                reverseStowTime: appData.myReverseStowTimeSelection,
                secureMainDeck: appData.mySecureMainDeckSelection,
                bunkerTime: appData.myBunkerTimeSelection,
                sideRamp: appData.mySideRampSelection,
                parallelHeavies: appData.checkboxHeavies,
                parallelMafis: appData.checkboxMafi,
                parallelStatics: appData.checkboxStatics,
                parallelTracks: appData.checkboxTracks,
                parallelUsed: appData.checkboxUsed,
                parallelImportNew: appData.checkboxNewImports,
                parallelExportNew: appData.checkboxNewExports,
              );
            }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    appData.transhipmentPreCarrier = [];
    appData.transhipmentOnCarrier = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !_isApproved && !widget.subscribeData.isAdmin
        ? SizedBox(
          height: MediaQuery.of(context).size.height * .9,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            backgroundColor: kColorBackground,
            body: ApprovalWrapper(
              adminAddress:
                  appData.modulesList
                      .where(
                        (element) =>
                            element.module == widget.title &&
                            element.terminal ==
                                widget.subscribeData.port!.first,
                      )
                      .first
                      .admin,
            ),
          ),
        )
        : SizedBox(
          height: MediaQuery.of(context).size.height * .9,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Icon(Icons.water), text: 'Vessel'),
                  Tab(icon: Icon(Icons.card_giftcard), text: 'Volumes'),
                  Tab(icon: Icon(Icons.person), text: 'Requirements'),
                  Tab(
                    icon: Icon(Icons.transfer_within_a_station),
                    text: 'Transhipments',
                  ),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: kHeaderLabelTextStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  appData.transactionData.isEmpty
                      ? Container()
                      : Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text(
                            'Tap to edit existing preplan',
                            style: kLabelTextStyle,
                          ),
                          dropdownColor: kColorText,
                          style: kLabelTextStyle,
                          iconSize: 24,
                          iconEnabledColor: kColorBar,
                          iconDisabledColor: kColorNavIcon,
                          items:
                              appData.transactionData.map<
                                DropdownMenuItem<String>
                              >((item) {
                                return DropdownMenuItem<String>(
                                  value:
                                      '${item.vesselName}:${item.voyageNumber}',
                                  child: Text(
                                    '${item.vesselName} ${item.voyageNumber}',
                                    style: kLabelTextStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) async {
                            setState(() {
                              loading = true;
                            });
                            if (_isEdit) {
                              await DialogService(
                                button:
                                    'Edit already in progress, click save or home first...',
                                origin: "Error",
                              ).confirmError(context: context);
                              setState(() {
                                loading = false;
                              });
                            } else {
                              _transactionData.clear();
                              try {
                                DatabaseService(null)
                                    .getSharePointData(
                                      '{"vesselname":"${newValue!.split(":")[0]}","voyage":"${newValue.split(":")[1]}"}',
                                      widget.mobiAppData,
                                    )
                                    .then((value) async {
                                      if (!context.mounted) return;
                                      if (value.startsWith("Error") ||
                                          value == "Unauthorized" ||
                                          value.startsWith("402") ||
                                          value.startsWith("502")) {
                                        await DialogService(
                                          button: value,
                                          origin: "Error",
                                        ).confirmError(context: context);
                                        _isEdit = false;

                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        debugPrint(value);
                                        _transactionData.add(
                                          PrePlanModel.fromMap(
                                            json.decode(value),
                                          ),
                                        );
                                        //set form values
                                        _setEditFormValues();
                                        _isEdit = true;

                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    });
                              } catch (error) {
                                debugPrint(error.toString());
                              }
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kColorNavIcon.withValues(alpha: 0.4),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            prefixIcon: const Icon(
                              Icons.sailing,
                              color: kColorForeground,
                            ),
                          ),
                        ),
                      ),
                  Expanded(
                    child: CachedNetworkImage(
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                      imageUrl:
                          widget.imageData
                              .where((element) => element.title == 'TPTLogo')
                              .first
                              .url,
                      imageBuilder:
                          (context, imageProvider) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                                alignment: Alignment.topRight,
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            //extendBody: true,
            backgroundColor: kColorNavIcon,
            key: _key,
            resizeToAvoidBottomInset: false,
            body:
                loading
                    ? Center(
                      child: CircularProgressIndicator(color: kColorSplash),
                    )
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        Form(
                          key: _formVesselKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: VesselTab(
                              tabBar: _tabController,
                              sector: widget.sector,
                              preplanDetails: _transactionData,
                              isEdit: _isEdit,
                            ),
                          ),
                        ),
                        Form(
                          key: _formVolumesKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: VolumeTab(
                              tabBar: _tabController,
                              sector: widget.sector,
                              preplanDetails: _transactionData,
                              isEdit: _isEdit,
                            ),
                          ),
                        ),
                        Form(
                          key: _formRequirementsKey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RequirementsTab(
                              tabBar: _tabController,
                              sector: widget.sector,
                              preplanDetails: _transactionData,
                              isEdit: _isEdit,
                            ),
                          ),
                        ),
                        Form(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: TranshipmentTab(
                              tabBar: _tabController,
                              sector: widget.sector,
                              preplanDetails: _transactionData,
                              isEdit: _isEdit,
                            ),
                          ),
                        ),
                      ],
                    ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () async {
                      _resetFormValues();
                      Navigator.pop(context);
                    },
                    backgroundColor: kColorBackground,
                    elevation: 12,
                    foregroundColor: kColorForeground,
                    splashColor: kColorSuccess,
                    child: const Icon(Icons.home, size: 50),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    heroTag: 'btn2',
                    onPressed: () async {
                      try {
                        if (!_formVesselKey.currentState!.validate()) {
                          _tabController.index = 0;
                          return;
                        } else if (!_formVolumesKey.currentState!.validate()) {
                          _tabController.index = 1;
                          return;
                        } else if (!_formRequirementsKey.currentState!
                            .validate()) {
                          _tabController.index = 2;
                          return;
                        } else {
                          //no transhipments manually set requirements
                          appData.transhipmentOnCarrier.isEmpty &&
                                  appData.transhipmentPreCarrier.isEmpty
                              ? appData.requirementDetails = RequirementsModel(
                                dischargeSequence:
                                    appData.myDischargeSequenceSelection,
                                loadSequence: appData.myLoadSequenceSelection,
                                volumeComments:
                                    appData.myVolumeCommentsSelection,
                                mafiList: appData.myMafiListSelection,
                                directRestows: appData.myDirectRestowSelection,
                                indirectRestows:
                                    appData.myIndirectRestowSelection,
                                stevedoreDrivers:
                                    appData.myStevedoreDriversSelection,
                                stevedorePilots:
                                    appData.myStevedorePilotsSelection,
                                exportLanes: appData.myExportLanesSelection,
                                importLanes: appData.myImportLanesSelection,
                                reverseStowTime:
                                    appData.myReverseStowTimeSelection,
                                secureMainDeck:
                                    appData.mySecureMainDeckSelection,
                                bunkerTime: appData.myBunkerTimeSelection,
                                sideRamp: appData.mySideRampSelection,
                                parallelHeavies: appData.checkboxHeavies,
                                parallelMafis: appData.checkboxMafi,
                                parallelStatics: appData.checkboxStatics,
                                parallelTracks: appData.checkboxTracks,
                                parallelUsed: appData.checkboxUsed,
                                parallelImportNew: appData.checkboxNewImports,
                                parallelExportNew: appData.checkboxNewExports,
                              )
                              : null;

                          setState(() {
                            loading = true;
                          });
                          await DatabaseService(null)
                              .postSharePointData(
                                json.encode(
                                  PrePlanModel(
                                    filesystem:
                                        appData.modulesList
                                            .where(
                                              (element) =>
                                                  element.module ==
                                                  'Vessel Preplan',
                                            )
                                            .first
                                            .fileSystem,
                                    filename:
                                        appData.myVesselNameSelection +
                                        appData.myVoyageNumberSelection,
                                    fileURL: " ",
                                    userEmail: currentUserEmail,
                                    vesselDetails: appData.vesselDetails,
                                    preparationDetails:
                                        appData.preparationDetails,
                                    volumeDetails: appData.volumeDetails,
                                    requirementDetails:
                                        appData.requirementDetails,
                                    transhipmentPreCarrier:
                                        appData.transhipmentPreCarrier,
                                    transhipmentOnCarrier:
                                        appData.transhipmentOnCarrier,
                                  ).toMap(),
                                ),
                                widget.mobiAppData,
                              )
                              .then((value) async {
                                if (!value.startsWith('200')) {
                                  if (!context.mounted) return;
                                  await DialogService(
                                    button: value,
                                    origin: "Error",
                                  ).confirmError(context: context);
                                } else {
                                  await DatabaseService(null).createPrePlan(
                                    appData.myVesselNameSelection,
                                    appData.myVoyageNumberSelection,
                                  );
                                  if (!context.mounted) return;
                                  await DialogService(
                                    button: value,
                                    origin: "Success",
                                  ).confirmError(context: context);
                                }
                              });
                          _resetFormValues();
                          setState(() {
                            loading = false;
                          });

                          await DatabaseService(
                            null,
                          ).transactionListData().then((value) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          });
                        }
                      } catch (error) {
                        if (_isEdit) {
                          if (!context.mounted) return;
                          await DialogService(
                            button:
                                'You are in edit mode please verify that the Volumes and Requirements tabs are correct before saving...',
                            origin: "Error",
                          ).confirmError(context: context);
                        }
                        debugPrint(error.toString());
                      }
                    },
                    backgroundColor: kColorSuccess,
                    elevation: 12,
                    foregroundColor: kColorForeground,
                    splashColor: kColorSuccess,
                    child: const Icon(Icons.save, size: 50),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          ),
        );
  }
}
