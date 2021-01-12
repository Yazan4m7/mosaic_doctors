import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:open_file/open_file.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';

class Exporting {
  static reportView(
      context, List<AccountStatementEntry> entries, Jiffy month) async {
    Directory tempDir1 = await getExternalStorageDirectory();
    ByteData imageData1 = await rootBundle.load('assets/images/logo_vertical.png');
    final image = MemoryImage(imageData1.buffer.asUint8List());



    final Document pdf = Document();



    var data = await rootBundle.load("assets/fonts/DroidKufi-Regular.ttf");
    final Font ttf = Font.ttf(data.buffer.asByteData());


    pdf.addPage(MultiPage(
        pageFormat:
            PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm,marginTop: 10),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {

            return null;


        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[
          Center(child:Image.provider(image,width: 400)),
              Header(
                  level: 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            'Account Statment for ${month.format('MMMM-yyyy')}',
                        ),
                        Directionality(textDirection: TextDirection.rtl, child:  Text(
                            '${getIt<SessionData>().doctor.name} د. ',  style: TextStyle(font: ttf),
                           ))
                       ,
                      ])),
              Padding(padding: const EdgeInsets.all(10)),
              Table(

                  columnWidths: {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1.5),

                  },

                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(width: 1.0),
                  children: [
                    TableRow(children: [

                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Date created",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Patient/Transaction",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Debit",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Credit",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Balance",
                              style: TextStyle(fontWeight: FontWeight.bold)))
                    ]),
                    ...entries
                        .map((item) => new TableRow(children: [

                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(item.patientName == "رصيد مدور" ? "":item.createdAt.substring(0, 10))),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                        item.patientName == "رصيد افتتاحي"
                                            ? "رصيد مدور"
                                            : item.patientName,
                                        style: TextStyle(font: ttf),textAlign: TextAlign.right),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                      item.debit == "N/A" ? "" : item.debit)),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                      item.credit == "N/A" ? "" : item.credit)),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(item.balance))
                            ]))
                        .toList()
                  ]),
            ]));
    Directory tempDir = await getExternalStorageDirectory();
    File file = File("${tempDir.path}/MOSAIC.pdf");
    print("file created");
    await file.writeAsBytes(pdf.save());
    print("file written");
    file.open();
    OpenFile.open(file.path);
    print(file.path);
  }
}
