class StoreItem {
  final String id;
  final String image;
  final String twd;
  final String ticket;

  StoreItem({
    required this.id,
    required this.image,
    required this.twd,
    required this.ticket,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['top_up_id'],
      image: json['top_up_image'],
      twd: json['TWD'],
      ticket: json['ticket'],
    );
  }
}
