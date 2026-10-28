import 'package:flutter/material.dart';
import 'sandbox_stub.dart' if (dart.library.html) 'sandbox_web.dart';

class LiveHtmlSandbox extends StatelessWidget {
  final String code;
  final String sandboxId;

  const LiveHtmlSandbox({
    super.key,
    required this.code,
    required this.sandboxId,
  });

  @override
  Widget build(BuildContext context) {
    return buildPlatformSandbox(
      htmlContent: code,
      uniqueId: sandboxId,
    );
  }
}
