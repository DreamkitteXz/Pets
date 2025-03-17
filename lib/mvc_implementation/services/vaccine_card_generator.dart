import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_app/mvc_implementation/models/vacinas.dart';
import 'package:pet_app/mvc_implementation/models/pets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class VaccineCardGenerator {
  static Future<String> generateVaccineCard(
      Pets pet, List<Vacinas> vaccines) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;

    // Use standard fonts instead of custom fonts
    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont headerFont =
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final PdfFont boldFont =
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    // Colors for the document
    final PdfColor primaryColor =
        PdfColor(0, 104, 71); // Green for official look
    final PdfColor secondaryColor = PdfColor(206, 173, 43); // Gold accent
    final PdfColor textColor = PdfColor(35, 35, 35);
    final PdfColor lightGray = PdfColor(245, 245, 245);

    // Add a page to the document
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // Draw border with rounded corners (simulated with rectangles since PDF doesn't support rounded corners directly)
    _drawPageBorder(page, primaryColor, pageSize);

    // Header section with coat of arms and title
    double yPosition = 25;

    // Attempt to load coat of arms image
    try {
      ByteData imageData =
          await rootBundle.load('assets/images/brazil_coat_of_arms.png');
      final PdfBitmap coatOfArms = PdfBitmap(imageData.buffer.asUint8List());
      page.graphics.drawImage(coatOfArms,
          Rect.fromLTWH((pageSize.width / 2) - 25, yPosition, 50, 50));
      yPosition += 60;
    } catch (e) {
      // If image loading fails, add some space for title
      yPosition += 10;
    }

    // Document title
    page.graphics.drawString(
      'REPÚBLICA FEDERATIVA DO BRASIL',
      headerFont,
      brush: PdfSolidBrush(textColor),
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    yPosition += 20;

    page.graphics.drawString(
      'MINISTÉRIO DA AGRICULTURA, PECUÁRIA E ABASTECIMENTO',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      brush: PdfSolidBrush(textColor),
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    yPosition += 25;

    // Main title in color band
    _drawColorBand(page, 'CARTÃO DE VACINAÇÃO ANIMAL', yPosition,
        pageSize.width, 40, primaryColor, secondaryColor, titleFont);
    yPosition += 55;

    // Pet information section with stylized box
    _drawBoxWithTitle(page, 'IDENTIFICAÇÃO DO ANIMAL', yPosition,
        pageSize.width, primaryColor, lightGray, headerFont);
    yPosition += 35;

    // Pet details in a two-column layout
    _addPetDetailsInColumns(
        page, pet, yPosition, pageSize.width, normalFont, boldFont);
    yPosition += 120;

    // Add QR code placeholder (if available)
    try {
      ByteData qrData =
          await rootBundle.load('assets/images/qr_placeholder.png');
      final PdfBitmap qrCode = PdfBitmap(qrData.buffer.asUint8List());
      page.graphics.drawImage(
          qrCode, Rect.fromLTWH(pageSize.width - 85, yPosition - 110, 80, 80));
    } catch (e) {
      // QR code is optional
    }

    // Vaccines section title
    _drawBoxWithTitle(page, 'HISTÓRICO DE VACINAÇÃO', yPosition, pageSize.width,
        primaryColor, lightGray, headerFont);
    yPosition += 35;

    // Add vaccines table with styling
    _addStylizedVaccinesTable(page, vaccines, yPosition, pageSize.width,
        primaryColor, secondaryColor, normalFont, boldFont, smallFont);

    // Footer with official stamp area and verification info
    _addOfficialFooter(
        page, pageSize, primaryColor, normalFont, boldFont, smallFont);

    // Save the document
    final String path = await _savePdf(document, pet.name ?? 'cartao_vacina');
    document.dispose();
    return path;
  }

  static void _drawPageBorder(
      PdfPage page, PdfColor borderColor, Size pageSize) {
    // Draw border with thicker line
    page.graphics.drawRectangle(
      pen: PdfPen(borderColor, width: 2),
      bounds: Rect.fromLTWH(10, 10, pageSize.width - 20, pageSize.height - 20),
    );

    // Add subtle decorative corner elements
    double cornerSize = 15;
    PdfPen cornerPen = PdfPen(borderColor, width: 2.5);

    // Top-left corner
    page.graphics
        .drawLine(cornerPen, Offset(10, 20), Offset(10 + cornerSize, 20));
    page.graphics
        .drawLine(cornerPen, Offset(20, 10), Offset(20, 10 + cornerSize));

    // Top-right corner
    page.graphics.drawLine(cornerPen, Offset(pageSize.width - 10, 20),
        Offset(pageSize.width - 10 - cornerSize, 20));
    page.graphics.drawLine(cornerPen, Offset(pageSize.width - 20, 10),
        Offset(pageSize.width - 20, 10 + cornerSize));

    // Bottom-left corner
    page.graphics.drawLine(cornerPen, Offset(10, pageSize.height - 20),
        Offset(10 + cornerSize, pageSize.height - 20));
    page.graphics.drawLine(cornerPen, Offset(20, pageSize.height - 10),
        Offset(20, pageSize.height - 10 - cornerSize));

    // Bottom-right corner
    page.graphics.drawLine(
        cornerPen,
        Offset(pageSize.width - 10, pageSize.height - 20),
        Offset(pageSize.width - 10 - cornerSize, pageSize.height - 20));
    page.graphics.drawLine(
        cornerPen,
        Offset(pageSize.width - 20, pageSize.height - 10),
        Offset(pageSize.width - 20, pageSize.height - 10 - cornerSize));
  }

  static void _drawColorBand(
      PdfPage page,
      String text,
      double yPosition,
      double width,
      double height,
      PdfColor primaryColor,
      PdfColor accentColor,
      PdfFont font) {
    // Draw main background
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, yPosition, width, height),
    );

    // Draw accent line at the bottom
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(accentColor),
      bounds: Rect.fromLTWH(0, yPosition + height - 5, width, 5),
    );

    // Add the title text
    page.graphics.drawString(
      text,
      font,
      brush: PdfSolidBrush(PdfColor(255, 255, 255)),
      bounds: Rect.fromLTWH(0, yPosition + 5, width, height - 10),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
    );
  }

  static void _drawBoxWithTitle(
      PdfPage page,
      String title,
      double yPosition,
      double width,
      PdfColor titleColor,
      PdfColor backgroundColor,
      PdfFont font) {
    // Draw title background
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(titleColor),
      bounds: Rect.fromLTWH(0, yPosition, width, 25),
    );

    // Draw title text
    page.graphics.drawString(
      title,
      font,
      brush: PdfSolidBrush(PdfColor(255, 255, 255)),
      bounds: Rect.fromLTWH(10, yPosition, width - 20, 25),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.middle),
    );

    // Draw content background
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(backgroundColor),
      pen: PdfPen(titleColor),
      bounds: Rect.fromLTWH(0, yPosition + 25, width, 5),
    );
  }

  static void _addPetDetailsInColumns(PdfPage page, Pets pet, double yPosition,
      double width, PdfFont normalFont, PdfFont boldFont) {
    double leftColumnWidth = width * 0.5;
    double rightColumnStart = leftColumnWidth + 10;
    double rightColumnWidth = width - rightColumnStart;

    // Define details fields
    List<Map<String, String>> leftDetails = [
      {"label": "Nome:", "value": pet.name ?? "Não informado"},
      {
        "label": "Espécie:",
        "value": _capitalizeFirstLetter(pet.species ?? "Não informado")
      },
      {"label": "Raça:", "value": pet.breed ?? "Não informado"},
      {"label": "Cor:", "value": pet.color ?? "Não informado"},
    ];

    List<Map<String, String>> rightDetails = [
      {
        "label": "Gênero:",
        "value": _translateGender(pet.gender ?? "Não informado")
      },
      {"label": "Data de Nascimento:", "value": _formatDate(pet.birthDate)},
      {"label": "Microchip:", "value": pet.chipNumber ?? "Não registrado"},
      {"label": "Proprietário:", "value": pet.ownerName ?? "Não informado"},
    ];

    // Draw left column
    _drawDetailsList(
        page, leftDetails, yPosition, 0, leftColumnWidth, normalFont, boldFont);

    // Draw right column
    _drawDetailsList(page, rightDetails, yPosition, rightColumnStart,
        rightColumnWidth, normalFont, boldFont);
  }

  static void _drawDetailsList(
      PdfPage page,
      List<Map<String, String>> details,
      double yPosition,
      double xPosition,
      double width,
      PdfFont normalFont,
      PdfFont boldFont) {
    double spacing = 25;

    for (int i = 0; i < details.length; i++) {
      double currentY = yPosition + (i * spacing);

      // Draw label
      page.graphics.drawString(
        details[i]["label"]!,
        boldFont,
        brush: PdfSolidBrush(PdfColor(35, 35, 35)),
        bounds: Rect.fromLTWH(xPosition, currentY, width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );

      // Draw value
      page.graphics.drawString(
        details[i]["value"]!,
        normalFont,
        brush: PdfSolidBrush(PdfColor(50, 50, 50)),
        bounds: Rect.fromLTWH(xPosition + 70, currentY, width - 70, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );

      // Draw underline
      page.graphics.drawLine(
        PdfPen(PdfColor(200, 200, 200)),
        Offset(xPosition, currentY + 20),
        Offset(xPosition + width - 10, currentY + 20),
      );
    }
  }

  static void _addStylizedVaccinesTable(
      PdfPage page,
      List<Vacinas> vaccines,
      double yPosition,
      double width,
      PdfColor primaryColor,
      PdfColor accentColor,
      PdfFont normalFont,
      PdfFont boldFont,
      PdfFont smallFont) {
    final PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: smallFont,
      cellPadding: PdfPaddings(left: 5, right: 5, top: 7, bottom: 7),
    );

    // Define columns with more detailed information
    grid.columns.add(count: 8);
    grid.columns[0].width = 45; // Data
    grid.columns[1].width = 80; // Vacina
    grid.columns[2].width = 60; // Fabricante
    grid.columns[3].width = 50; // Lote
    grid.columns[4].width = 45; // Validade
    grid.columns[5].width = 45; // Próxima
    grid.columns[6].width = 70; // Veterinário
    grid.columns[7].width = 80; // Clínica

    PdfGridRow header = grid.headers.add(1)[0];
    header.style.backgroundBrush = PdfSolidBrush(primaryColor);
    header.style.textBrush = PdfSolidBrush(PdfColor(255, 255, 255));
    header.style.font = boldFont;

    List<String> headerTexts = [
      'Data',
      'Vacina',
      'Fabricante',
      'Lote',
      'Validade',
      'Próxima',
      'Veterinário',
      'Clínica'
    ];

    for (int i = 0; i < headerTexts.length; i++) {
      header.cells[i].value = headerTexts[i];
      header.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle);
    }

    // Update data mapping with proper null checks
    for (var vaccine in vaccines) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = _formatDate(vaccine.administrationDate);
      row.cells[1].value = vaccine.name ?? 'N/A';
      row.cells[2].value = vaccine.manufacturer ?? 'N/A';
      row.cells[3].value = vaccine.batchNumber ?? 'N/A';
      row.cells[4].value = _formatDate(vaccine.expirationDate);
      row.cells[5].value = _formatDate(vaccine.nextDueDate);
      row.cells[6].value =
          '${vaccine.veterinarianName ?? 'N/A'}\n${vaccine.crmvNumber ?? ''}';
      row.cells[7].value = vaccine.clinicName ?? 'N/A';

      // Center align all cells
      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle);
      }
    }

// Apply alternating row colors
    for (int i = 0; i < grid.rows.count; i++) {
      if (i % 2 == 0) {
        for (int j = 0; j < grid.rows[i].cells.count; j++) {
          grid.rows[i].cells[j].style.backgroundBrush =
              PdfSolidBrush(PdfColor(245, 245, 245));
        }
      }
    }
    // Draw grid on the page
    grid.draw(page: page, bounds: Rect.fromLTWH(0, yPosition, width, 0));
  }

  static void _addOfficialFooter(
      PdfPage page,
      Size pageSize,
      PdfColor primaryColor,
      PdfFont normalFont,
      PdfFont boldFont,
      PdfFont smallFont) {
    double footerY = pageSize.height - 80;

    // Add clinic information
    page.graphics.drawString('RESPONSÁVEL TÉCNICO / ESTABELECIMENTO', boldFont,
        brush: PdfSolidBrush(primaryColor),
        bounds: Rect.fromLTWH(50, footerY - 20, 300, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));

    // Draw stamp area
    page.graphics.drawString('Carimbo e Assinatura do Veterinário', normalFont,
        brush: PdfSolidBrush(primaryColor),
        bounds: Rect.fromLTWH(50, footerY, 200, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Draw lines for stamp and signature
    page.graphics.drawLine(PdfPen(primaryColor), Offset(50, footerY + 40),
        Offset(250, footerY + 40));

    // Add verification text
    page.graphics.drawString(
        'Este documento é oficial e possui validação digital', smallFont,
        brush: PdfSolidBrush(PdfColor(100, 100, 100)),
        bounds: Rect.fromLTWH(0, pageSize.height - 25, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
  }

  static Future<String> _savePdf(PdfDocument document, String fileName) async {
    try {
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Unable to access external storage');
      }

      final String path = '${directory.path}/${fileName}_vaccine_card.pdf';
      File file = File(path);
      await file.writeAsBytes(await document.save());
      return path;
    } catch (e) {
      print('Error saving PDF: $e');
      throw e;
    }
  }

  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String _translateGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Macho';
      case 'female':
        return 'Fêmea';
      default:
        return 'Não informado';
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
