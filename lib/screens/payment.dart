import 'package:flutter/material.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/widgets/custom_button.dart';

/// 1) Sélection du portefeuille
class PaymentWalletSelectionPage extends StatelessWidget {
  const PaymentWalletSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wallets = ['BankyLI', 'Sedade', 'BimBank', 'MasriVie'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choix du portefeuille'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sélectionnez votre portefeuille',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...wallets.map((wallet) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomButton(
                      text: wallet,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentMethodInputPage(
                              wallet: wallet,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.white,
                      textColor: primaryColor,
                      borderColor: primaryColor,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2) Choix du mode d'entrée et saisie du code/numéro
class PaymentMethodInputPage extends StatefulWidget {
  final String wallet;
  const PaymentMethodInputPage({required this.wallet, Key? key})
      : super(key: key);

  @override
  State<PaymentMethodInputPage> createState() => _PaymentMethodInputPageState();
}

class _PaymentMethodInputPageState extends State<PaymentMethodInputPage> {
  bool useCode = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le champ.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentValidationPage(
          wallet: widget.wallet,
          method: useCode ? 'Code' : 'Numéro',
          credential: input,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mode d\'entrée - ${widget.wallet}'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToggleButtons(
              isSelected: [useCode, !useCode],
              onPressed: (index) => setState(() => useCode = index == 0),
              borderColor: primaryColor,
              selectedBorderColor: primaryColor,
              fillColor: primaryColor.withOpacity(0.1),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Code')),
                Padding(padding: EdgeInsets.all(8), child: Text('Numéro'))
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText:
                    useCode ? 'Entrez votre code' : 'Entrez votre numéro',
                border: const OutlineInputBorder(),
              ),
              keyboardType: useCode ? TextInputType.text : TextInputType.phone,
            ),
            const Spacer(),
            CustomButton(
              text: 'Suivant',
              onPressed: _next,
              backgroundColor: primaryColor,
              textColor: Colors.white,
              borderColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// 3) Validation du paiement
class PaymentValidationPage extends StatelessWidget {
  final String wallet;
  final String method;
  final String credential;

  const PaymentValidationPage({
    required this.wallet,
    required this.method,
    required this.credential,
    Key? key,
  }) : super(key: key);

  void _confirm(BuildContext context) {
    // TODO: appeler l'API de paiement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement validé avec succès.')),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation du paiement'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Portefeuille : \$wallet',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Méthode : \$method',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Identifiant : \$credential',
                style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            CustomButton(
              text: 'Confirmer le paiement',
              onPressed: () => _confirm(context),
              backgroundColor: primaryColor,
              textColor: Colors.white,
              borderColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
