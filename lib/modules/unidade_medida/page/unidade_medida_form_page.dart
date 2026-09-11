import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_base.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/validacao_unidade.dart';
import 'package:my_app_teste/modules/unidade_medida/widgets/atalhos_unidade_base.dart';
import 'package:my_app_teste/modules/unidade_medida/service/unidade_medida_service.dart';
import 'package:my_app_teste/modules/unidade_medida/widgets/seletor_tipo_medida.dart';

/// Cadastro e edição de unidade de medida.
///
/// Cuida de estado e envio; as regras vivem em [ValidadorUnidade] e a
/// escolha do tipo em [SeletorTipoMedida].
///
/// Na edição, tipo e fator aparecem travados: mudá-los reinterpretaria em
/// silêncio todo saldo já gravado naquela unidade. Para corrigir um fator
/// errado, o caminho é inativar a unidade e criar outra.
class UnidadeMedidaFormPage extends StatefulWidget {
  final UnidadeMedidaResponse? unidade;

  const UnidadeMedidaFormPage({super.key, this.unidade});

  bool get ehEdicao => unidade != null;

  @override
  State<UnidadeMedidaFormPage> createState() => _UnidadeMedidaFormPageState();
}

class _UnidadeMedidaFormPageState extends State<UnidadeMedidaFormPage> {
  final _nome = TextEditingController();
  final _simbolo = TextEditingController();
  final _fator = TextEditingController();

  DadosUnidade _dados = const DadosUnidade();
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final unidade = widget.unidade;
    if (unidade != null) {
      _nome.text = unidade.nome ?? '';
      _simbolo.text = unidade.simbolo ?? '';
      _fator.text = formatarNumeroBr(
        unidade.fatorParaBase,
        casas: null,
        vazio: '',
      );
      _dados = DadosUnidade(
        tipoMedida: unidade.tipoMedida,
        ativo: unidade.ativo ?? true,
      );
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _simbolo.dispose();
    _fator.dispose();
    super.dispose();
  }

  /// Preenche o formulário inteiro a partir de uma unidade conhecida.
  ///
  /// Escrever os quatro campos de uma vez é o ponto do atalho: evita que
  /// alguém cadastre "Quilograma" com fator 1, o que faria o sistema tratar
  /// quilo como grama em toda conversão.
  void _aplicarAtalho(UnidadeBase base) {
    final dados = base.aplicarEm(_dados);
    _nome.text = dados.nome;
    _simbolo.text = dados.simbolo;
    _fator.text = dados.fatorParaBase;
    setState(() {
      _dados = _dados.copiarCom(tipoMedida: dados.tipoMedida);
      _erro = null;
    });
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  /// Junta o que está nos controllers ao que está em [_dados].
  DadosUnidade get _dadosCompletos => _dados.copiarCom(
    nome: _nome.text,
    simbolo: _simbolo.text,
    fatorParaBase: _fator.text,
  );

  Future<void> _salvar() async {
    final dados = _dadosCompletos;
    final erroValidacao = ValidadorUnidade.validar(
      dados,
      ehEdicao: widget.ehEdicao,
    );
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      if (widget.ehEdicao) {
        await editarUnidadeMedida(widget.unidade!.id!, dados.paraEdicao());
      } else {
        await criarUnidadeMedida(dados.paraCriacao());
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
      title: Text(
        widget.ehEdicao ? 'Editar unidade' : 'Nova unidade',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTema.texto,
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          // Só na criação: em edição o tipo e o fator são imutáveis, então
          // um atalho que os preenchesse não teria efeito.
          if (!widget.ehEdicao) ...[
            AtalhosUnidadeBase(
              simboloAtual: _simbolo.text,
              aoEscolher: _aplicarAtalho,
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTema.borda),
            const SizedBox(height: 12),
          ],
          const AppRotulo('Nome'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _nome,
            dica: 'Ex.: Quilograma',
            tamanhoMax: ValidadorUnidade.nomeTamanhoMaximo,
          ),
          const SizedBox(height: 14),
          const AppRotulo('Símbolo'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _simbolo,
            dica: 'Ex.: kg, mL, csp',
            tamanhoMax: ValidadorUnidade.simboloTamanhoMaximo,
            // Redesenha para o atalho correspondente acender (ou apagar)
            // conforme o símbolo digitado.
            aoMudar: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTema.borda),
          const SizedBox(height: 12),
          _tituloSecao(Icons.straighten_rounded, 'Tipo de medida *'),
          const SizedBox(height: 12),
          SeletorTipoMedida(
            selecionado: _dados.tipoMedida,
            habilitado: !widget.ehEdicao,
            aoSelecionar: (tipo) => setState(() {
              _dados = _dados.copiarCom(tipoMedida: tipo);
              _erro = null;
            }),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTema.borda),
          const SizedBox(height: 12),
          _tituloSecao(Icons.calculate_outlined, 'Fator para a base *'),
          const SizedBox(height: 8),
          AppCampoTexto(
            controle: _fator,
            dica: 'Ex.: 1000',
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            formatadores: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            habilitado: !widget.ehEdicao,
          ),
          const SizedBox(height: 12),
          AppDica(
            widget.ehEdicao
                ? 'Tipo e fator são fixos após o cadastro — alterá-los mudaria '
                      'o significado de todo saldo já gravado nesta unidade. '
                      'Para corrigir, inative esta unidade e crie outra.'
                : 'Quanto 1 unidade desta equivale à unidade base? '
                      'Ex.: 1 kg = 1000 g → fator 1000. '
                      'Use 1 para definir uma nova unidade base.',
            emoji: widget.ehEdicao ? '🔒' : '💡',
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

  Widget _tituloSecao(IconData icone, String titulo) => Row(
    children: [
      Icon(icone, size: 16, color: AppTema.primariaEscura),
      const SizedBox(width: 8),
      Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTema.texto,
        ),
      ),
    ],
  );
}
