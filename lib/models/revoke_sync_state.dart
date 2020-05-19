import 'package:flutter/foundation.dart';
import 'package:rapidpass_checkpoint/data/app_database.dart';

class RevokeSyncState {
  int since;
  final int pageSize;
  int totalPages = 0;
  int totalRows = 0;
  int pageNumber = 0;
  int insertedRowsCount = 0;
  String statusMessage;
  Exception exception;
  List<RevokePassesCompanion> passesForInsert = List();
  RevokeSyncState({@required this.since, this.pageSize = 1000});

  @override
  String toString() {
    return 'RevokeSyncState(since: $since, '
        'pageSize: $pageSize, '
        'totalPages: $totalPages, '
        'totalRows: $totalRows, '
        'pageNumber: $pageNumber, '
        'insertedRowsCount: $insertedRowsCount)';
  }
}
