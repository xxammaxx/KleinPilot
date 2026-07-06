/// Data model for a local Kleinanzeigen listing draft.
///
/// This is a purely local model. No network, no auto-posting, no scraping.
///
/// Photo attachments are local file paths only — no upload, no EXIF extraction.
///
/// Persistence fields (id, createdAt, updatedAt) are optional.
/// A draft without `id` is a new, unsaved draft in memory.
/// A draft with `id` is a saved draft persisted locally via DraftStorage.
class Draft {
  /// Unique local ID. Only set when the draft has been saved.
  String? id;

  /// ISO-8601 timestamp when the draft was first saved.
  String? createdAt;

  /// ISO-8601 timestamp when the draft was last modified/saved.
  String? updatedAt;

  String title;
  String categoryNote;
  String condition;
  String description;
  String defects;
  String includedItems;
  String priceNote;
  String handoverNote;
  String locationNote;

  /// Locally selected photo file paths.
  /// Photos remain on the device. No upload, no EXIF/GPS extraction.
  final List<String> photoPaths;

  Draft({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.title = '',
    this.categoryNote = '',
    this.condition = '',
    this.description = '',
    this.defects = '',
    this.includedItems = '',
    this.priceNote = '',
    this.handoverNote = '',
    this.locationNote = '',
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? [];

  /// Serialize this Draft to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
    'title': title,
    'categoryNote': categoryNote,
    'condition': condition,
    'description': description,
    'defects': defects,
    'includedItems': includedItems,
    'priceNote': priceNote,
    'handoverNote': handoverNote,
    'locationNote': locationNote,
    'photoPaths': photoPaths,
  };

  /// Deserialize a Draft from a JSON-compatible map.
  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      title: json['title'] as String? ?? '',
      categoryNote: json['categoryNote'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      description: json['description'] as String? ?? '',
      defects: json['defects'] as String? ?? '',
      includedItems: json['includedItems'] as String? ?? '',
      priceNote: json['priceNote'] as String? ?? '',
      handoverNote: json['handoverNote'] as String? ?? '',
      locationNote: json['locationNote'] as String? ?? '',
      photoPaths: List<String>.from(json['photoPaths'] as List? ?? []),
    );
  }

  /// Create a copy of this Draft, optionally overriding fields.
  Draft copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? title,
    String? categoryNote,
    String? condition,
    String? description,
    String? defects,
    String? includedItems,
    String? priceNote,
    String? handoverNote,
    String? locationNote,
    List<String>? photoPaths,
  }) {
    return Draft(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      categoryNote: categoryNote ?? this.categoryNote,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      defects: defects ?? this.defects,
      includedItems: includedItems ?? this.includedItems,
      priceNote: priceNote ?? this.priceNote,
      handoverNote: handoverNote ?? this.handoverNote,
      locationNote: locationNote ?? this.locationNote,
      photoPaths: photoPaths ?? List<String>.from(this.photoPaths),
    );
  }
}
