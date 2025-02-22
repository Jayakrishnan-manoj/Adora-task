import 'package:adora_location_task/data/location_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  final String tableName = "locations";
  final String locationIdColumnName = "id";
  final String latitudeColumnName = "lat";
  final String longitudeColumnName = "lng";
  final String timeColumnName = "time";

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final String databasePathDir = await getDatabasesPath();
    final String databasePath = join(databasePathDir, "location_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
          $locationIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
          $latitudeColumnName TEXT NOT NULL,
          $longitudeColumnName TEXT NOT NULL,
          $timeColumnName INTEGER NOT NULL
          )
          ''');
      },
    );
    return database;
  }

  void addLocation(Position position, DateTime time) async {
    final String latitude = position.latitude.toString();
    final String longitude = position.longitude.toString();
    final int timeStamp = time.millisecondsSinceEpoch;
    final _db = await database;
    await _db.insert(tableName, {
      latitudeColumnName: latitude,
      longitudeColumnName: longitude,
      timeColumnName: timeStamp,
    });
    print("location added");
  }

  Future<List<LocationData>> getLocation() async {
    final _db = await database;
    final data = await _db.query(tableName);
    print(data);
    List<LocationData> locations =
        data
            .map(
              (element) => LocationData(
                id: element[locationIdColumnName] as int,
                latitude: element[latitudeColumnName] as String,
                longitude: element[longitudeColumnName] as String,
                timeStamp: element[timeColumnName] as int,
              ),
            )
            .toList();
    print(locations);
    return locations;
  }
}
