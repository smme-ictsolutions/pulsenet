import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class TranshipmentTab extends StatefulWidget {
  final TabController tabBar;
  final String sector;
  final List<PrePlanModel> preplanDetails;
  final bool isEdit;
  const TranshipmentTab({
    super.key,
    required this.tabBar,
    required this.sector,
    required this.preplanDetails,
    required this.isEdit,
  });
  @override
  State<TranshipmentTab> createState() => _TranshipmentTabState();
}

class _TranshipmentTabState extends State<TranshipmentTab>
    with AutomaticKeepAliveClientMixin<TranshipmentTab> {
  @override
  void initState() {
    appData.transhipmentOnCarrier =
        widget.isEdit ? widget.preplanDetails[0].transhipmentOnCarrier : [];
    appData.transhipmentPreCarrier =
        widget.isEdit ? widget.preplanDetails[0].transhipmentPreCarrier : [];
    super.initState();
  }

  @override
  void didUpdateWidget(TranshipmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        if (oldWidget.isEdit != widget.isEdit && widget.isEdit) {
          appData.transhipmentOnCarrier =
              widget.isEdit
                  ? widget.preplanDetails[0].transhipmentOnCarrier
                  : [];
          appData.transhipmentPreCarrier =
              widget.isEdit
                  ? widget.preplanDetails[0].transhipmentPreCarrier
                  : [];
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor: kColorBackground,
                  elevation: 12,
                  foregroundColor: kColorForeground,
                  splashColor: kColorSuccess,
                  heroTag: 'btn1',
                  child: Icon(Icons.add),
                  onPressed: () async {
                    await DialogService(button: "", origin: "Transhipments")
                        .showTranshipmentDialog(
                          context: context,
                          sector: widget.sector,
                          operationType: "add",
                        )
                        .then((value) {
                          if (value.transhipType ==
                              "PRE-CARRIER (Tranship to be Loaded)") {
                            appData.transhipmentPreCarrier.add(value);
                          } else {
                            appData.transhipmentOnCarrier.add(value);
                          }
                        });

                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'PRE-CARRIER (Tranship to be Loaded)',
                style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
              ),
              DataTable(
                columns: [
                  DataColumn(label: Text('Vessel')),
                  DataColumn(label: Text('New Veh')),
                  DataColumn(label: Text('Heavies')),
                  DataColumn(label: Text('Statics')),
                  DataColumn(label: Text('Used')),
                  DataColumn(label: Text('Berth')),
                ],
                rows:
                    appData.transhipmentPreCarrier
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  e.vesselName,
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.newVehicle.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.heavies.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.statics.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.used.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.berthCode!,
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
              Text(
                'ON-CARRIER (Tranship to be Discharged)',
                style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
              ),
              DataTable(
                columns: [
                  DataColumn(label: Text('Vessel')),
                  DataColumn(label: Text('New Veh')),
                  DataColumn(label: Text('Heavies')),
                  DataColumn(label: Text('Statics')),
                  DataColumn(label: Text('Used')),
                ],
                rows:
                    appData.transhipmentOnCarrier
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  e.vesselName,
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.newVehicle.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.heavies.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.statics.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.used.toString(),
                                  style:
                                      isMobile
                                          ? kSmallestTextStyle
                                          : kLabelTextStyle,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
