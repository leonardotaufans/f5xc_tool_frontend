import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DataTableLoading extends StatelessWidget {
  const DataTableLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        sortColumnIndex: 1,
        sortAscending: false,
        columns: [
          DataColumn(label: Expanded(child: Text('Event Type'))),
          DataColumn(label: Expanded(child: Text('Timestamp'))),
          DataColumn(label: Expanded(child: Text('Environment'))),
          DataColumn(
              label: Expanded(
                  child: Text(
                'Previous\nVersion',
                textAlign: TextAlign.center,
              )),
              numeric: true),
          DataColumn(
              label: Text('Target\nVersion', textAlign: TextAlign.center),
              numeric: true),
          DataColumn(label: Text('Description'))
        ],
        showCheckboxColumn: true,
        onSelectAll: (_) {},
        rows: [
          DataRow(cells: [
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
            DataCell(Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ShimmerContainer(),
            )),
          ]),
        ]);
  }
}

class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerContainer({super.key, this.width = 80, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)),
    );
  }
}
