// models/user_model.dart
class User {
  final int? id;
  final String soccode;
  final String societyname;
  final String? pandiunit;
  final String? district;
  final String? hq;
  final int uploaded;
  final bool hasImage;
  final String? imagePath;

  User({
    this.id,
    required this.soccode,
    required this.societyname,
    this.pandiunit,
    this.district,
    this.hq,
    this.uploaded = 0,
    this.hasImage = false,
    this.imagePath,
  });

  // Getter for display name (for dropdown)
  String get displayName => '$soccode - $societyname';

  // Getter for name (for compatibility with existing UI)
  String get name => societyname;

  User copyWith({
    int? id,
    String? soccode,
    String? societyname,
    String? pandiunit,
    String? district,
    String? hq,
    int? uploaded,
    bool? hasImage,
    String? imagePath,
  }) {
    return User(
      id: id ?? this.id,
      soccode: soccode ?? this.soccode,
      societyname: societyname ?? this.societyname,
      pandiunit: pandiunit ?? this.pandiunit,
      district: district ?? this.district,
      hq: hq ?? this.hq,
      uploaded: uploaded ?? this.uploaded,
      hasImage: hasImage ?? this.hasImage,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soccode': soccode,
      'societyname': societyname,
      'pandiunit': pandiunit,
      'district': district,
      'hq': hq,
      'uploaded': uploaded,
      'hasImage': hasImage,
      'imagePath': imagePath,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      soccode: json['soccode'] ?? '',
      societyname: json['societyname'] ?? '',
      pandiunit: json['pandiunit'],
      district: json['district'],
      hq: json['hq'],
      uploaded: json['uploaded'] ?? 0,
      hasImage: json['hasImage'] ?? false,
      imagePath: json['imagePath'],
    );
  }

  // Factory constructor for dropdown items
  factory User.fromDropdownJson(Map<String, dynamic> json) {
    return User(
      soccode: json['soccode'] ?? '',
      societyname: json['societyname'] ?? '',
      uploaded: 0,
      hasImage: false,
    );
  }

  @override
  String toString() {
    return 'User(soccode: $soccode, societyname: $societyname, uploaded: $uploaded, hasImage: $hasImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.soccode == soccode;
  }

  @override
  int get hashCode => soccode.hashCode;
}
