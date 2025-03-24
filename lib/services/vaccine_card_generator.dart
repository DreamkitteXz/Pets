import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_app/models/vacinas.dart';
import 'package:pet_app/models/pets.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class VaccineCardGenerator {
  static Future<String> generateVaccineCard(
      Pets pet, List<Vacinas> vaccines) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 40;

    // iOS-style fonts
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 16);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    // iOS-style colors
    final PdfColor iosBlue = PdfColor(0, 122, 255);
    final PdfColor iosGray = PdfColor(142, 142, 147);
    final PdfColor iosBackground = PdfColor(249, 249, 249);

    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    double yPosition = 40;

    // Title
    page.graphics.drawString(
      'Pet Vaccine Card',
      titleFont,
      brush: PdfSolidBrush(iosBlue),
      bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 30),
    );
    yPosition += 50;

    // Pet Information Section
    _addSectionHeader(page, 'Pet Details', yPosition, headerFont, iosBlue);
    yPosition += 30;

    // Pet details in iOS style
    Map<String, String> petDetails = {
      'Name': pet.name ?? 'Not provided',
      'Species': _capitalizeFirstLetter(pet.species ?? 'Not provided'),
      'Breed': pet.breed ?? 'Not provided',
      'Gender': _translateGender(pet.gender ?? 'Not provided'),
      'Birth Date': _formatDate(pet.birthDate),
      'Microchip': pet.chipNumber ?? 'Not registered',
      'Owner': pet.ownerName ?? 'Not provided',
    };

    yPosition =
        _addDetailsGrid(page, petDetails, yPosition, normalFont, iosGray);
    yPosition += 40;

    // Vaccines Section
    _addSectionHeader(
        page, 'Vaccination History', yPosition, headerFont, iosBlue);
    yPosition += 30;

    // Filter approved vaccines
    final validatedVaccines =
        vaccines.where((v) => v.status == 'approved').toList();

    if (validatedVaccines.isNotEmpty) {
      _addVaccineTable(page, validatedVaccines, yPosition, pageSize.width,
          normalFont, smallFont, iosBlue, iosBackground);
    } else {
      page.graphics.drawString(
        'No approved vaccines recorded',
        normalFont,
        brush: PdfSolidBrush(iosGray),
        bounds: Rect.fromLTWH(0, yPosition, pageSize.width, 20),
      );
    }

    // Save document
    final String path = await _savePdf(document, pet.name ?? 'vaccine_card');
    document.dispose();
    return path;
  }

  static void _addSectionHeader(PdfPage page, String title, double yPosition,
      PdfFont font, PdfColor color) {
    page.graphics.drawString(
      title,
      font,
      brush: PdfSolidBrush(color),
      bounds: Rect.fromLTWH(0, yPosition, page.getClientSize().width, 20),
    );
  }

  static double _addDetailsGrid(PdfPage page, Map<String, String> details,
      double yPosition, PdfFont font, PdfColor color) {
    double currentY = yPosition;
    details.forEach((key, value) {
      page.graphics.drawString(
        '$key: $value',
        font,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 20),
      );
      currentY += 25;
    });
    return currentY;
  }

  static void _addVaccineTable(
      PdfPage page,
      List<Vacinas> vaccines,
      double yPosition,
      double width,
      PdfFont normalFont,
      PdfFont smallFont,
      PdfColor iosBlue,
      PdfColor iosBackground) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);

    // Set column headers
    final header = grid.headers.add(1)[0];
    header.cells[0].value = 'Date';
    header.cells[1].value = 'Vaccine';
    header.cells[2].value = 'Next Due';
    header.cells[3].value = 'Veterinarian';

    // Add vaccine data
    for (var vaccine in vaccines) {
      final row = grid.rows.add();
      row.cells[0].value = _formatDate(vaccine.administrationDate);
      row.cells[1].value = vaccine.name ?? 'N/A';
      row.cells[2].value = _formatDate(vaccine.nextDueDate);
      row.cells[3].value = vaccine.veterinarianName ?? 'N/A';
    }

    // Style the grid
    grid.style = PdfGridStyle(
      font: smallFont,
      cellPadding: PdfPaddings(left: 8, top: 8, right: 8, bottom: 8),
    );

    grid.draw(page: page, bounds: Rect.fromLTWH(0, yPosition, width, 0));
  }

  // Helper methods remain the same
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String _translateGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Not specified';
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  static Future<String> _savePdf(PdfDocument document, String fileName) async {
    final Directory? directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('Unable to access storage');

    final String path = '${directory.path}/${fileName}_vaccine_card.pdf';
    File file = File(path);
    await file.writeAsBytes(await document.save());
    return path;
  }
}
