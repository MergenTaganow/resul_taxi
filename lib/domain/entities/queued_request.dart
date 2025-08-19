class QueuedRequest {
  final int requestId;
  final double priceTotal;
  final List<Map<String, dynamic>> roadDetails;

  QueuedRequest({
    required this.requestId,
    required this.priceTotal,
    required this.roadDetails,
  });

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'price_total': priceTotal,
    'road_details': roadDetails,
  };

  static QueuedRequest fromJson(Map<String, dynamic> json) => QueuedRequest(
    requestId: json['request_id'],
    priceTotal: json['price_total'],
    roadDetails: List<Map<String, dynamic>>.from(json['road_details']),
  );
}