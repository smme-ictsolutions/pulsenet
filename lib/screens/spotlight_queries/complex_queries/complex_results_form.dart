import 'dart:async';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class ComplexResultsForm extends StatefulWidget {
  const ComplexResultsForm({
    super.key,
    required this.mobiAppData,
    required this.vnlValidUnitIds,
    required this.flexibleQueryData,
    required this.vnlFacility,
    required this.onResults,
  });
  final MobiAppData mobiAppData;
  final List<FlexibleQueryData> vnlValidUnitIds;
  final List<FlexibleQueryData> flexibleQueryData;
  final String vnlFacility;
  final ValueChanged<List<FlexibleTrackandTraceModel>> onResults;
  @override
  State<ComplexResultsForm> createState() => _ComplexResultsFormState();
}

class _ComplexResultsFormState extends State<ComplexResultsForm> {
  late StreamSubscription _subscription;
  final List<FlexibleTrackandTraceModel> _trackTraceItems = [];
  bool _queryOptionsError = false;
  int _currentTrackTraceItem = 0;

  @override
  void initState() {
    _subscription = MobiApiService()
        .getFlexibleTrackandTrace(
          widget.mobiAppData,
          widget.vnlValidUnitIds,
          widget.vnlFacility,
        )
        .listen(
          (data) async {
            if (!mounted) return;
            setState(() {
              _trackTraceItems.addAll(data);
              _currentTrackTraceItem++;
              widget.onResults(_trackTraceItems);
              _queryOptionsError = false;
            });
          },
          onDone: () {
            debugPrint('_getTrackTraceData stream completed');
          },
          onError: (e) {
            debugPrint('Error in _fetch track trace data: $e');
            if (!mounted) return;
            setState(() {
              _queryOptionsError = true;
            });
          },
        );
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (_currentTrackTraceItem < widget.vnlValidUnitIds.length &&
                widget.vnlValidUnitIds.isNotEmpty &&
                (_currentTrackTraceItem) / (widget.vnlValidUnitIds.length) < 1)
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _subscription.cancel();
                    setState(() {
                      _currentTrackTraceItem = widget.vnlValidUnitIds.length;
                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    child: LinearProgressIndicator(
                      minHeight: 20,
                      color: Colors.red,
                      value:
                          ((_currentTrackTraceItem) /
                              (widget.vnlValidUnitIds.length)),
                    ),
                  ),
                ),
              ],
            )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child:
              _queryOptionsError
                  ? Text('Error loading query options')
                  : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: kColorSuccess, width: 2.0),
                    ),
                    height: MediaQuery.of(context).size.height * .40,
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 5,
                          ),
                      itemCount: widget.vnlValidUnitIds.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation:
                              5.0, // Controls the "raised" effect (shadow depth)
                          child: GridTile(
                            header: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.vnlValidUnitIds[index].unitIds
                                        .trim(),
                                  ),
                                  const Icon(Icons.check, color: kColorSuccess),
                                ],
                              ),
                            ),
                            footer: Align(
                              alignment: Alignment.center,
                              child: Text(
                                textAlign: TextAlign.start,
                                widget.flexibleQueryData
                                    .firstWhere(
                                      (element) =>
                                          element.unitIds ==
                                          widget.vnlValidUnitIds[index].unitIds
                                              .trim(),
                                    )
                                    .filter,
                                style: kSmallestTextStyle1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: kColorSuccess,
                                    ),
                                    onPressed: () async {
                                      await DialogService(
                                        origin:
                                            '${widget.flexibleQueryData.firstWhere((element) => element.unitIds == widget.vnlValidUnitIds[index].unitIds.trim()).filter} query results',
                                        button: 'dismiss',
                                      ).showFlexibleQueryResults(
                                        context: context,
                                        trackTraceItems:
                                            _trackTraceItems
                                                .where(
                                                  (element) =>
                                                      element.unitNumber ==
                                                      widget
                                                          .vnlValidUnitIds[index]
                                                          .unitIds
                                                          .trim(),
                                                )
                                                .first,
                                        mobiAppData: widget.mobiAppData,
                                        imageData: imageData,
                                      );
                                    },
                                    child:
                                        _trackTraceItems
                                                .where(
                                                  (element) =>
                                                      element.unitNumber ==
                                                      widget
                                                          .vnlValidUnitIds[index]
                                                          .unitIds
                                                          .trim(),
                                                )
                                                .toList()
                                                .isNotEmpty
                                            ? Text(
                                              'Status: ${_trackTraceItems.firstWhere((element) => element.unitNumber == widget.vnlValidUnitIds[index].unitIds.trim()).tState}',

                                              style: kMarkerTextStyle1,
                                            )
                                            : CircularProgressIndicator(
                                              color: kColorError,
                                              constraints: BoxConstraints(
                                                minHeight: 15,
                                                minWidth: 15,
                                                maxHeight: 15,
                                                maxWidth: 15,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
