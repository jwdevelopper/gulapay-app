import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/whatsapp.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_form_page.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import 'package:my_app_teste/modules/cliente/widgets/detalhe/cartoes_detalhe_cliente.dart';

/// Detalhe de um cliente: perfil, contato, endereço e a troca de situação.
///
/// Cuida de navegação e das ações; o que a tela mostra vive em
/// `widgets/detalhe/cartoes_detalhe_cliente.dart`.
///
/// Devolve `true` ao fechar quando algo mudou, para a listagem recarregar.
class ClienteDetalhesPage extends StatelessWidget {
  final ClienteResponse cliente;

  const ClienteDetalhesPage({super.key, required this.cliente});

  bool get _ativo => cliente.ativo ?? true;

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _editar(BuildContext context) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
    // Fecha o detalhe: os dados exibidos aqui vieram da listagem e agora
    // estão desatualizados.
    if (salvou == true && context.mounted) Navigator.pop(context, true);
  }

  Future<void> _inativar(BuildContext context) async {
    final confirmou = await AppDialogoConfirmacao.mostrar(
      context,
      titulo: 'Inativar cliente',
      mensagem:
          'Deseja inativar este cliente? Ele não aparecerá mais nas buscas '
          'ativas, mas o histórico de pedidos será preservado.',
      rotuloConfirmar: 'Inativar',
      tom: TomConfirmacao.destrutivo,
    );
    if (confirmou != true || !context.mounted) return;

    await _executar(
      context,
      acao: () => inativarCliente(cliente.id!),
      sucesso: 'Cliente "${cliente.nome ?? ''}" inativado.',
      falha: 'Erro ao inativar',
    );
  }

  Future<void> _reativar(BuildContext context) async {
    final confirmou = await AppDialogoConfirmacao.mostrar(
      context,
      titulo: 'Ativar cliente',
      mensagem: 'Deseja reativar "${cliente.nome ?? 'este cliente'}"?',
      rotuloConfirmar: 'Ativar',
      tom: TomConfirmacao.positivo,
      icone: Icons.person_add_alt_1_rounded,
    );
    if (confirmou != true || !context.mounted) return;

    await _executar(
      context,
      acao: () => reativarCliente(cliente.id!, cliente),
      sucesso: 'Cliente "${cliente.nome ?? ''}" reativado.',
      falha: 'Erro ao reativar',
    );
  }

  /// Roda a ação de mudança de situação, avisa o resultado e fecha a tela
  /// devolvendo `true` — para a listagem saber que precisa recarregar.
  Future<void> _executar(
    BuildContext context, {
    required Future<void> Function() acao,
    required String sucesso,
    required String falha,
  }) async {
    try {
      await acao();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sucesso), backgroundColor: AppTema.sucesso),
      );
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$falha: ${e.message}'),
          backgroundColor: AppTema.erro,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    appBar: AppBar(
      backgroundColor: AppTema.fundo,
      foregroundColor: AppTema.texto,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTema.primariaEscura),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Detalhes do cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTema.texto,
            ),
          ),
          Text(
            _ativo ? 'Cadastro · Ativo' : 'Cadastro · Inativo',
            style: const TextStyle(
              fontSize: 12,
              color: AppTema.textoSecundario,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Editar cliente',
          icon: const FaIcon(
            FontAwesomeIcons.penToSquare,
            size: 18,
            color: AppTema.primariaEscura,
          ),
          onPressed: () => _editar(context),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PerfilCliente(cliente: cliente),
        const SizedBox(height: 12),
        ContatoCliente(
          cliente: cliente,
          aoAbrirWhatsApp: () => abrirWhatsApp(
            context,
            telefone: cliente.telefone,
            linkPronto: cliente.linkWhatsApp,
          ),
        ),
        if (cliente.endereco != null) ...[
          const SizedBox(height: 12),
          EnderecoDoCliente(endereco: cliente.endereco!),
        ],
        const SizedBox(height: 24),
        _botaoSituacao(context),
      ],
    ),
  );

  /// Um botão só, que troca de papel conforme a situação — inativar um
  /// cliente ativo, reativar um inativo.
  Widget _botaoSituacao(BuildContext context) {
    final cor = _ativo ? AppTema.erro : AppTema.sucesso;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        side: BorderSide(color: cor),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: FaIcon(
        _ativo ? FontAwesomeIcons.userSlash : FontAwesomeIcons.userCheck,
        size: 16,
      ),
      label: Text(
        _ativo ? 'Inativar cliente' : 'Ativar cliente',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: () => _ativo ? _inativar(context) : _reativar(context),
    );
  }
}
