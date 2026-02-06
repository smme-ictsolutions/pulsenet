class MenuList {
  String? header, image, footer;
  bool needsFacilitySelection;

  MenuList({
    required this.header,
    required this.image,
    required this.footer,
    required this.needsFacilitySelection,
  });
}

class Approvals {
  String user;
  List<String> modules;

  Approvals({required this.user, required this.modules});

  Map<String, dynamic> toMap() => {
    "user": user,
    "modules": modules.map((e) => e).toList(growable: true),
  };
}
