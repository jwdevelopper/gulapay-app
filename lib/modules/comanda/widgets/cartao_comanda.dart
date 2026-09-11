import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_response.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';

/// Linha da listagem de comandas.
///
/// Mostra, da esquerda para a direita: o ícone do canal, o código da
/// comanda com quem/onde, e o total com o status colorido. Extraído do
/// `itemBuilder` da `ComandasPage`, onde era um `Card` de 80 linhas montado
/// inline.
///
/// Toda tradução de enum (canal, status, cor, dinheiro) vem de
/// [RotulosComanda] — o card não conhece os valores crus da API.
class CartaoComanda extends StatelessWidget {
  /// A comanda exibida.
  final ComandaResponse comanda;

  /// Ação ao tocar. Na listagem abre o detalhe.
  final VoidCallback aoTocar;

  const CartaoComanda({
    super.key,
    required this.comanda,
    required this.aoTocar,
  });

  /// Segunda linha: canal, cliente e mesa, quando existirem.
  String get _descricao => [
    RotulosComanda.origem(comanda.tipoOrigem),
    if (comanda.clienteNome != null) comanda.clienteNome!,
    if (comanda.mesaNumero != null) 'Mesa ${comanda.mesaNumero}',
  ].join(' • ');

  @override
  Widget build(BuildContext context) => Card(
    color: AppTema.superficie,
    elevation: 0,
    shadowColor: AppTema.sombra,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppTema.borda),
    ),
    child: ListTile(
      onTap: aoTocar,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
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
      title: Text(
        comanda.codigo.isEmpty ? 'Comanda #${comanda.id}' : comanda.codigo,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTema.texto,
        ),
      ),
      subtitle: Text(
        _descricao,
        style: const TextStyle(color: AppTema.textoSecundario, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            RotulosComanda.dinheiro(comanda.totalLiquido),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTema.texto,
            ),
          ),
          Text(
            RotulosComanda.status(comanda.status),
            style: TextStyle(
              fontSize: 11,
              color: RotulosComanda.corStatus(comanda.status),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}
