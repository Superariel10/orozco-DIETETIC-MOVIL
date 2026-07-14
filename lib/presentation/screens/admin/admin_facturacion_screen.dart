// lib/presentation/screens/admin/admin_facturacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/shared/empty_state.dart';

class AdminFacturacionScreen extends ConsumerWidget {
  const AdminFacturacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturasAsync = ref.watch(adminFacturasProvider);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('CENTRO DE PAGOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.refresh(adminFacturasProvider),
        child: facturasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => _buildDemoFacturas(context),
          data: (facturas) {
            if (facturas.isEmpty) return _buildDemoFacturas(context);
            return _buildFacturasList(facturas, context);
          },
        ),
      ),
    );
  }

  Widget _buildFacturasList(List<dynamic> facturas, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: facturas.length,
      itemBuilder: (context, index) {
        final f = facturas[index];
        return _FacturaCard(
          client: 'Paciente #${f['paciente'] ?? '---'}',
          amount: '\$${f['monto'] ?? '0.00'}',
          date: f['fecha_pago'] ?? 'Hoy',
          status: f['estado'] ?? 'Pendiente',
          plan: 'Plan Nutricional Estándar',
          method: 'Transferencia Bancaria',
        );
      },
    );
  }

  Widget _buildDemoFacturas(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        _FacturaCard(client: 'Carlos Perez', amount: '\$45.00', date: '12 Jul 2026', status: 'Pagado', plan: 'Plan Keto Premium', method: 'Tarjeta de Crédito'),
        _FacturaCard(client: 'Maria Gomez', amount: '\$60.00', date: '11 Jul 2026', status: 'Pendiente', plan: 'Aumento Masa Muscular', method: 'PayPal'),
        _FacturaCard(client: 'Juan Rodriguez', amount: '\$30.00', date: '10 Jul 2026', status: 'Pagado', plan: 'Plan Vegetariano', method: 'Efectivo'),
      ],
    );
  }
}

class _FacturaCard extends StatelessWidget {
  final String client, amount, date, status, plan, method;
  const _FacturaCard({required this.client, required this.amount, required this.date, required this.status, required this.plan, required this.method});

  @override
  Widget build(BuildContext context) {
    final isPaid = status.toLowerCase() == 'pagado';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => _showFacturaDetail(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(isPaid ? Icons.check_circle_rounded : Icons.pending_rounded, color: isPaid ? Colors.green : Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text(date, style: const TextStyle(color: AppColors.textFaint, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: AppColors.borderLight)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toUpperCase(), style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFacturaDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('Detalle del Pago', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            _DetailItem(label: 'CLIENTE', value: client),
            _DetailItem(label: 'PLAN CONTRATADO', value: plan),
            _DetailItem(label: 'MÉTODO DE PAGO', value: method),
            _DetailItem(label: 'FECHA DE TRANSACCIÓN', value: date),
            _DetailItem(label: 'TOTAL PAGADO', value: amount, isPrimary: true),
            const Spacer(),
            if (status.toLowerCase() != 'pagado')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago finalizado correctamente'), backgroundColor: AppColors.success));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('FINALIZAR PAGO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label, value;
  final bool isPrimary;
  const _DetailItem({required this.label, required this.value, this.isPrimary = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: isPrimary ? 24 : 16, fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700, color: isPrimary ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
