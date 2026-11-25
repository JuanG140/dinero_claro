import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gasto.dart';

/// Servicio que guarda y lee los gastos en una base de datos SQLite
/// dentro del celular.
///
/// Es un singleton: toda la app usa la misma instancia
/// ([BaseDatos.instancia]), así la base se abre una sola vez.
class BaseDatos {
  BaseDatos._();
  static final BaseDatos instancia = BaseDatos._();

  static const _nombreArchivo = 'dinero_claro.db';
  static const _version = 1;

  Database? _db;

  /// Devuelve la base abierta; la abre la primera vez que se pide.
  Future<Database> get _baseDatos async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(ruta, version: _version, onCreate: _crearTablas);
  }

  /// Se ejecuta solo la primera vez, cuando el archivo de la base no existe.
  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL,
        monto_original REAL NOT NULL,
        moneda TEXT NOT NULL,
        tasa REAL NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  /// Guarda un gasto y lo devuelve con el id que le asignó SQLite.
  Future<Gasto> insertarGasto(Gasto gasto) async {
    final db = await _baseDatos;
    final id = await db.insert('gastos', gasto.toMap());
    return gasto.copyWith(id: id);
  }

  /// Lee todos los gastos, del más reciente al más antiguo.
  Future<List<Gasto>> obtenerGastos() async {
    final db = await _baseDatos;
    final filas = await db.query('gastos', orderBy: 'fecha DESC');
    return filas.map(Gasto.fromMap).toList();
  }

  /// Borra el gasto con ese id.
  Future<void> borrarGasto(int id) async {
    final db = await _baseDatos;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
