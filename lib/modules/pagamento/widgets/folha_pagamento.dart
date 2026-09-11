import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/pagamento/dto/forma_pagamento.dart';

/// O que o usuário escolheu na folha de pagamento.
class EscolhaPagamento {
  final String formaPagamento;
  final double valor;

  const EscolhaPagamento({required this.formaPagamento, required this.valor});
}

/// Abre a folha de registro de pagamento.
///
/// Devolve `null` se o usuário fechar sem confirmar.
///
/// [saldoRestante] é o que ainda falta receber — não o total da comanda.
/// Numa conta dividida, o segundo pagamento precisa partir do que sobrou,
/// e o backend recusa valor acima disso: não há troco no MVP.
Future<EscolhaPagamento?> abrirFolhaPagamento(
  BuildContext context, {
  required double saldoRestante,
  required double totalDevido,
  required double totalPago,
}) => showModalBottomSheet<EscolhaPagamento>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _FolhaPagamento(
    saldoRestante: saldoRestante,
    totalDevido: totalDevido,
    totalPago: totalPago,
  ),
);

class _FolhaPagamento extends StatefulWidget {
  final double saldoRestante;
  final double totalDevido;
  final double totalPago;

  const _FolhaPagamento({
    required this.saldoRestante,
    required this.totalDevido,
    required this.totalPago,
  });

  @override
  State<_FolhaPagamento> createState() => _FolhaPagamentoState();
}

class _FolhaPagamentoState extends State<_FolhaPagamento> {
  late final _valor = TextEditingController(
    // Já vem com o saldo restante: o caso comum é quitar de uma vez.
    text: formatarNumeroBr(widget.saldoRestante),
  );
  String _forma = formasPagamento.first.valor;
  String? _erro;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  void _confirmar() {
    final valor = parseNumeroBr(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe o valor recebido.');
      return;
    }
    if (valor > widget.saldoRestante) {
      setState(
        () => _erro =
            'O valor passa do que falta receber '
            '(${formatarMoedaBr(widget.saldoRestante)}). Não há troco: '
            'informe o valor exato.',
      );
      return;
    }
    Navigator.pop(
      context,
      EscolhaPagamento(formaPagamento: _forma, valor: valor),
    );
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: 0.82,
    child: Container(
      decoration: const BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Alca(),
              const SizedBox(height: 18),
              const Text(
                'Registrar pagamento',
                style: TextStyle(
                  color: AppTema.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _resumo(),
              const SizedBox(height: 18),
              const AppRotuloCampo('Forma de pagamento', obrigatorio: true),
              const SizedBox(height: 8),
              Expanded(child: _listaDeFormas()),
              const SizedBox(height: 12),
              const AppRotuloCampo('Valor recebido', obrigatorio: true),
              const SizedBox(height: 8),
              AppCampoFormulario(
                controlador: _valor,
                dica: '0,00',
                preco: true,
                tipoTeclado: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                formatadores: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                aoAlterar: (_) => setState(() => _erro = null),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                AppCartaoAviso.erro(_erro),
              ],
              const SizedBox(height: 14),
              _botaoConfirmar(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _resumo() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTema.superficieAlt,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTema.borda),
    ),
    child: Column(
      children: [
        AppLinhaResumo(
          rotulo: 'Total da comanda',
          valor: formatarMoedaBr(widget.totalDevido),
        ),
        if (widget.totalPago > 0) ...[
          const SizedBox(height: 6),
          AppLinhaResumo(
            rotulo: 'Já pago',
            valor: formatarMoedaBr(widget.totalPago),
          ),
        ],
        const SizedBox(height: 6),
        AppLinhaResumo(
          rotulo: 'Falta receber',
          valor: formatarMoedaBr(widget.saldoRestante),
        ),
      ],
    ),
  );

  Widget _listaDeFormas() => ListView.separated(
    itemCount: formasPagamento.length,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (_, i) {
      final opcao = formasPagamento[i];
      final selecionada = opcao.valor == _forma;
      return AppItemSelecionavel(
        selecionado: selecionada,
        aoTocar: () => setState(() => _forma = opcao.valor),
        filho: Row(
          children: [
            Icon(
              opcao.icone,
              color: selecionada ? AppTema.primaria : AppTema.textoSecundario,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opcao.rotulo,
                    style: const TextStyle(
                      color: AppTema.texto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    opcao.descricao,
                    style: const TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selecionada)
              const Icon(Icons.check_rounded, color: AppTema.primaria),
          ],
        ),
      );
    },
  );

  Widget _botaoConfirmar() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _confirmar,
      icon: const Icon(Icons.check_rounded),
      label: const Text('Confirmar pagamento'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

class _Alca extends StatelessWidget {
  const _Alca();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTema.bordaSuave,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}
