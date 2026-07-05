/// Data model for a local Kleinanzeigen listing draft.
///
/// This is a purely local model. No network, no auto-posting, no scraping.
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
  });
}
