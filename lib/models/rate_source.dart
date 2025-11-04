enum RateSource {
  manual('Manual Entry'),
  facebook('Facebook Update'),
  api('API Integration');

  const RateSource(this.displayName);

  final String displayName;

  static RateSource fromString(String value) {
    return RateSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => RateSource.manual,
    );
  }
}
