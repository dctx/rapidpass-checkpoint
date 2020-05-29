class UsageStats {
  UsageStatsDetail oneDay = UsageStatsDetail();
  UsageStatsDetail oneWeek = UsageStatsDetail();

  UsageStats();

  @override
  toString() {
    return '{ oneDay: ${this.oneDay} , oneWeek: ${this.oneWeek} }';
  }

  int getMidnightTimestamp(int timestamp) {
    const int seconds1Hour = 60 * 60;
    // get timezone offset
    final int timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    // get 12 midnight timestamp in UTC
    int date =
        (timestamp + (seconds1Hour * timeZoneOffset)) ~/ (seconds1Hour * 24);
    // get 12 midnight timestamp in current timezone
    return ((date * (seconds1Hour * 24)) - (seconds1Hour * timeZoneOffset));
  }

  void incrementStats({final int approved, final int denied}) {
    oneDay.scanned += approved + denied;
    oneWeek.scanned += approved + denied;
    oneDay.approved += approved;
    oneWeek.approved += approved;
    oneDay.denied += denied;
    oneWeek.denied += denied;
  }
}

class UsageStatsDetail {
  int scanned;
  int approved;
  int denied;
  int timestamp;

  UsageStatsDetail(
      {this.timestamp = 0,
      this.scanned = 0,
      this.approved = 0,
      this.denied = 0});

  void resetStats() {
    this.scanned = 0;
    this.approved = 0;
    this.denied = 0;
  }

  @override
  toString() {
    return '{ scanned:${this.scanned} , approved: ${this.approved}, denied: ${this.denied} }';
  }
}
