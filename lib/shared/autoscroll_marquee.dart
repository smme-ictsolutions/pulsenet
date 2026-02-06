import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:flutter/material.dart';

class AutoScrollMarquee extends StatefulWidget {
  final double height;
  final List items;
  final List<ImageData> imageData;

  const AutoScrollMarquee({
    super.key,
    this.height = 30.0,
    required this.items,
    required this.imageData,
  });
  @override
  State<StatefulWidget> createState() => _AutoScrollMarqueeState();
}

class _AutoScrollMarqueeState extends State<AutoScrollMarquee>
    with SingleTickerProviderStateMixin {
  ScrollController scrollCtrl = ScrollController();
  late AnimationController animateCtrl;

  @override
  void dispose() {
    animateCtrl.dispose();
    super.dispose();
  }

  @override
  initState() {
    double offset = 0.0;
    super.initState();
    animateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..addListener(() {
      if (animateCtrl.isCompleted) animateCtrl.repeat();
      offset += 0.6;
      if (offset - 1 > scrollCtrl.offset) {
        offset = 0.0;
      }
      setState(() {
        scrollCtrl.jumpTo(offset);
      });
    });
    animateCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width - 20,
          child: ListView.builder(
            itemCount: widget.items.first.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: TextFormField(
                            readOnly: true,
                            initialValue: widget.items[0][index].cityName,
                            style: kSubTitleTextStyle,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            initialValue:
                                '${widget.items[0][index].temperature.toStringAsFixed(0)}\u2103',
                            style: kLabelTextStyle,
                          ),
                        ),
                        Expanded(
                          child: CachedNetworkImage(
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                            imageUrl:
                                "${appData.apiWeatherIcon}${widget.items[0][index].icon}.png",
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  width: 10,
                                  height: 40,
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
                        Expanded(
                          child: CachedNetworkImage(
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                            imageUrl:
                                widget.imageData
                                    .where(
                                      (element) => element.title == 'windsock',
                                    )
                                    .first
                                    .url,
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  width: 10,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.topRight,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                ' ${widget.items[0][index].windSpeed.toStringAsFixed(0)} km/h',
                            style: kLabelTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            controller: scrollCtrl,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
