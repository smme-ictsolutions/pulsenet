import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/user.dart';
import 'package:flutter/material.dart';

class HoverableMarker extends StatefulWidget {
  final MarkerData markerData;
  final List<VesselStatus> vesselStatus;
  const HoverableMarker({
    super.key,
    required this.markerData,
    required this.vesselStatus,
  });

  @override
  State<HoverableMarker> createState() => _HoverableMarkerState();
}

class _HoverableMarkerState extends State<HoverableMarker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.2 : 1.0),
        child:
            _isHovered &&
                    widget.vesselStatus
                        .where(
                          (element) => element.berth == widget.markerData.label,
                        )
                        .isNotEmpty
                ? _vesselProgressIndicator()
                : Text(
                  widget.markerData.label,
                  style:
                      widget.markerData.label.length > 3
                          ? kMapHeaderTextStyle1
                          : kMapHeaderTextStyle,
                ),
      ),
    );
  }

  Widget _vesselProgressIndicator() {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0,
        end:
            (double.parse(
                  widget.vesselStatus
                      .where(
                        (element) => element.berth == widget.markerData.label,
                      )
                      .first
                      .outboundLoadCount,
                ) +
                double.parse(
                  widget.vesselStatus
                      .where(
                        (element) => element.berth == widget.markerData.label,
                      )
                      .first
                      .inboundDischargeCount,
                )) /
            (double.parse(
                  widget.vesselStatus
                      .where(
                        (element) => element.berth == widget.markerData.label,
                      )
                      .first
                      .outboundUnitCount,
                ) +
                double.parse(
                  widget.vesselStatus
                      .where(
                        (element) => element.berth == widget.markerData.label,
                      )
                      .first
                      .inboundUnitCount,
                )),
      ),
      duration: Duration(milliseconds: 10),
      builder:
          (context, value, _) => Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${(value * 100).round().toString()}%',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              CircularProgressIndicator(
                value: value,
                backgroundColor: kColorSuccess,
                color: kColorError,
              ),
            ],
          ),
    );
  }
}
