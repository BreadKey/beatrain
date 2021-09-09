import 'package:beatrain/pattern.dart';
import 'package:flutter/material.dart';

class PatternTile extends StatelessWidget {
  final void Function()? onTap;
  const PatternTile({Key? key, required this.pattern, this.onTap})
      : super(key: key);

  final Pattern pattern;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text("${pattern.keyLength}"),
        ),
        title: Text(pattern.name),
        trailing: Text("BPM: ${pattern.bpm}"),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pattern.level, (index) {
            return Icon(
              Icons.star,
              color: index < 5
                  ? Colors.green
                  : index < 10
                      ? Colors.amber
                      : Colors.deepOrange,
            );
          }),
        ),
        onTap: onTap,
      ),
    );
  }
}
