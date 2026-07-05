/// Data model for a local Kleinanzeigen listing draft.
///
/// This is a purely local model. No network, no auto-posting, no scraping.
///
/// Photo attachments are local file paths only — no upload, no EXIF extraction.
class Draft {
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
}
