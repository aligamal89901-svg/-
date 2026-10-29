import 'package:flutter/material.dart';
import 'package:nasaq/core/services/terminal_link_service.dart';
import 'package:nasaq/widgets/terminal_pairing_sheet.dart';

class TerminalStatusBadge extends StatefulWidget {
  const TerminalStatusBadge({super.key});

  @override
  State<TerminalStatusBadge> createState() => _TerminalStatusBadgeState();
}

class _TerminalStatusBadgeState extends State<TerminalStatusBadge> {
  @override
  void initState() {
    super.initState();
    TerminalLinkService.instance.checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TerminalLinkService.instance,
      builder: (context, _) {
        final isConnected = TerminalLinkService.instance.isOnline;
        return InkWell(
          onTap: () => TerminalPairingSheet.show(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConnected ? const Color(0xFF81C784) : const Color(0xFFE57373),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? 'المحرك نشط' : 'ربط Termux',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
