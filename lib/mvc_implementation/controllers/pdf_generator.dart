import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

Future<void> _createPDF(Vacinas widget) async {
  PdfDocument document = PdfDocument();
  final page = document.pages.add();
  PdfPageTemplateElement headervet = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width, 100));

  page.graphics.drawString(
      'Carteira de Vacinação', PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(0, 30, page.getClientSize().width, 30),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle));

  page.graphics.drawImage(PdfBitmap(await loadImageFromUrl(widget.imageRotulo)),
      const Rect.fromLTWH(100, 100, 300, 200));

  page.graphics.drawString(
      'Vacina', PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(0, 340, page.getClientSize().width, 30),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle));

  PdfGrid grid = PdfGrid();
  grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 14),
      cellPadding: PdfPaddings(left: 10, right: 10, top: 10, bottom: 10));

  grid.columns.add(count: 3);
  grid.headers.add(1);

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'Vacina';
  header.cells[1].value = 'Data Aplicada';
  header.cells[2].value = 'Próxima aplicação';

  //Creates the header style
  PdfGridCellStyle headerStyle = PdfGridCellStyle();
  headerStyle.borders.all = PdfPen(PdfColor(126, 151, 173));
  headerStyle.backgroundBrush = PdfSolidBrush(PdfColor(126, 151, 173));
  headerStyle.textBrush = PdfBrushes.white;
  headerStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 14,
      style: PdfFontStyle.regular);

//Adds cell customizations
  for (int i = 0; i < header.cells.count; i++) {
    if (i == 0 || i == 1) {
      header.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.middle);
    } else {
      header.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle);
    }
    header.cells[i].style = headerStyle;
  }

  PdfGridRow row = grid.rows.add();
  row.cells[0].value = widget.vacina;
  row.cells[1].value = widget.dataAplicada;
  row.cells[2].value = widget.proximaAplicacao;

//Set padding for grid cells
  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);

//Creates the grid cell styles
  PdfGridCellStyle cellStyle = PdfGridCellStyle();
  cellStyle.borders.all = PdfPens.white;
  cellStyle.borders.bottom = PdfPen(PdfColor(217, 217, 217), width: 0.70);
  cellStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 12);
  cellStyle.textBrush = PdfSolidBrush(PdfColor(131, 130, 136));
//Adds cell customizations
  for (int i = 0; i < grid.rows.count; i++) {
    PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      row.cells[j].style = cellStyle;
      if (j == 0 || j == 1) {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle);
      } else {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle);
      }
    }
  }

  // Título para a segunda grade
  page.graphics.drawString(
    'Dados da Vacina',
    PdfStandardFont(PdfFontFamily.helvetica, 14),
    bounds: Rect.fromLTWH(0, 500, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );

  // Cria a segunda grade
  PdfGrid grid2 = PdfGrid();
  grid2.style = PdfGridStyle(
    font: PdfStandardFont(PdfFontFamily.helvetica, 14),
    cellPadding: PdfPaddings(left: 10, right: 10, top: 10, bottom: 10),
  );

  // Adiciona colunas e cabeçalho para a segunda grade
  grid2.columns.add(count: 4);
  grid2.headers.add(1);

  PdfGridRow header2 = grid2.headers[0];
  header2.cells[0].value = 'Lote';
  header2.cells[1].value = 'Farmacêutica';
  header2.cells[2].value = 'Data de Validade';
  header2.cells[3].value = 'Peso do Pet';

  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
  for (int i = 0; i < header2.cells.count; i++) {
    if (i == 0 || i == 1) {
      header2.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.middle);
    } else {
      header2.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.middle);
    }
    header2.cells[i].style = headerStyle;
  }

  PdfGridRow row2 = grid2.rows.add();
  row2.cells[0].value = widget.lote;
  row2.cells[1].value = widget.farmaceutica;
  row2.cells[2].value = widget.dataValidade;
  row2.cells[3].value = widget.pesoDataAplicacao;

//Creates the grid cell styles
  PdfGridCellStyle cellStyle2 = PdfGridCellStyle();
  cellStyle2.borders.all = PdfPens.white;
  cellStyle2.borders.bottom = PdfPen(PdfColor(217, 217, 217), width: 0.70);
  cellStyle2.font = PdfStandardFont(PdfFontFamily.timesRoman, 12);
  cellStyle2.textBrush = PdfSolidBrush(PdfColor(131, 130, 136));
//Adds cell customizations
  for (int i = 0; i < grid2.rows.count; i++) {
    PdfGridRow row = grid2.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      row.cells[j].style = cellStyle;
      if (j == 0 || j == 1) {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle);
      } else {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle);
      }
    }
  }
  page.graphics.drawString(
    'Observações',
    PdfStandardFont(PdfFontFamily.helvetica, 14),
    bounds: Rect.fromLTWH(0, 650, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );

  String paragraphText = widget.observacoes;
  PdfTextElement paragraph = PdfTextElement(
    text: paragraphText,
    font: PdfStandardFont(PdfFontFamily.helvetica, 12),
  );
  paragraph.draw(
    page: page,
    bounds: Rect.fromLTWH(0, 700, page.getClientSize().width, 0),
  );

  PdfLayoutFormat layoutFormat =
      PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

  grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 370, page.getClientSize().width, 0),
      format: layoutFormat);
  grid2.draw(
    page: page,
    bounds: Rect.fromLTWH(0, 550, page.getClientSize().width, 0),
    format: layoutFormat,
  );

  List<int> bytes = await document.save();
  document.dispose();

  saveAndLaunchFile(bytes, 'Output.pdf');
}

Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load(name);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<Uint8List> loadImageFromUrl(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image from URL: $imageUrl');
  }
}

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final path = (await getExternalStorageDirectory())?.path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
}
