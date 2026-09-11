import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/dto/validacao_categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';

/// Cadastro e edição de categoria.
///
/// Cuida de estado e envio; as regras vivem em [ValidadorCategoria].
///
/// O formulário não mexe em `ativo`: inativar e reativar são ações da
/// listagem, com confirmação própria.
class CategoriaFormPage extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormPage({super.key, this.categoria});

  bool get ehEdicao => categoria != null;

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  final _servico = CategoriaService();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();

  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final categoria = widget.categoria;
    if (categoria != null) {
      _nome.text = categoria.nome;
      _descricao.text = categoria.descricao ?? '';
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final erroValidacao = ValidadorCategoria.validarNome(_nome.text);
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    final categoria = ValidadorCategoria.montar(
      nome: _nome.text,
      descricao: _descricao.text,
      base: widget.categoria,
    );

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      if (widget.ehEdicao) {
        await _servico.atualizar(widget.categoria!.id!, categoria);
      } else {
        await _servico.criar(categoria);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

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
          Text(
            widget.ehEdicao ? 'Editar categoria' : 'Nova categoria',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTema.texto,
            ),
          ),
          const Text(
            'Cardápio · Identidade',
            style: TextStyle(fontSize: 12, color: AppTema.textoSecundario),
          ),
        ],
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          AppRotulo(
            'Nome',
            contador:
                '${_nome.text.length}/${ValidadorCategoria.nomeTamanhoMaximo}',
          ),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _nome,
            dica: 'Ex.: Pratos principais',
            tamanhoMax: ValidadorCategoria.nomeTamanhoMaximo,
            aoMudar: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AppRotulo(
            'Descrição',
            opcional: true,
            contador:
                '${_descricao.text.length}/'
                '${ValidadorCategoria.descricaoTamanhoMaximo}',
          ),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _descricao,
            dica: 'Detalhes, ingredientes, acompanhamentos…',
            tamanhoMax: ValidadorCategoria.descricaoTamanhoMaximo,
            aoMudar: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const AppDica(
            'Use um nome curto e claro. A descrição aparece no cardápio '
            'digital para o cliente.',
          ),
          if (_erro != null) ...[
            const SizedBox(height: 14),
            AppCartaoAviso.erro(_erro),
          ],
        ],
      ),
    ),
    bottomNavigationBar: AppBarraAcoes(
      textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
      carregando: _salvando,
      aoCancelar: () => Navigator.pop(context, false),
      aoConfirmar: _salvar,
    ),
  );
}
