/// As quatro etapas do formulário de abertura de comanda.
///
/// Extraídas de `comanda_form_page.dart`. São pequenas o bastante para
/// conviverem num arquivo — cada uma é só a composição de peças já
/// existentes.
///
///  * [EtapaCanal] — escolha do canal de venda;
///  * [EtapaCliente] — quem está pedindo;
///  * [EtapaDados] — mesa/garçom/escopo ou endereço, conforme o canal;
///  * [EtapaRevisao] — resumo e observação.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/comanda/dto/opcoes_comanda.dart';
import 'package:my_app_teste/modules/comanda/dto/validacao_comanda.dart';
import 'package:my_app_teste/modules/comanda/widgets/comanda_search_selector.dart';
import 'package:my_app_teste/modules/comanda/widgets/form/cartoes_comanda.dart';

/// Etapa 1 — canal da venda. Define o que as etapas seguintes exigem.
class EtapaCanal extends StatelessWidget {
  final String canalSelecionado;
  final ValueChanged<String> aoSelecionar;

  const EtapaCanal({
    super.key,
    required this.canalSelecionado,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TituloEtapa(
        'Como será esta venda?',
        'Escolha o canal para configurar os próximos dados.',
      ),
      const SizedBox(height: 18),
      for (final opcao in canaisComanda)
        CartaoCanal(
          opcao: opcao,
          selecionado: opcao.valor == canalSelecionado,
          aoTocar: () => aoSelecionar(opcao.valor),
        ),
      const SizedBox(height: 8),
      const AppCartaoAviso.dica(
        'O canal define quais informações serão obrigatórias para abrir a '
        'comanda.',
      ),
    ],
  );
}

/// Etapa 2 — cliente. Obrigatório em todos os canais (RF20).
class EtapaCliente extends StatelessWidget {
  final DadosComanda dados;
  final String? mensagemErro;
  final VoidCallback aoAbrirCliente;

  const EtapaCliente({
    super.key,
    required this.dados,
    required this.mensagemErro,
    required this.aoAbrirCliente,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TituloEtapa(
        'Quem está fazendo o pedido?',
        'Selecione o cliente vinculado a esta comanda.',
      ),
      const SizedBox(height: 18),
      CampoSeletorComanda(
        rotulo: 'Cliente *',
        valor: dados.cliente?.nome ?? '',
        detalhe: dados.cliente?.telefone,
        icone: Icons.person_outline_rounded,
        aoTocar: aoAbrirCliente,
        erro: mensagemErro != null && dados.cliente == null,
      ),
      const SizedBox(height: 14),
      if (dados.cliente != null) CartaoCliente(cliente: dados.cliente!),
      if (mensagemErro != null) ...[
        const SizedBox(height: 14),
        AppCartaoAviso.erro(mensagemErro),
      ],
    ],
  );
}

/// Etapa 3 — dados da venda. O conteúdo muda conforme o canal: `MESA` pede
/// mesa, garçom e escopo; `DELIVERY` confirma cliente e endereço; `BALCAO`
/// só confirma o cliente.
class EtapaDados extends StatelessWidget {
  final DadosComanda dados;
  final String rotuloMesa;
  final String rotuloGarcom;
  final String? mensagemErro;
  final VoidCallback aoAbrirMesa;
  final VoidCallback aoAbrirGarcom;
  final VoidCallback aoAbrirEscopo;

  const EtapaDados({
    super.key,
    required this.dados,
    required this.rotuloMesa,
    required this.rotuloGarcom,
    required this.mensagemErro,
    required this.aoAbrirMesa,
    required this.aoAbrirGarcom,
    required this.aoAbrirEscopo,
  });

  @override
  Widget build(BuildContext context) {
    final temErro = mensagemErro != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloEtapa(
          dados.ehMesa ? 'Configure a mesa' : 'Informe os dados',
          'Preencha as informações necessárias para esta comanda.',
        ),
        const SizedBox(height: 18),
        if (dados.ehMesa) ...[
          CampoSeletorComanda(
            rotulo: 'Mesa *',
            valor: dados.mesaId == null ? '' : rotuloMesa,
            icone: Icons.table_restaurant_rounded,
            aoTocar: aoAbrirMesa,
            erro: temErro && dados.mesaId == null,
          ),
          const SizedBox(height: 18),
          CampoSeletorComanda(
            rotulo: 'Garçom responsável *',
            valor: dados.garcomId == null ? '' : rotuloGarcom,
            icone: Icons.person_outline_rounded,
            aoTocar: aoAbrirGarcom,
            erro: temErro && dados.garcomId == null,
          ),
          const SizedBox(height: 18),
          CampoSeletorComanda(
            rotulo: 'Tipo de comanda',
            valor: rotuloEscopo(dados.escopo),
            icone: Icons.group_outlined,
            aoTocar: aoAbrirEscopo,
          ),
        ],
        if (dados.ehDelivery) ...[
          if (dados.cliente != null) CartaoCliente(cliente: dados.cliente!),
          const SizedBox(height: 10),
          CartaoEndereco(cliente: dados.cliente),
        ],
        if (dados.tipo == DadosComanda.canalBalcao && dados.cliente != null)
          CartaoCliente(cliente: dados.cliente!),
        if (temErro) ...[
          const SizedBox(height: 14),
          AppCartaoAviso.erro(mensagemErro),
        ],
      ],
    );
  }
}

/// Etapa 4 — revisão e observação livre.
class EtapaRevisao extends StatelessWidget {
  final DadosComanda dados;
  final String rotuloMesa;
  final String rotuloGarcom;
  final TextEditingController controladorObservacao;

  const EtapaRevisao({
    super.key,
    required this.dados,
    required this.rotuloMesa,
    required this.rotuloGarcom,
    required this.controladorObservacao,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TituloEtapa(
        'Revise sua comanda',
        'Confira os dados antes de abrir a venda.',
      ),
      const SizedBox(height: 18),
      _resumo(),
      const SizedBox(height: 18),
      const AppRotuloCampo('Observação'),
      const SizedBox(height: 8),
      AppCampoFormulario(
        controlador: controladorObservacao,
        dica: 'Ex.: sem cebola, separar bebidas',
        maxLinhas: 4,
      ),
    ],
  );

  Widget _resumo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTema.borda),
    ),
    child: Column(
      children: [
        AppLinhaResumo(rotulo: 'Canal', valor: rotuloDaOpcaoCanal(dados.tipo)),
        if (dados.mesaId != null)
          AppLinhaResumo(rotulo: 'Mesa', valor: rotuloMesa),
        if (dados.garcomId != null)
          AppLinhaResumo(rotulo: 'Garçom', valor: rotuloGarcom),
        if (dados.cliente != null)
          AppLinhaResumo(
            rotulo: 'Cliente',
            valor: dados.cliente!.nome ?? 'Cliente',
          ),
        if (dados.ehMesa)
          AppLinhaResumo(rotulo: 'Escopo', valor: rotuloEscopo(dados.escopo)),
      ],
    ),
  );
}

/// Rótulo amigável do escopo da comanda.
String rotuloEscopo(String escopo) =>
    escopo == DadosComanda.escopoCompartilhada ? 'Compartilhada' : 'Individual';

/// Rótulo amigável do canal, a partir das opções cadastradas.
String rotuloDaOpcaoCanal(String valor) {
  for (final opcao in canaisComanda) {
    if (opcao.valor == valor) return opcao.rotulo;
  }
  return valor;
}
