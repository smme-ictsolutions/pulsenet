import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/appointments.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewSlotsForm extends StatefulWidget {
  const ViewSlotsForm({
    super.key,
    required this.title,
    required this.mobiAppData,
  });
  final String title;
  final MobiAppData mobiAppData;

  @override
  State<ViewSlotsForm> createState() => _ViewSlotsFormState();
}

class _ViewSlotsFormState extends State<ViewSlotsForm> {
  final _key = GlobalKey<ScaffoldState>();
  List<ZoneRuleSets> _zoneRuleSets = [];
  bool loading = false, _isFiltered = false;
  DateTime _focusedDay = DateTime.now(), _selectedDay = DateTime.now();
  late final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  final TextEditingController _textZone = TextEditingController();
  int _currentZoneIndex = 0;

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(
      Duration(days: DateTime.daysPerWeek - dateTime.weekday),
    );
  }

  List<AvailableSlotsModel> _availableSlots = [];
  var formatter = DateFormat("yy-MMM-dd HHmm");

  Future<void> getAvailableSlots() async {
    try {
      setState(() {
        _isFiltered = false;
        loading = true;
      });

      await MobiApiService()
          .getAvailableSlots(
            widget.mobiAppData,
            appData.activeNavisUser.facility!,
          )
          .then((value) async {
            if (value.isNotEmpty) {
              _zoneRuleSets = await DatabaseService(null).getZoneRuleSets(
                appData.navisFacilitiesList
                    .where(
                      (element) =>
                          element.filter == appData.activeNavisUser.facility!,
                    )
                    .first
                    .code!,
              );
            }
            _availableSlots = value;
          });

      _availableSlots.isEmpty
          ? setState(() {
            loading = false;
          })
          : setState(() {
            loading = false;
            _textZone.text =
                filteredBySelectedDate(
                  _selectedDay,
                  true,
                )[_currentZoneIndex].zoneRule;
          });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
        _availableSlots.clear();
      });
    }
  }

  @override
  void initState() {
    initializeDateFormatting();
    appData.activeNavisUser.facility != null ? getAvailableSlots() : null;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kColorNavIcon,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                icon: const Icon(size: 30, Icons.home, color: kColorBackground),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(widget.title, style: kHeaderLabelTextStyle),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      imageData
                          .where((element) => element.title == 'TPTLogo')
                          .first
                          .url,
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        extendBody: true,
        backgroundColor: kColorNavIcon,
        key: _key,
        resizeToAvoidBottomInset: false,
        body:
            loading
                ? const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: kColorBar),
                )
                : Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: appData.activeNavisUser.facility,
                            validator:
                                (val) =>
                                    val == null ? 'Facility is required' : null,
                            style: kTextStyle,
                            iconSize: 24,
                            iconEnabledColor: kColorBar,
                            iconDisabledColor: kColorNavIcon,
                            items:
                                appData.navisFacilitiesList
                                    .map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.filter,
                                        child: Text(item.port!),
                                      );
                                    })
                                    .toList(),
                            onChanged: (String? newValue) async {
                              try {
                                setState(() {
                                  _isFiltered = false;
                                  loading = true;
                                });
                                if (newValue != null) {
                                  appData.activeNavisUser.facility != newValue
                                      ? appData
                                          .activeNavisUser = NavisSubscribeData(
                                        username: null,
                                        password: null,
                                        facility: newValue,
                                        connected: false,
                                      )
                                      : null;
                                  await MobiApiService()
                                      .getAvailableSlots(
                                        widget.mobiAppData,
                                        appData.activeNavisUser.facility!,
                                      )
                                      .then((value) async {
                                        if (value.isNotEmpty) {
                                          _zoneRuleSets = await DatabaseService(
                                            null,
                                          ).getZoneRuleSets(
                                            appData.navisFacilitiesList
                                                .where(
                                                  (element) =>
                                                      element.filter ==
                                                      newValue,
                                                )
                                                .first
                                                .code!,
                                          );
                                        }
                                        _availableSlots = value;
                                      });
                                }
                                _availableSlots.isEmpty
                                    ? setState(() {
                                      loading = false;
                                    })
                                    : setState(() {
                                      loading = false;
                                      _textZone.text =
                                          filteredBySelectedDate(
                                            _selectedDay,
                                            true,
                                          )[_currentZoneIndex].zoneRule;
                                    });
                              } catch (e) {
                                debugPrint(e.toString());
                                setState(() {
                                  loading = false;
                                  _availableSlots.clear();
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Tap to select facility",
                              hintStyle: kLabelTextStyle,
                              filled: true,
                              fillColor: kColorNavIcon.withValues(alpha: 0.4),
                              focusColor: kColorForeground,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              prefixIcon: const Icon(
                                Icons.place,
                                color: kColorSplash,
                              ),
                            ),
                          ),
                        ),
                        _availableSlots.isEmpty
                            ? Container()
                            : Expanded(
                              flex: 0,
                              child: IconButton(
                                color: _isFiltered ? kColorSuccess : kColorBar,
                                icon: Icon(
                                  _isFiltered
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isFiltered = !_isFiltered;
                                  });
                                  if (_isFiltered) {
                                    await DialogService(
                                          origin: "Zone Filter",
                                          button: 'done',
                                        )
                                        .showZoneFilter(
                                          context: context,
                                          availableSlots:
                                              filteredBySelectedDate(
                                                _selectedDay,
                                                false,
                                              ),
                                        )
                                        .then((value) {
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              _availableSlots = value;
                                              _textZone.text =
                                                  filteredBySelectedDate(
                                                    _selectedDay,
                                                    false,
                                                  )[_currentZoneIndex].zoneRule;
                                            });
                                          } else {
                                            setState(() {
                                              _isFiltered = !_isFiltered;
                                            });
                                          }
                                        });
                                  } else {
                                    setState(() {
                                      loading = true;
                                    });

                                    await MobiApiService()
                                        .getAvailableSlots(
                                          widget.mobiAppData,
                                          appData.activeNavisUser.facility!,
                                        )
                                        .then((value) {
                                          _availableSlots = value;
                                        });

                                    setState(() {
                                      loading = false;
                                      _textZone.text =
                                          filteredBySelectedDate(
                                            _selectedDay,
                                            true,
                                          )[_currentZoneIndex].zoneRule;
                                    });
                                  }
                                },
                              ),
                            ),
                      ],
                    ),
                    appData.activeNavisUser.facility == null
                        ? Container()
                        : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCalendar(
                            daysOfWeekHeight: 20,
                            selectedDayPredicate:
                                (day) => isSameDay(day, _selectedDay),
                            firstDay: findFirstDateOfTheWeek(DateTime.now()),
                            lastDay: findLastDateOfTheWeek(DateTime.now()),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            weekendDays: const [
                              DateTime.saturday,
                              DateTime.sunday,
                            ],
                            onDaySelected: (selectedDay, focusedDay) {
                              //check if selected day is in available slots
                              _availableSlots
                                      .where(
                                        (selectedDate) =>
                                            selectedDate.transactionDate ==
                                            formatter.format(selectedDay),
                                      )
                                      .isNotEmpty
                                  ? _textZone.text =
                                      filteredBySelectedDate(
                                        selectedDay,
                                        true,
                                      ).first.zoneRule
                                  : null;
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                _currentZoneIndex = 0;
                              });
                            },
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                // dont allow format change
                              }
                            },
                            headerStyle: HeaderStyle(
                              formatButtonShowsNext: false,
                              decoration: const BoxDecoration(
                                color: kColorSuccess,
                              ),
                              headerMargin: const EdgeInsets.only(bottom: 8.0),
                              titleTextStyle: const TextStyle(color: kColorBar),
                              formatButtonDecoration: BoxDecoration(
                                border: Border.all(color: kColorBar),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              formatButtonTextStyle: const TextStyle(
                                color: kColorBar,
                              ),
                              leftChevronIcon: Container(),
                              rightChevronIcon: Container(),
                            ),
                            calendarStyle: CalendarStyle(
                              isTodayHighlighted: true,
                              selectedDecoration: BoxDecoration(
                                color: kColorSplash,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              selectedTextStyle: const TextStyle(
                                color: kColorBar,
                              ),
                              todayDecoration: BoxDecoration(
                                color: kColorText,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              defaultDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              weekendDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              withinRangeDecoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              holidayDecoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              outsideDecoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              markersAlignment: Alignment.bottomRight,
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder:
                                  (context, day, slots) =>
                                      _availableSlots
                                              .where(
                                                (element) =>
                                                    element.transactionDate ==
                                                    formatter.format(day),
                                              )
                                              .isNotEmpty
                                          ? _buildSlotsAvailableMarker(
                                            day,
                                            _availableSlots
                                                .where(
                                                  (element) =>
                                                      element.transactionDate ==
                                                      formatter.format(day),
                                                )
                                                .toList(),
                                          )
                                          : Container(
                                            width: 16,
                                            height: 16,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.no_transfer,
                                              size: 16,
                                            ),
                                          ),
                            ),
                          ),
                        ),
                    appData.activeNavisUser.facility == null
                        ? Container()
                        : const Divider(indent: 8, endIndent: 8, thickness: 2),
                    appData.activeNavisUser.facility == null
                        ? Container()
                        : Expanded(
                          flex: 0,
                          child: Card(
                            color: Colors.black.withValues(alpha: .7),
                            child:
                                filteredBySelectedDate(
                                      _selectedDay,
                                      false,
                                    ).isNotEmpty
                                    ? Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            controller: _textZone,
                                            textAlign: TextAlign.center,
                                            style: kLabelTextStyle,
                                            showCursor: false,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              prefixIconColor:
                                                  _currentZoneIndex == 0
                                                      ? kColorText
                                                      : kColorBar,
                                              suffixIconColor:
                                                  _currentZoneIndex ==
                                                          filteredBySelectedDate(
                                                                _selectedDay,
                                                                true,
                                                              ).length -
                                                              1
                                                      ? kColorText
                                                      : kColorBar,
                                              prefixIcon: InkWell(
                                                onTap: () {
                                                  _currentZoneIndex == 0
                                                      ? null
                                                      : setState(() {
                                                        _currentZoneIndex =
                                                            _currentZoneIndex -
                                                            1;
                                                        _textZone.text =
                                                            filteredBySelectedDate(
                                                                  _selectedDay,
                                                                  true,
                                                                )[_currentZoneIndex]
                                                                .zoneRule;
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.keyboard_arrow_left,
                                                  size: 40,
                                                ),
                                              ),
                                              suffixIcon: InkWell(
                                                onTap: () {
                                                  _currentZoneIndex ==
                                                          filteredBySelectedDate(
                                                                _selectedDay,
                                                                true,
                                                              ).length -
                                                              1
                                                      ? null
                                                      : setState(() {
                                                        _currentZoneIndex =
                                                            _currentZoneIndex +
                                                            1;
                                                        _textZone.text =
                                                            filteredBySelectedDate(
                                                                  _selectedDay,
                                                                  true,
                                                                )[_currentZoneIndex]
                                                                .zoneRule;
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.keyboard_arrow_right,
                                                  size: 40,
                                                ),
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(),
                          ),
                        ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .5,
                            width: MediaQuery.of(context).size.width,
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount:
                                  filteredBySelectedDate(_selectedDay, false)
                                      .where(
                                        (element) =>
                                            element.zoneRule == _textZone.text,
                                      )
                                      .length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 5.0,
                                  ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    /*
                                  /*//construct selected datetime based on selected tile
                                  var selectedTime = _formatSlotTime(
                                      filteredBySelectedDate(
                                              _selectedDay, false)
                                          .where((element) =>
                                              element.zoneRule ==
                                              _textZone.text)
                                          .toList()[index]);
                                  DateTime selectedDateTimeSlot = DateTime(
                                      _selectedDay.year,
                                      _selectedDay.month,
                                      _selectedDay.day,
                                      int.parse(selectedTime.substring(
                                          0, selectedTime.indexOf(':'))));
                                  if (selectedDateTimeSlot
                                      .isBefore(DateTime.now())) {
                                    DialogService(
                                            button: 'dismiss',
                                            origin:
                                                'Oops looks like you selected an expired slot.')
                                        .showSnackBar(context: context);
                                    return;
                                  } else*/
                                  if (filteredBySelectedDate(
                                              _selectedDay, false)
                                          .where((element) =>
                                              element.zoneRule ==
                                              _textZone.text)
                                          .toList()[index]
                                          .availableSlots ==
                                      0) {
                                    DialogService(
                                            button: 'dismiss',
                                            origin:
                                                'Oops looks like you selected a slot with no available slots.')
                                        .showSnackBar(context: context);
                                    return;
                                  }
                                  String transactionTypeCode = "";
                                  String selectedGate = "";
                                  for (var zoneRule in _zoneRuleSets) {
                                    if (zoneRule.zoneRules!
                                        .where((element) =>
                                            element == _textZone.text)
                                        .isNotEmpty) {
                                      selectedGate = zoneRule.gateID!;
                                      filteredBySelectedDate(_selectedDay, false)
                                                      .where((element) =>
                                                          element.zoneRule ==
                                                          _textZone.text)
                                                      .toList()[index]
                                                      .transactionType ==
                                                  'Deliver Full' &&
                                              selectedGate.contains('IFT')
                                          ? transactionTypeCode = 'DE'
                                          : filteredBySelectedDate(_selectedDay, false)
                                                          .where((element) =>
                                                              element.zoneRule ==
                                                              _textZone.text)
                                                          .toList()[index]
                                                          .transactionType ==
                                                      'Deliver Full' &&
                                                  !selectedGate.contains('IFT')
                                              ? transactionTypeCode = 'DI'
                                              : filteredBySelectedDate(_selectedDay, false).where((element) => element.zoneRule == _textZone.text).toList()[index].transactionType == 'Receive Full' &&
                                                      selectedGate
                                                          .contains('IFT')
                                                  ? transactionTypeCode = 'RI'
                                                  : filteredBySelectedDate(_selectedDay, false)
                                                                  .where((element) => element.zoneRule == _textZone.text)
                                                                  .toList()[index]
                                                                  .transactionType ==
                                                              'Receive Full' &&
                                                          !selectedGate.contains('IFT')
                                                      ? transactionTypeCode = 'RE'
                                                      : filteredBySelectedDate(_selectedDay, false).where((element) => element.zoneRule == _textZone.text).toList()[index].transactionType == 'Receive Empty'
                                                          ? transactionTypeCode = 'RM'
                                                          : null;
                                    }
                                  }
                                  if (transactionTypeCode != "" &&
                                      selectedGate != "") {
                                    await showDialog(
                                        context: context,
                                        builder: (_) {
                                          return MyDialog(
                                            imageData: imageData,
                                            title: "Create Truck Appointment",
                                            mobiAppData: widget.mobiAppData,
                                            selectedItem:
                                                filteredBySelectedDate(
                                                        _selectedDay, false)
                                                    .where((element) =>
                                                        element.zoneRule ==
                                                        _textZone.text)
                                                    .toList()[index],
                                            selectedZone: _textZone.text,
                                            gateID: selectedGate,
                                            transactionTypeCode:
                                                transactionTypeCode,
                                            appointmentDate:
                                                DateFormat('yyyy-MM-dd')
                                                    .format(_selectedDay),
                                            appointmentTime: _formatSlotTime(
                                                filteredBySelectedDate(
                                                        _selectedDay, false)
                                                    .where((element) =>
                                                        element.zoneRule ==
                                                        _textZone.text)
                                                    .toList()[index]),
                                            selectedDate: _selectedDay,
                                          );
                                        }).then((value) async {
                                      setState(() {
                                        loading = true;
                                      });
                                      await MobiApiService()
                                          .getAvailableSlots(widget.mobiAppData,
                                              appData.activeNavisUser.facility!)
                                          .then(
                                        (value) async {
                                          if (value.isNotEmpty) {
                                            _zoneRuleSets =
                                                await DatabaseService(null)
                                                    .getZoneRuleSets(appData
                                                        .navisFacilitiesList
                                                        .where((element) =>
                                                            element.filter ==
                                                            appData
                                                                .activeNavisUser
                                                                .facility!)
                                                        .first
                                                        .code!);
                                          }
                                          _availableSlots = value;
                                        },
                                      );
                                      _availableSlots.isEmpty
                                          ? setState(() {
                                              loading = false;
                                            })
                                          : setState(() {
                                              loading = false;
                                              _textZone.text =
                                                  filteredBySelectedDate(
                                                              _selectedDay,
                                                              true)[
                                                          _currentZoneIndex]
                                                      .zoneRule;
                                            });
                                    });
                                  } else {
                                    //no appointments to show
                                    DialogService(
                                            button: 'Dismiss',
                                            origin:
                                                'Oops, looks like I cannot locate the correct transaction type or gate to complete your appointment.')
                                        .showSnackBar(context: context);
                                  }
                                */
                                  },
                                  child: _cardAvailableSlots(
                                    context,
                                    filteredBySelectedDate(_selectedDay, false)
                                        .where(
                                          (element) =>
                                              element.zoneRule ==
                                              _textZone.text,
                                        )
                                        .toList(),
                                    index,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildSlotsAvailableMarker(
    DateTime day,
    List<AvailableSlotsModel> availableSlots,
  ) {
    int totalAvailableSlots = 0;
    for (var slot in availableSlots) {
      if (slot.transactionDate == formatter.format(day)) {
        totalAvailableSlots = totalAvailableSlots + slot.availableSlots!;
      }
    }
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: kColorSuccess),
      child: Text('$totalAvailableSlots', style: kMarkerTextStyle),
    );
  }

  String _formatSlotTime(AvailableSlotsModel selectedItem) {
    String selectedTime = selectedItem.startTime.substring(
      selectedItem.startTime.indexOf(" ") + 1,
    );
    selectedTime =
        "${selectedTime.substring(0, 2)}:${selectedTime.substring(2, selectedTime.length)}:00";
    return selectedTime;
    // return selectedItem.startTime
    //     .substring(selectedItem.startTime.indexOf(" ") + 1)
    //     .replaceAll('00', ':00:00');
  }

  Widget _cardAvailableSlots(
    BuildContext context,
    List<AvailableSlotsModel> selectedItem,
    int index,
  ) {
    const Color background = kColorSuccess;
    const Color fill = kColorSplash;
    final List<Color> gradient = [background, background, fill, fill];
    try {
      double fillPercent =
          (selectedItem[index].slotsBooked! /
              selectedItem[index].slotCapacity!) *
          100; // fills % for container from bottom
      double fillStop = (100 - fillPercent) / 100;
      final List<double> stops = [0.0, fillStop, fillStop, 1.0];

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: kColorBar),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradient,
            stops: stops,
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),
          boxShadow: const [
            BoxShadow(
              color: kColorBar,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: GridTile(
          header: Column(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    selectedItem[index].transactionType,
                    style: kLabelTextStyle,
                  ),
                ),
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '${selectedItem[index].startTime.substring(selectedItem[index].startTime.indexOf(" ") + 1)} to ${selectedItem[index].endTime.substring(selectedItem[index].endTime.indexOf(" ") + 1)}',
                    style: kLabelTextStyle,
                  ),
                ),
              ),
            ],
          ),
          footer: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //slots booked greater than slots capacity and capacity is not 0
                  selectedItem[index].slotsBooked! >
                              selectedItem[index].slotCapacity! &&
                          selectedItem[index].slotCapacity! > 0
                      ? Text(
                        '${(selectedItem[index].slotCapacity!)} used',
                        style: kMarkerTextStyle,
                      )
                      : selectedItem[index].slotsBooked! > 0 &&
                          selectedItem[index].slotCapacity! ==
                              0 //slots booked but capacity was reset to 0
                      ? const Text('0 used', style: kMarkerTextStyle)
                      : Text(
                        '${(selectedItem[index].slotsBooked!)} used',
                        style: kMarkerTextStyle,
                      ),
                  //slots booked greater than slots capacity and capacity is not 0
                  selectedItem[index].slotsBooked! >
                              selectedItem[index].slotCapacity! &&
                          selectedItem[index].slotCapacity! > 0
                      ? Text(
                        ' ${((selectedItem[index].slotCapacity! / selectedItem[index].slotCapacity!) * 100).round()}%',
                        style: kHeaderLabelTextStyle,
                      )
                      : selectedItem[index].slotsBooked! > 0 &&
                          selectedItem[index].slotCapacity! == 0
                      ? //slots booked but capacity was reset to 0
                      const Text('100 %', style: kMarkerTextStyle)
                      : Text(
                        ' ${((selectedItem[index].slotsBooked! / selectedItem[index].slotCapacity!) * 100).round()}%',
                        style: kHeaderLabelTextStyle,
                      ),
                ],
              ),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedItem[index].availableSlots.toString(),
                  style: kDescriptionTextStyle,
                ),
                const Text(" unused", style: kMarkerTextStyle),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      return Container();
    }
  }

  List<AvailableSlotsModel> filteredBySelectedDate(
    DateTime selectedDate,
    bool isLookup,
  ) {
    var seen = <String>{};
    try {
      if (!isLookup) {
        return _availableSlots
            .where(
              (element) =>
                  element.transactionDate ==
                  DateFormat("yy-MMM-dd 0000").format(selectedDate),
            )
            .toList();
      } else {
        return _availableSlots
            .where(
              (element) =>
                  element.transactionDate ==
                  DateFormat("yy-MMM-dd 0000").format(selectedDate),
            )
            .toList()
            .where((element) => seen.add(element.zoneRule))
            .toList();
      }
    } catch (error) {
      debugPrint(error.toString());
    }
    return _availableSlots;
  }
}
