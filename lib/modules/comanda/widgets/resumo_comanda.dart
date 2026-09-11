/// Cartão de resumo da comanda: código, status, canal, cliente, garçom,
/// mesa, totais e o link de WhatsApp.
///
/// Extraído de `comanda_detalhe_page.dart`, onde ocupava ~255 linhas como
/// método do `State`. É puramente visual — recebe a comanda pronta e
/// devolve as interações por callback.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/utils/whatsapp.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_response.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';

class ResumoComanda extends StatelessWidget {
  /// Comanda exibida.
  final ComandaResponse comanda;

  const ResumoComanda({super.key, required this.comanda});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTema.borda),
      boxShadow: const [
        BoxShadow(
          color: AppTema.sombraCampo,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTema.preenchimentoCampo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                RotulosComanda.iconeOrigem(comanda.tipoOrigem),
                color: AppTema.primaria,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RotulosComanda.origem(comanda.tipoOrigem),
                    style: const TextStyle(
                      color: AppTema.texto,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    comanda.clienteNome ?? 'Cliente não informado',
                    style: const TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _chipStatus(comanda.status),
          ],
        ),
        if (comanda.mesaNumero != null || comanda.garcomNome != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (comanda.mesaNumero != null)
                _pilulaInfo(
                  Icons.table_restaurant_outlined,
                  'Mesa ${comanda.mesaNumero}',
                ),
              if (comanda.garcomNome != null)
                _pilulaInfo(Icons.person_outline_rounded, comanda.garcomNome!),
            ],
          ),
        ],
        if (comanda.linkWhatsApp?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await abrirWhatsApp(
                context,
                telefone: comanda.clienteTelefone,
                linkPronto: comanda.linkWhatsApp,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTema.primaria,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('Abrir no WhatsApp'),
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: AppTema.bordaSuave),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total líquido',
              style: TextStyle(
                color: AppTema.texto,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              RotulosComanda.dinheiro(comanda.totalLiquido),
              style: const TextStyle(
                color: AppTema.primaria,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _chipStatus(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: RotulosComanda.corStatus(status).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: RotulosComanda.corStatus(status).withValues(alpha: 0.35),
      ),
    ),
    child: Text(
      status.replaceAll('_', ' '),
      style: TextStyle(
        color: RotulosComanda.corStatus(status),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _pilulaInfo(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppTema.preenchimentoCampo,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTema.textoSecundario),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTema.texto,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
