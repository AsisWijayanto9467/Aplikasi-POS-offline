// lib/data/services/export_service.dart
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ExportService {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // ========== EXPORT TO EXCEL ==========
  Future<String?> exportToExcel({
    required Map<String, dynamic> reportData,
    required String fileName,
  }) async {
    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Laporan'];

      int rowIndex = 1;

      // ===== TITLE =====
      sheet.merge(excel.CellIndex.indexByString('A1'), excel.CellIndex.indexByString('E1'));
      final titleCell = sheet.cell(excel.CellIndex.indexByString('A1'));
      titleCell.value = excel.TextCellValue('LAPORAN SALON DESK');
      titleCell.cellStyle = excel.CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: excel.ExcelColor.fromHexString('#7E0092'),
        horizontalAlign: excel.HorizontalAlign.Center,
      );

      rowIndex = 3;

      // ===== PERIOD =====
      sheet.merge(excel.CellIndex.indexByString('A$rowIndex'), excel.CellIndex.indexByString('E$rowIndex'));
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).value =
          excel.TextCellValue('Periode: ${reportData['period'] ?? '-'}');
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).cellStyle = excel.CellStyle(
        fontSize: 11,
        horizontalAlign: excel.HorizontalAlign.Center,
      );

      rowIndex = 5;

      // ===== STYLES =====
      final headerStyle = excel.CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: excel.ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: excel.ExcelColor.fromHexString('#7E0092'),
        horizontalAlign: excel.HorizontalAlign.Center,
      );

      final labelStyle = excel.CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: excel.ExcelColor.fromHexString('#F3E5F5'),
      );

      final normalStyle = excel.CellStyle(fontSize: 11);

      // ===== SUMMARY =====
      sheet.merge(excel.CellIndex.indexByString('A$rowIndex'), excel.CellIndex.indexByString('E$rowIndex'));
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).value = excel.TextCellValue('RINGKASAN');
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).cellStyle = headerStyle;

      rowIndex = 6;

      final summaryData = [
        ['Total Penjualan', _currencyFormat.format(reportData['totalSales'] ?? 0)],
        ['Total Transaksi', '${reportData['totalOrders'] ?? 0}'],
        ['Rata-rata Transaksi', _currencyFormat.format(reportData['averageBasket'] ?? 0)],
        ['Perubahan Penjualan', '${(reportData['salesChange'] ?? 0).toStringAsFixed(1)}%'],
      ];

      for (var data in summaryData) {
        sheet.merge(excel.CellIndex.indexByString('A$rowIndex'), excel.CellIndex.indexByString('B$rowIndex'));
        sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).value = excel.TextCellValue(data[0]);
        sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).cellStyle = labelStyle;

        sheet.merge(excel.CellIndex.indexByString('C$rowIndex'), excel.CellIndex.indexByString('E$rowIndex'));
        sheet.cell(excel.CellIndex.indexByString('C$rowIndex')).value = excel.TextCellValue(data[1]);
        sheet.cell(excel.CellIndex.indexByString('C$rowIndex')).cellStyle = normalStyle;

        rowIndex++;
      }

      rowIndex += 2;

      // ===== TOP PRODUCTS TABLE =====
      sheet.merge(excel.CellIndex.indexByString('A$rowIndex'), excel.CellIndex.indexByString('E$rowIndex'));
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).value = excel.TextCellValue('PRODUK TERLARIS');
      sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).cellStyle = headerStyle;

      rowIndex++;

      final headers = ['No', 'Nama', 'Kategori', 'Unit', 'Pendapatan'];
      for (var i = 0; i < headers.length; i++) {
        final col = String.fromCharCode(65 + i);
        sheet.cell(excel.CellIndex.indexByString('$col$rowIndex')).value = excel.TextCellValue(headers[i]);
        sheet.cell(excel.CellIndex.indexByString('$col$rowIndex')).cellStyle = labelStyle;
      }

      rowIndex++;

      final topProducts = (reportData['topProducts'] as List?) ?? [];
      for (var i = 0; i < topProducts.length; i++) {
        final p = topProducts[i] as Map<String, dynamic>;

        sheet.cell(excel.CellIndex.indexByString('A$rowIndex')).value = excel.IntCellValue(i + 1);
        sheet.cell(excel.CellIndex.indexByString('B$rowIndex')).value = excel.TextCellValue(p['name'] ?? '-');
        sheet.cell(excel.CellIndex.indexByString('C$rowIndex')).value = excel.TextCellValue(p['category'] ?? '-');
        sheet.cell(excel.CellIndex.indexByString('D$rowIndex')).value = excel.IntCellValue(p['units'] ?? 0);
        sheet.cell(excel.CellIndex.indexByString('E$rowIndex')).value = excel.DoubleCellValue((p['revenue'] as num?)?.toDouble() ?? 0);

        for (var j = 0; j < 5; j++) {
          final col = String.fromCharCode(65 + j);
          sheet.cell(excel.CellIndex.indexByString('$col$rowIndex')).cellStyle = normalStyle;
        }
        rowIndex++;
      }

      sheet.setColumnWidth(0, 5);
      sheet.setColumnWidth(1, 30);
      sheet.setColumnWidth(2, 15);
      sheet.setColumnWidth(3, 10);
      sheet.setColumnWidth(4, 20);

      // ===== SAVE & SHARE =====
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.xlsx';

      final fileBytes = excelFile.encode();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        // ✅ Gunakan share_plus untuk membuka/membagikan file
        await Share.shareXFiles([XFile(filePath)], text: 'Laporan Excel - Salon Desk');
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  // ========== EXPORT TO PDF (SYNCFUSION) ==========
  Future<String?> exportToPDF({
    required Map<String, dynamic> reportData,
    required String fileName,
  }) async {
    try {
      final document = PdfDocument();
      final now = DateTime.now();

      var page = document.pages.add();
      var graphics = page.graphics;
      var size = page.getClientSize();
      double y = 0;

      final font = PdfStandardFont(PdfFontFamily.helvetica, 11);
      final boldFont = PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);
      final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 13, style: PdfFontStyle.bold);
      final purpleBrush = PdfSolidBrush(PdfColor(126, 0, 146));
      final greyBrush = PdfSolidBrush(PdfColor(128, 128, 128));
      final lightGreyBrush = PdfSolidBrush(PdfColor(240, 240, 240));

      // ===== TITLE =====
      graphics.drawString('SALON DESK',
          PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold),
          brush: purpleBrush,
          bounds: Rect.fromLTWH(0, y, size.width, 30),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));
      y += 35;

      graphics.drawString('Laporan Penjualan', PdfStandardFont(PdfFontFamily.helvetica, 14),
          bounds: Rect.fromLTWH(0, y, size.width, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));
      y += 20;

      graphics.drawString(
          'Periode: ${reportData['period'] ?? '-'} | ${DateFormat('dd MMM yyyy HH:mm').format(now)}',
          PdfStandardFont(PdfFontFamily.helvetica, 9),
          brush: greyBrush,
          bounds: Rect.fromLTWH(0, y, size.width, 15),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));
      y += 25;

      graphics.drawLine(PdfPen(PdfColor(126, 0, 146), width: 1), Offset(40, y), Offset(size.width - 40, y));
      y += 20;

      // ===== RINGKASAN =====
      graphics.drawString('RINGKASAN', titleFont, brush: purpleBrush, bounds: Rect.fromLTWH(40, y, 200, 20));
      y += 25;

      final summary = [
        ['Total Penjualan', _currencyFormat.format(reportData['totalSales'] ?? 0)],
        ['Total Transaksi', '${reportData['totalOrders'] ?? 0}'],
        ['Rata-rata Transaksi', _currencyFormat.format(reportData['averageBasket'] ?? 0)],
        ['Perubahan Penjualan', '${(reportData['salesChange'] ?? 0).toStringAsFixed(1)}%'],
      ];

      for (var s in summary) {
        graphics.drawString(s[0], font, bounds: Rect.fromLTWH(40, y, 200, 18));
        graphics.drawString(s[1], boldFont, bounds: Rect.fromLTWH(250, y, 200, 18));
        y += 20;
      }

      y += 20;
      graphics.drawLine(PdfPen(PdfColor(200, 200, 200), width: 0.5), Offset(40, y), Offset(size.width - 40, y));
      y += 15;

      // ===== PRODUK TERLARIS =====
      graphics.drawString('PRODUK TERLARIS', titleFont, brush: purpleBrush, bounds: Rect.fromLTWH(40, y, 200, 20));
      y += 25;

      final topProducts = (reportData['topProducts'] as List?) ?? [];

      if (topProducts.isEmpty) {
        graphics.drawString('Belum ada data', font, brush: greyBrush, bounds: Rect.fromLTWH(40, y, 200, 18));
        y += 20;
      } else {
        graphics.drawRectangle(brush: PdfSolidBrush(PdfColor(243, 229, 245)), bounds: Rect.fromLTWH(40, y, size.width - 80, 20));

        final headerCols = ['No', 'Nama', 'Kategori', 'Unit', 'Pendapatan'];
        final colWidths = [30.0, 150.0, 80.0, 50.0, 100.0];
        double x = 40;

        for (var i = 0; i < headerCols.length; i++) {
          graphics.drawString(headerCols[i], boldFont, bounds: Rect.fromLTWH(x, y, colWidths[i], 20),
              format: PdfStringFormat(alignment: i >= 3 ? PdfTextAlignment.right : PdfTextAlignment.left));
          x += colWidths[i];
        }
        y += 22;

        for (var i = 0; i < topProducts.length; i++) {
          if (y > size.height - 60) {
            page = document.pages.add();
            graphics = page.graphics;
            size = page.getClientSize();
            y = 20;
          }

          final p = topProducts[i] as Map<String, dynamic>;
          x = 40;

          if (i % 2 == 1) {
            graphics.drawRectangle(brush: lightGreyBrush, bounds: Rect.fromLTWH(40, y, size.width - 80, 18));
          }

          final rowData = [
            '${i + 1}', p['name'] ?? '-', p['category'] ?? '-',
            '${p['units'] ?? 0}', _currencyFormat.format((p['revenue'] as num?)?.toDouble() ?? 0),
          ];

          for (var j = 0; j < rowData.length; j++) {
            graphics.drawString(rowData[j], font, bounds: Rect.fromLTWH(x, y, colWidths[j], 18),
                format: PdfStringFormat(alignment: j >= 3 ? PdfTextAlignment.right : PdfTextAlignment.left));
            x += colWidths[j];
          }
          y += 20;
        }
      }

      // ===== FOOTER =====
      y = size.height - 40;
      graphics.drawLine(PdfPen(PdfColor(200, 200, 200), width: 0.5), Offset(40, y), Offset(size.width - 40, y));
      y += 5;
      graphics.drawString('© ${now.year} Salon Desk', PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfSolidBrush(PdfColor(160, 160, 160)),
          bounds: Rect.fromLTWH(0, y, size.width, 15),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));

      // ===== SAVE & SHARE =====
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await document.save());
      document.dispose();

      // ✅ Gunakan share_plus untuk membuka/membagikan file
      await Share.shareXFiles([XFile(filePath)], text: 'Laporan PDF - Salon Desk');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return null;
    }
  }
}