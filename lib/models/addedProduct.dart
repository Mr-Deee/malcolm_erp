class addedproduct{
  addedproduct({
    this.name,
    this.farmcode,
    this.cost,
    this.group,
    this.location,
    this.company,
    this.quantity,
    this.image,
    this.description,
  });

  String? name;
  String? farmcode;
  double? cost;
  String? group;
  String? location;
  String? company;
  int? quantity;
  String? image;
  String? description;

  factory addedproduct.fromMap(Map<String, dynamic> json) => addedproduct(
    name: json["ExpenseType"] as String?,
    farmcode: json["FarmCodes"] as String?,
    cost: json["Cost"] as double?,
    group: json["group"] as String?,
    location: json["location"] as String?,
    company: json["Company"] as String?,
    quantity: json["quantity"] as int?,
    image: json["image"] as String?,
    description: json["description"] as String?,
  );

  Map<String, dynamic> toMap() => {
    "ExpenseType": name,
    "farmcodes": farmcode,
    "Cost": cost,
    "group": group,
    "location": location,
    "company": company,
    "quantity": quantity,
    "image": image,
    "description": description,
  };
}
