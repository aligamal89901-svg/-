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
        return GestureDetector(
          onTap: () => TerminalPairingSheet.show(context),
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isConnected ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? 'المحرك نشط' : 'ربط Termux ⚡',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? const Color(0xFF1B5E20) : const Color(0xFFBF360C),
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
