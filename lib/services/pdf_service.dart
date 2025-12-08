import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../models/model.dart';

Future<File?> generarPdfBitacora(
    Bitacora bitacora, 
    List<ChecklistItem> checklist,
    Firma firma) async {
  if (kIsWeb) {
    return null;
  }

  final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
  final dejavuFont = pw.Font.ttf(fontData);

  final pdf = pw.Document();

  // Formato de fecha dd/mm/yyyy
  final fechaFormatted = DateFormat('dd/MM/yyyy').format(bitacora.fecha);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text('Bitácora',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold))
            ),

            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                fechaFormatted,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            // Cabecera
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Equipo
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Equipo:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(bitacora.equipo,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                pw.SizedBox(width: 12),

                // Area
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Área:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(bitacora.area,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                // Línea
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Sub-área / Línea:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(bitacora.linea,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                // Tipo_limpieza
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tipo de Limpieza:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(bitacora.tipoLimpieza,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                // Tipo_limpieza
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Frecuencua:',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(bitacora.frecuencia,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),

                
              ],
            ),
            pw.SizedBox(height: 16),
            buildChecklistTable(checklist, dejavuFont),
            pw.SizedBox(height: 16),
            buildThreeSignaturesSection(firma),
          ],
        );
      },
    ),
  );

  final bytes = await pdf.save();
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/bitacora_${bitacora.id}.pdf');
  await file.writeAsBytes(bytes);
  return file;
}

pw.Widget buildChecklistTable(List<ChecklistItem> items, pw.Font dejavuFont) {
  final sorted = [...items]..sort((a, b) => a.orden!.compareTo(b.orden!));

  // Encabezado de la tabla
  final header = pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
            flex: 0,
            child: pw.Container(
                width: 40,
                child: pw.Text('Estado',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center))),
        pw.SizedBox(width: 8),
        pw.Expanded(
            flex: 5,
            child: pw.Text('Elemento',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(width: 8),
        pw.Expanded(
            flex: 3,
            child: pw.Text('Observación',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold))),
      ],
    ),
  );

  // Construir filas dinámicamente
  final rows = <pw.TableRow>[];

  // Agregar encabezado como primera fila (puedes preferir dejarlo fuera y ponerlo separado)
  rows.add(pw.TableRow(children: [
    // Estado (encabezado ya mostrado en container arriba si no quieres repetir, aquí va vacío)
    pw.Padding(
        padding: const pw.EdgeInsets.all(0), child: pw.SizedBox(height: 0)),
    pw.Padding(
        padding: const pw.EdgeInsets.all(0), child: pw.SizedBox(height: 0)),
    pw.Padding(
        padding: const pw.EdgeInsets.all(0), child: pw.SizedBox(height: 0)),
  ]));

  for (final it in sorted) {
    final dynamic value = it.checked;
    late final bool checkedBool;

    if (value is int) {
      checkedBool = value == 1;
    } else if (value is bool) {
      checkedBool = value;
    } else {
      checkedBool = false;
    }

    final String symbol = checkedBool ? '√' : 'X';
    final PdfColor symbolColor =
        checkedBool ? PdfColors.green800 : PdfColors.red800;

    final tituloText = it.titulo.trim();
    final observacionText =
        (it.observacion != null && it.observacion!.trim().isNotEmpty)
            ? it.observacion!.trim()
            : '-';

    rows.add(
      pw.TableRow(
        decoration: const pw
            .BoxDecoration(), // puedes alternar color por fila si quieres
        children: [
          // Columna Estado
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                symbol,
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [dejavuFont],
                    color: symbolColor),
              ),
            ),
          ),

          // Columna Titulo (Elemento)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                tituloText,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          ),

          // Columna Observacion
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                observacionText,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tabla con anchos controlados: usamos columnWidths y colocamos el header separado arriba
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Encabezado visible
      header,
      pw.SizedBox(height: 4),
      pw.Table(
        columnWidths: const {
          0: pw.FixedColumnWidth(40), // estado estrecho
          1: pw.FlexColumnWidth(5), // titulo
          2: pw.FlexColumnWidth(3), // observacion
        },
        children: rows,
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(width: 0.2, color: PdfColors.grey300),
        ),
      ),
    ],
  );
}


pw.Widget buildThreeSignaturesSection(Firma firma) {
  
  final pw.ImageProvider? ejecutoImage = (firma.firmaEjecuto != null && firma.firmaEjecuto!.isNotEmpty)
    ? pw.MemoryImage(base64Decode(firma.firmaEjecuto!))
    : null;
  final pw.ImageProvider? verificoImage = (firma.firmaVerifico != null && firma.firmaVerifico!.isNotEmpty)
    ? pw.MemoryImage(base64Decode(firma.firmaVerifico!))
    : null;
  final pw.ImageProvider? liberoImage = (firma.firmaLibero != null && firma.firmaLibero!.isNotEmpty)
    ? pw.MemoryImage(base64Decode(firma.firmaLibero!))
    : null; 
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.SizedBox(height: 24),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Firma 1
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey400,
                      width: 0.8,
                    ),
                  ),
                  child: ejecutoImage != null
                    ? pw.Center(child: pw.Image(ejecutoImage, fit: pw.BoxFit.contain))
                    : pw.Center(
                        child: pw.Text(
                          'Firma 1',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                ),
                pw.SizedBox(height: 6),
                // Línea para el nombre
                pw.Container(
                  height: 0.5,
                  color: PdfColors.black,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  firma.ejecuto ?? 'Nombre 1',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),

          pw.SizedBox(width: 12),

          // Firma 2
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey400,
                      width: 0.8,
                    ),
                  ),
                  child: verificoImage != null
                    ? pw.Center(child: pw.Image(verificoImage, fit: pw.BoxFit.contain))
                    : pw.Center(
                        child: pw.Text(
                          'Firma 1',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  height: 0.5,
                  color: PdfColors.black,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  firma.verifico ?? 'Nombre 2',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),

          pw.SizedBox(width: 12),

          // Firma 3
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey400,
                      width: 0.8,
                    ),
                  ),
                  child: liberoImage != null
                    ? pw.Center(child: pw.Image(liberoImage, fit: pw.BoxFit.contain))
                    : pw.Center(
                        child: pw.Text(
                          'Firma 1',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  height: 0.5,
                  color: PdfColors.black,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  firma.libero ?? 'Nombre 3',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}