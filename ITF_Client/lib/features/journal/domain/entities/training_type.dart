enum TrainingType {
  pattern,
  sparring,
  kicks,
  punches,
  fitness,
  other;

  String get i18nKey => 'journal.type.$name';
}
