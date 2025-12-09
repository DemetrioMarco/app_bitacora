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
    Bitacora bitacora, List<ChecklistItem> checklist, Firma firma) async {
  if (kIsWeb) {
    return null;
  }

  final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
  final dejavuFont = pw.Font.ttf(fontData);

  final pdf = pw.Document();
  final headerRow = buildTableHeader();

  // Formato de fecha dd/mm/yyyy
  final fechaFormatted = DateFormat('dd/MM/yyyy').format(bitacora.fecha);

 // Reemplaza la creación de la página por MultiPage con header repetido
pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(24),
    // Este header se repetirá en cada página generada
    header: (pw.Context context) {
      return (context.pageNumber == 1) ? pw.SizedBox() : headerRow;
          },
    build: (pw.Context context) => [
      // Tu título y fecha
      pw.Container(
        alignment: pw.Alignment.center,
        child: pw.Text('Bitácora',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(fechaFormatted,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 10),

      // Row de metadatos (Equipo / Área / etc.) — puedes dejarlo igual al tuyo
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Equipo
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Equipo:',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bitacora.equipo, style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),

          pw.SizedBox(width: 12),

          // Área
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Área:',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bitacora.area, style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),

          // Resto de columnas...
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Sub-área / Línea:',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bitacora.linea, style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Tipo de Limpieza:',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bitacora.tipoLimpieza, style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Frecuencia:',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(bitacora.frecuencia, style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 16),

      headerRow,

      // Aquí incluimos la tabla de filas (sin encabezado, porque el header del MultiPage ya lo dibuja)
      buildChecklistTableWithoutHeader(checklist, dejavuFont),

      pw.SizedBox(height: 16),

      // Firmas (quedarán al final; si no caben en la página, irán a la siguiente)
      buildThreeSignaturesSection(firma),
    ],
  ),
);

  final bytes = await pdf.save();
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/bitacora_${bitacora.id}.pdf');
  await file.writeAsBytes(bytes);
  return file;
}


// Función que crea el header de la tabla (usa la misma lógica de anchos que la tabla)
pw.Widget buildTableHeader() {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 40,
          alignment: pw.Alignment.center,
          child: pw.Text('Estado',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          flex: 5,
          child: pw.Text('Elemento',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          flex: 3,
          child: pw.Text('Observación',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    ),
  );
}


pw.Widget buildChecklistTableWithoutHeader(List<ChecklistItem> items, pw.Font dejavuFont) {
  final sorted = [...items]..sort((a, b) => a.orden!.compareTo(b.orden!));

  final rows = <pw.TableRow>[];

  for (final it in sorted) {
    final dynamic value = it.checked;
    final bool checkedBool = (value is int) ? value == 1 : (value is bool ? value : false);
    final String symbol = checkedBool ? '√' : 'X';
    final PdfColor symbolColor = checkedBool ? PdfColors.green800 : PdfColors.red800;

    final tituloText = it.titulo.trim();
    final observacionText = (it.observacion != null && it.observacion!.trim().isNotEmpty)
        ? it.observacion!.trim()
        : '-';

    rows.add(
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: pw.Container(
              width: 40,
              alignment: pw.Alignment.center,
              child: pw.Text(
                symbol,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  fontFallback: [dejavuFont],
                  color: symbolColor,
                ),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(tituloText, style: const pw.TextStyle(fontSize: 11)),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(observacionText,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ),
          ),
        ],
      ),
    );
  }

  return pw.Table(
    columnWidths: const {
      0: pw.FixedColumnWidth(40),
      1: pw.FlexColumnWidth(5),
      2: pw.FlexColumnWidth(3),
    },
    children: rows,
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(width: 0.2, color: PdfColors.grey300),
    ),
  );
}

pw.Widget buildThreeSignaturesSection(Firma firma) {
  final pw.ImageProvider? ejecutoImage =
      (firma.firmaEjecuto != null && firma.firmaEjecuto!.isNotEmpty)
          ? pw.MemoryImage(base64Decode(firma.firmaEjecuto!))
          : null;
  final pw.ImageProvider? verificoImage =
      (firma.firmaVerifico != null && firma.firmaVerifico!.isNotEmpty)
          ? pw.MemoryImage(base64Decode(firma.firmaVerifico!))
          : null;
  final pw.ImageProvider? liberoImage =
      (firma.firmaLibero != null && firma.firmaLibero!.isNotEmpty)
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
                      ? pw.Center(
                          child: pw.Image(ejecutoImage, fit: pw.BoxFit.contain))
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
                      ? pw.Center(
                          child:
                              pw.Image(verificoImage, fit: pw.BoxFit.contain))
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
                      ? pw.Center(
                          child: pw.Image(liberoImage, fit: pw.BoxFit.contain))
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
