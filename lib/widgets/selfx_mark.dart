import 'package:flutter/material.dart';

const selfxLogoAsset = 'assets/images/mainlogo.png';

class SelfxMark extends StatelessWidget {
  const SelfxMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            selfxLogoAsset,
            width: compact ? 32 : 40,
            height: compact ? 32 : 40,
            fit: BoxFit.contain,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          const Text(
            'SELFX POS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ],
    );
  }
}
