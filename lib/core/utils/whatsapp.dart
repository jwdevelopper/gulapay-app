import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre a conversa do WhatsApp com o cliente.
///
/// O link é resolvido nesta ordem:
///
///  1. [telefone], normalizado para o formato `wa.me` — descarta tudo que
///     não é dígito e prefixa `55` quando o número tem até 11 dígitos
///     (ou seja, veio sem DDI);
///  2. [linkPronto] (o `linkWhatsApp` que o backend devolve), usado como
///     está se já for uma URL, ou normalizado se vier como telefone.
///
/// Avisa o usuário por `SnackBar` quando não há telefone, quando o
/// dispositivo não consegue abrir o link, ou quando o lançamento falha.
///
/// Antes essa lógica vivia inline no `onTap` do cartão de resumo da
/// comanda — ~90 linhas dentro da árvore de widgets.
///
/// ```dart
/// await abrirWhatsApp(
///   context,
///   telefone: comanda.clienteTelefone,
///   linkPronto: comanda.linkWhatsApp,
/// );
/// ```
Future<void> abrirWhatsApp(
  BuildContext context, {
  String? telefone,
  String? linkPronto,
}) async {
  final link = montarLinkWhatsApp(telefone: telefone, linkPronto: linkPronto);

  if (link == null) {
    _avisar(context, 'Telefone do cliente não disponível.');
    return;
  }

  try {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (abriu) return;
      debugPrint('launchUrl devolveu false para $uri');
    } else {
      debugPrint('canLaunchUrl devolveu false para $uri');
    }
    if (context.mounted) {
      _avisar(
        context,
        'Não foi possível abrir o WhatsApp. '
        'Verifique se o app está instalado.',
      );
    }
  } catch (e, st) {
    debugPrint('Erro ao abrir WhatsApp para link="$link": $e\n$st');
    if (context.mounted) {
      _avisar(context, 'Erro ao abrir o WhatsApp. Veja o log para detalhes.');
    }
  }
}

/// Monta a URL `wa.me` a partir de um telefone ou de um link já pronto.
///
/// Devolve `null` quando nenhum dos dois permite formar um destino válido.
/// Exposta separadamente para poder ser testada sem `BuildContext`.
String? montarLinkWhatsApp({String? telefone, String? linkPronto}) {
  final tel = telefone?.trim();
  if (tel != null && tel.isNotEmpty) {
    final normalizado = _normalizarNumero(tel);
    if (normalizado != null) return 'https://wa.me/$normalizado';
  }

  final link = linkPronto?.trim();
  if (link == null || link.isEmpty) return null;

  // Já é uma URL? usa como está.
  final ehUrl =
      link.startsWith('http') ||
      link.contains('wa.me') ||
      link.startsWith('whatsapp:');
  if (ehUrl) return link;

  final normalizado = _normalizarNumero(link);
  return normalizado == null ? null : 'https://wa.me/$normalizado';
}

/// Mantém só os dígitos e prefixa o DDI do Brasil quando ausente.
String? _normalizarNumero(String bruto) {
  final digitos = bruto.replaceAll(RegExp(r'\D'), '');
  if (digitos.isEmpty) return null;
  return digitos.length <= 11 ? '55$digitos' : digitos;
}

void _avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
}
