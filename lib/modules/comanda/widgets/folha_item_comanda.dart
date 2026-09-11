/// Folha de lançamento e edição de um item da comanda.
///
/// Extraída de `comanda_detalhe_page.dart`, onde ocupava ~520 linhas como
/// classe privada. Tem estado próprio (produto escolhido, quantidade,
/// descontos) e por isso não cabe num diálogo de confirmação — este é um
/// formulário.
///
/// Devolve um [ResultadoFormItem] via `Navigator.pop`, ou `null` se o
/// usuário fechar sem salvar; a página decide se chama criar ou editar.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/comanda/widgets/comanda_search_selector.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';

class ResultadoFormItem {
  const ResultadoFormItem({
    required this.produtoId,
    required this.quantidade,
    this.valorDesconto,
    this.valorAcrescimo,
    this.observacao,
  });

  final int produtoId;
  final double quantidade;
  final double? valorDesconto;
  final double? valorAcrescimo;
  final String? observacao;
}

class FolhaItemComanda extends StatefulWidget {
  const FolhaItemComanda({
    super.key,
    required this.titulo,
    this.produtoFixoNome,
    this.quantidadeInicial = 1,
    this.descontoInicial = 0,
    this.acrescimoInicial = 0,
    this.observacaoInicial,
    this.edicao = false,
  });

  final String titulo;
  final String? produtoFixoNome;
  final double quantidadeInicial;
  final double descontoInicial;
  final double acrescimoInicial;
  final String? observacaoInicial;
  final bool edicao;

  @override
  State<FolhaItemComanda> createState() => _FolhaItemComandaState();
}

class _FolhaItemComandaState extends State<FolhaItemComanda> {
  final _produtoService = ProdutoService();
  final _qtdCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _acresCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  List<Produto> _produtos = const [];
  Produto? _produto;
  bool _loading = true;
  bool _mostrarAjustes = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _qtdCtrl.text = _fmtQtd(widget.quantidadeInicial);
    _descCtrl.text = widget.descontoInicial == 0
        ? ''
        : _fmtMoney(widget.descontoInicial);
    _acresCtrl.text = widget.acrescimoInicial == 0
        ? ''
        : _fmtMoney(widget.acrescimoInicial);
    _obsCtrl.text = widget.observacaoInicial ?? '';
    _mostrarAjustes = widget.descontoInicial > 0 || widget.acrescimoInicial > 0;
    if (widget.edicao) {
      _loading = false;
    } else {
      _carregarProdutos();
    }
  }

  String _fmtMoney(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

  String _fmtQtd(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString().replaceAll('.', ',');
  }

  double? _parseDecimal(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[^\d,.]'), '');
    if (cleaned.isEmpty) return null;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      return double.tryParse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.tryParse(cleaned.replaceAll(',', '.'));
  }

  double _qtdAtual() => _parseDecimal(_qtdCtrl.text) ?? 0;

  void _ajustarQtd(double delta) {
    final atual = _qtdAtual();
    final base = atual <= 0 ? 1.0 : atual;
    final nova = (base + delta).clamp(0.001, 9999.0);
    setState(() => _qtdCtrl.text = _fmtQtd(nova));
  }

  InputDecoration _decoration(
    String label, {
    String? hint,
    String? prefix,
    String? helper,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    prefixText: prefix,
    labelStyle: const TextStyle(
      color: AppTema.textoSecundario,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: const TextStyle(color: AppTema.textoSecundario),
    helperStyle: const TextStyle(color: AppTema.textoSecundario, fontSize: 11),
    filled: true,
    fillColor: AppTema.superficieAlt,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTema.borda),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTema.borda),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTema.primaria, width: 1.5),
    ),
  );

  Widget _fieldLabel(String title, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTema.texto,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _quantidadeStepper() => Container(
    padding: const EdgeInsets.all(14),
    decoration: DecoracoesApp.campo(),
    child: Row(
      children: [
        _stepBtn(Icons.remove_rounded, () => _ajustarQtd(-1)),
        Expanded(
          child: TextField(
            controller: _qtdCtrl,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
            ],
            style: const TextStyle(
              color: AppTema.texto,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              hintText: '1',
              hintStyle: TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        _stepBtn(Icons.add_rounded, () => _ajustarQtd(1)),
      ],
    ),
  );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => Material(
    color: AppTema.preenchimentoCampo,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTema.bordaSuave),
        ),
        child: Icon(icon, color: AppTema.primaria, size: 22),
      ),
    ),
  );

  Widget _produtoCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTema.preenchimentoCampo,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTema.borda),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTema.superficie,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppTema.primaria,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.produtoFixoNome ?? 'Item',
            style: const TextStyle(
              color: AppTema.texto,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _qtdCtrl.dispose();
    _descCtrl.dispose();
    _acresCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    try {
      final lista = await _produtoService.listar(apenasAtivos: true);
      if (!mounted) return;
      setState(() {
        _produtos = lista
            .whereType<Map>()
            .map((e) => Produto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar produtos.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _abrirProduto() async {
    final produto = await abrirSeletorComBusca<Produto>(
      context: context,
      titulo: 'Escolher produto',
      itens: _produtos.where((item) => item.id != null).toList(),
      tituloItem: (item) => item.nome,
      subtituloItem: (item) => item.preco == null
          ? ''
          : 'R\$ ${item.preco!.toStringAsFixed(2).replaceAll('.', ',')}',
      icone: Icons.restaurant_rounded,
      selecionado: _produto,
    );
    if (produto != null && mounted) setState(() => _produto = produto);
  }

  void _salvar() {
    final qtd = _parseDecimal(_qtdCtrl.text);
    if (!widget.edicao && (_produto?.id == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um produto.')));
      return;
    }
    if (qtd == null || qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }
    Navigator.pop(
      context,
      ResultadoFormItem(
        produtoId: _produto?.id ?? 0,
        quantidade: qtd,
        valorDesconto: _parseDecimal(_descCtrl.text),
        valorAcrescimo: _parseDecimal(_acresCtrl.text),
        observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTema.borda,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            widget.titulo,
            style: const TextStyle(
              color: AppTema.texto,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.edicao
                ? 'Altere os dados do item'
                : 'Escolha o produto e a quantidade',
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(padding: EdgeInsets.all(32), child: AppCarregando())
          else if (_erro != null)
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTema.erro),
            )
          else ...[
            if (widget.edicao)
              _produtoCard()
            else ...[
              _fieldLabel('Produto', subtitle: 'Obrigatório'),
              CampoSeletorComanda(
                rotulo: 'Produto *',
                valor: _produto?.nome ?? '',
                detalhe: _produto?.preco == null
                    ? null
                    : 'R\$ ${_produto!.preco!.toStringAsFixed(2).replaceAll('.', ',')}',
                icone: Icons.restaurant_rounded,
                aoTocar: _abrirProduto,
              ),
            ],
            const SizedBox(height: 20),
            _fieldLabel(
              'Quantidade',
              subtitle: 'Toque nos botões ou digite o valor',
            ),
            _quantidadeStepper(),
            const SizedBox(height: 20),
            _fieldLabel('Observação', subtitle: 'Opcional'),
            TextField(
              controller: _obsCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppTema.texto, fontSize: 15),
              decoration: _decoration('Ex.: sem gelo, ponto da carne…'),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTema.superficieAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTema.borda),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _mostrarAjustes,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  iconColor: AppTema.primaria,
                  collapsedIconColor: AppTema.textoSecundario,
                  title: const Text(
                    'Ajuste de valor',
                    style: TextStyle(
                      color: AppTema.texto,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Desconto abate · acréscimo soma',
                    style: TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _descCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]'),
                              ),
                            ],
                            style: const TextStyle(
                              color: AppTema.texto,
                              fontSize: 15,
                            ),
                            decoration: _decoration(
                              'Desconto',
                              prefix: 'R\$ ',
                              hint: '0,00',
                              helper: 'Valor a menos',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _acresCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]'),
                              ),
                            ],
                            style: const TextStyle(
                              color: AppTema.texto,
                              fontSize: 15,
                            ),
                            decoration: _decoration(
                              'Acréscimo',
                              prefix: 'R\$ ',
                              hint: '0,00',
                              helper: 'Valor a mais',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTema.primaria,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.edicao ? 'Salvar alterações' : 'Adicionar à comanda',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
