// lib/modules/cliente/page/cliente_detalhe_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import '../dto/cliente_response.dart';
import 'cliente_form_page.dart';

class ClienteDetalhesPage extends StatelessWidget {
  final ClienteResponse cliente;

  const ClienteDetalhesPage({super.key, required this.cliente});

  void _confirmarInativacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation,
                color: AppTema.primaria, size: 20),
            SizedBox(width: 10),
            Text('Inativar cliente',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppTema.textoEscuro)),
          ],
        ),
        content: const Text(
          'Deseja inativar este cliente? Ele não aparecerá mais nas buscas ativas, '
          'mas o histórico de pedidos será preservado.',
          style: TextStyle(color: AppTema.textoEscuro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style:
                TextButton.styleFrom(foregroundColor: AppTema.textoSecundario),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                await inativarCliente(cliente.id!);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Cliente "${cliente.nome ?? ''}" inativado com sucesso.'),
                    backgroundColor: const Color(0xFF2E8B57),
                  ),
                );
                Navigator.pop(context, true);
              } on ApiError catch (e) {
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao inativar: ${e.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
  }

  void _confirmarReativacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.userCheck,
                color: AppTema.primaria, size: 20),
            SizedBox(width: 10),
            Text('Ativar cliente',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppTema.textoEscuro)),
          ],
        ),
        content: Text(
          'Deseja reativar "${cliente.nome ?? 'este cliente'}"?',
          style: const TextStyle(color: AppTema.textoEscuro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style:
                TextButton.styleFrom(foregroundColor: AppTema.textoSecundario),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                await reativarCliente(cliente.id!, cliente);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Cliente "${cliente.nome ?? ''}" reativado com sucesso.'),
                    backgroundColor: const Color(0xFF2E8B57),
                  ),
                );
                Navigator.pop(context, true);
              } on ApiError catch (e) {
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao reativar: ${e.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAtivo = cliente.ativo ?? true;

    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detalhes do cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            Text(
              isAtivo ? 'Cadastro · Ativo' : 'Cadastro · Inativo',
              style:
                  const TextStyle(fontSize: 12, color: AppTema.textoSecundario),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.penToSquare,
                size: 18, color: AppTema.primariaEscura),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ClienteFormPage(cliente: cliente),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardPerfil(isAtivo),
            const SizedBox(height: 12),
            _buildCardContato(),
            if (cliente.endereco != null) ...[
              const SizedBox(height: 12),
              _buildCardEndereco(),
            ],
            const SizedBox(height: 24),
            if (isAtivo)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade600),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const FaIcon(FontAwesomeIcons.userSlash, size: 16),
                label: const Text('Inativar cliente',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => _confirmarInativacao(context),
              )
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E8B57),
                  side: const BorderSide(color: Color(0xFF2E8B57)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const FaIcon(FontAwesomeIcons.userCheck, size: 16),
                label: const Text('Ativar cliente',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => _confirmarReativacao(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPerfil(bool isAtivo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTema.bordaCampo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTema.fundoDica,
            child: Text(
              ((cliente.nome?.trim().isNotEmpty ?? false)
                      ? cliente.nome!.trim().characters.first
                      : '?')
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTema.primaria,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nome ?? 'Sem nome',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTema.textoEscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cliente.email ?? 'E-mail não informado',
                  style: const TextStyle(
                      fontSize: 13, color: AppTema.textoSecundario),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (!isAtivo)
                      AppTag(
                        'Inativo',
                        fundo: Colors.red.shade100,
                        cor: Colors.red.shade800,
                      )
                    else
                      AppTag(
                        'Ativo',
                        fundo: Colors.green.shade100,
                        cor: Colors.green.shade800,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContato() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTema.bordaCampo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildLinha(
            icone: const FaIcon(FontAwesomeIcons.whatsapp, size: 16, color: Colors.green),
            rotulo: 'WhatsApp',
            valor: cliente.telefone ?? 'Não informado',
          ),
          if (cliente.email != null && cliente.email!.isNotEmpty) ...[
            Divider(height: 1, color: AppTema.bordaCampo),
            _buildLinha(
              icone: const FaIcon(FontAwesomeIcons.envelope, size: 16, color: AppTema.primariaEscura),
              rotulo: 'E-mail',
              valor: cliente.email!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardEndereco() {
    final e = cliente.endereco!;
    final linhas = [
      if ((e.logradouro ?? '').isNotEmpty)
        '${e.logradouro}${(e.numero ?? '').isNotEmpty ? ', ${e.numero}' : ''}',
      if ((e.complemento ?? '').isNotEmpty) e.complemento!,
      if ((e.bairro ?? '').isNotEmpty) e.bairro!,
      if ((e.cidade ?? '').isNotEmpty)
        '${e.cidade}${(e.uf ?? '').isNotEmpty ? ' - ${e.uf}' : ''}',
      if ((e.cep ?? '').isNotEmpty) 'CEP ${e.cep}',
    ];

    if (linhas.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTema.bordaCampo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FaIcon(FontAwesomeIcons.locationDot,
              size: 16, color: AppTema.primariaEscura),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Endereço',
                    style: TextStyle(
                        fontSize: 12, color: AppTema.textoSecundario)),
                const SizedBox(height: 4),
                ...linhas.map((l) => Text(l,
                    style: const TextStyle(color: AppTema.textoEscuro))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinha({
    required Widget icone,
    required String rotulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          icone,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo,
                    style: const TextStyle(
                        fontSize: 11, color: AppTema.textoSecundario)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTema.textoEscuro)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
