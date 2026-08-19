import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:pet_app/design/design.dart' show AppStatus, appStatusFromString;
import 'package:pet_app/models/deworming_model.dart';
import 'package:pet_app/models/pet_model.dart';
import 'package:pet_app/models/vaccine_model.dart';

/// Uma linha da carteira — vacina ou vermífugo, já normalizados.
class _Registro {
  final String tipo; // 'Vacina' | 'Vermífugo'
  final String nome;
  final String fabricante;
  final String lote;
  final DateTime? aplicacao;
  final DateTime? proximaDose;
  final String responsavel;
  final String comprovacao;

  _Registro({
    required this.tipo,
    required this.nome,
    required this.fabricante,
    required this.lote,
    required this.aplicacao,
    required this.proximaDose,
    required this.responsavel,
    required this.comprovacao,
  });
}

/// Gera a **Carteira de Vacinação e Vermifugação** em PDF.
///
/// Este documento é o mesmo emitido pela web em
/// `src/components/pages/PetRecord/Carteira.jsx` (branch Website): mesmo
/// título, mesmos dados do pet, mesmas colunas, mesmo critério de inclusão
/// (registro aprovado E não removido) e o mesmo rodapé. Ao mexer em um lado,
/// mexa no outro — é um documento só, em duas mídias.
class VaccineCardGenerator {
  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  static String _data(DateTime? d) => d == null ? '—' : _fmt.format(d);

  static String _ou(String? v) => (v == null || v.trim().isEmpty) ? '—' : v;

  /// Só entram registros aprovados e não removidos (soft delete `active`),
  /// igual ao filtro da web.
  static bool _entraNaCarteira(String? status, bool? active) =>
      appStatusFromString(status) == AppStatus.approved && active != false;

  static String _responsavel(String? vet, String? crmv, String? clinica) {
    if (vet == null || vet.trim().isEmpty) return '—';
    final buffer = StringBuffer(vet);
    if (crmv != null && crmv.trim().isNotEmpty) buffer.write(' ($crmv)');
    if (clinica != null && clinica.trim().isNotEmpty) {
      buffer.write(' · $clinica');
    }
    return buffer.toString();
  }

  static String _idade(DateTime? birthDate) {
    if (birthDate == null) return '—';
    final now = DateTime.now();
    final months =
        (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (months < 12) return '$months ${months == 1 ? 'mês' : 'meses'}';
    final years = months ~/ 12;
    return '$years ${years == 1 ? 'ano' : 'anos'}';
  }

  static String _especieRaca(Pets pet) {
    final especie = _especieDisplay(pet.species);
    if (pet.breed == null || pet.breed!.trim().isEmpty) return especie;
    return '$especie · ${pet.breed}';
  }

  static String _especieDisplay(String? species) {
    switch (species?.toLowerCase()) {
      case 'dog':
        return 'Cachorro';
      case 'cat':
        return 'Gato';
      case null:
        return '—';
      default:
        return species!;
    }
  }

  static String _sexoDisplay(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'Macho';
      case 'female':
        return 'Fêmea';
      default:
        return '—';
    }
  }

  static Future<String> generateVaccineCard(
    Pets pet,
    List<Vacinas> vaccines, {
    List<Vermifugo> dewormings = const [],
  }) async {
    final registros = <_Registro>[];

    for (final v in vaccines) {
      if (!_entraNaCarteira(v.status, v.active)) continue;
      // A web mostra ícones (câmera / pino); no PDF vira texto equivalente.
      final provas = <String>[
        if ((v.labelImage ?? '').isNotEmpty) 'foto',
        if (v.labelImageMetadata?['location'] != null) 'local',
      ];
      registros.add(_Registro(
        tipo: 'Vacina',
        nome: _ou(v.name),
        fabricante: _ou(v.manufacturer),
        lote: _ou(v.batchNumber),
        aplicacao: v.administrationDate,
        proximaDose: v.nextDueDate,
        responsavel:
            _responsavel(v.veterinarianName, v.crmvNumber, v.clinicName),
        comprovacao: provas.isEmpty ? '—' : provas.join(' + '),
      ));
    }

    for (final d in dewormings) {
      if (!_entraNaCarteira(d.status, d.active)) continue;
      registros.add(_Registro(
        tipo: 'Vermífugo',
        nome: _ou(d.name),
        fabricante: _ou(d.manufacturer),
        // O modelo de vermífugo não tem lote nem foto de rótulo.
        lote: '—',
        aplicacao: d.administrationDate,
        proximaDose: d.nextDueDate ?? d.reinforcementDate,
        responsavel:
            _responsavel(d.veterinarianName, d.crmvNumber, d.clinicName),
        comprovacao: '—',
      ));
    }

    // Mais recentes primeiro, como na web.
    registros.sort((a, b) {
      final da = a.aplicacao;
      final db = b.aplicacao;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    final document = PdfDocument();
    document.pageSettings.margins.all = 40;

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 17,
        style: PdfFontStyle.bold);
    final captionFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final labelFont =
        PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    final valueFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final tableFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
    final tableHeaderFont =
        PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);

    // Mesmos tokens do site (--text-*, --separator).
    final textPrimary = PdfColor(28, 28, 30);
    final textSecondary = PdfColor(99, 99, 102);
    final textTertiary = PdfColor(142, 142, 147);
    final separator = PdfColor(216, 216, 220);

    final page = document.pages.add();
    final pageSize = page.getClientSize();
    final graphics = page.graphics;
    double y = 0;

    graphics.drawString(
      'Carteira de Vacinação e Vermifugação',
      titleFont,
      brush: PdfSolidBrush(textPrimary),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 24),
    );
    y += 22;

    graphics.drawString(
      'Documento com registros validados · emitido em '
      '${_fmt.format(DateTime.now())}',
      captionFont,
      brush: PdfSolidBrush(textTertiary),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 14),
    );
    y += 22;

    graphics.drawLine(
      PdfPen(separator, width: 1.5),
      Offset(0, y),
      Offset(pageSize.width, y),
    );
    y += 16;

    // Dados do pet — mesmos seis campos da web, em grade de 3 colunas.
    final campos = <List<String>>[
      ['PET', _ou(pet.name)],
      ['ESPÉCIE / RAÇA', _especieRaca(pet)],
      ['IDADE', _idade(pet.birthDate)],
      ['TUTOR', _ou(pet.ownerName)],
      ['MICROCHIP', _ou(pet.chipNumber)],
      ['SEXO', _sexoDisplay(pet.gender)],
    ];

    const colunas = 3;
    final larguraColuna = pageSize.width / colunas;
    for (var i = 0; i < campos.length; i++) {
      final coluna = i % colunas;
      final linha = i ~/ colunas;
      final x = coluna * larguraColuna;
      final topo = y + linha * 38;

      graphics.drawString(
        campos[i][0],
        labelFont,
        brush: PdfSolidBrush(textTertiary),
        bounds: Rect.fromLTWH(x, topo, larguraColuna - 8, 12),
      );
      graphics.drawString(
        campos[i][1],
        valueFont,
        brush: PdfSolidBrush(textPrimary),
        bounds: Rect.fromLTWH(x, topo + 13, larguraColuna - 8, 16),
      );
    }
    y += ((campos.length / colunas).ceil() * 38) + 6;

    graphics.drawLine(
      PdfPen(separator, width: 1),
      Offset(0, y),
      Offset(pageSize.width, y),
    );
    y += 16;

    if (registros.isEmpty) {
      graphics.drawString(
        'Nenhum registro validado para exibir.',
        valueFont,
        brush: PdfSolidBrush(textSecondary),
        bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
      );
      y += 30;
    } else {
      final grid = PdfGrid();
      grid.columns.add(count: 8);
      // Proporções pensadas para caber em retrato sem estourar.
      const pesos = <double>[0.09, 0.16, 0.14, 0.10, 0.11, 0.11, 0.19, 0.10];
      for (var i = 0; i < pesos.length; i++) {
        grid.columns[i].width = pageSize.width * pesos[i];
      }

      final header = grid.headers.add(1)[0];
      const titulos = [
        'TIPO',
        'NOME',
        'FABRICANTE',
        'LOTE',
        'APLICAÇÃO',
        'PRÓX. DOSE',
        'RESPONSÁVEL',
        'COMPROV.',
      ];
      for (var i = 0; i < titulos.length; i++) {
        header.cells[i].value = titulos[i];
      }
      header.style = PdfGridRowStyle(
        font: tableHeaderFont,
        textBrush: PdfSolidBrush(textSecondary),
      );

      for (final r in registros) {
        final row = grid.rows.add();
        row.cells[0].value = r.tipo;
        row.cells[1].value = r.nome;
        row.cells[2].value = r.fabricante;
        row.cells[3].value = r.lote;
        row.cells[4].value = _data(r.aplicacao);
        row.cells[5].value = _data(r.proximaDose);
        row.cells[6].value = r.responsavel;
        row.cells[7].value = r.comprovacao;
      }

      grid.style = PdfGridStyle(
        font: tableFont,
        textBrush: PdfSolidBrush(textPrimary),
        cellPadding: PdfPaddings(left: 5, top: 6, right: 5, bottom: 6),
      );
      grid.applyBuiltInStyle(PdfGridBuiltInStyle.plainTable1);

      final result =
          grid.draw(page: page, bounds: Rect.fromLTWH(0, y, pageSize.width, 0));
      y = (result?.bounds.bottom ?? y) + 18;
    }

    // O rodapé vai na última página gerada pela tabela.
    final ultimaPagina = document.pages[document.pages.count - 1];
    final alturaUltima = ultimaPagina.getClientSize().height;
    final yRodape = y + 40 > alturaUltima ? alturaUltima - 40 : y;

    ultimaPagina.graphics.drawLine(
      PdfPen(separator, width: 1),
      Offset(0, yRodape),
      Offset(pageSize.width, yRodape),
    );
    ultimaPagina.graphics.drawString(
      'Apenas registros aprovados por veterinário (CRMV) são exibidos. '
      'Comprovação: foto do rótulo · localização da aplicação.',
      captionFont,
      brush: PdfSolidBrush(textTertiary),
      bounds: Rect.fromLTWH(0, yRodape + 8, pageSize.width, 28),
    );

    final path = await _savePdf(document, pet.name ?? 'carteira');
    document.dispose();
    return path;
  }

  static Future<String> _savePdf(PdfDocument document, String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('Unable to access storage');

    final safeName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    final path = '${directory.path}/'
        '${safeName.isEmpty ? 'carteira' : safeName}_carteira.pdf';
    final file = File(path);
    await file.writeAsBytes(await document.save());
    return path;
  }
}
