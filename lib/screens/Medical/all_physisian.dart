import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/screens/Medical/provider/medical_provider.dart';
import 'package:medicall_app/Models/Medical/physician_model.dart';
import '../../config/routes.dart';

class AllPhysiciansScreen extends StatefulWidget {
  const AllPhysiciansScreen({Key? key}) : super(key: key);

  @override
  _AllPhysiciansScreenState createState() => _AllPhysiciansScreenState();
}

class _AllPhysiciansScreenState extends State<AllPhysiciansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalProvider>().fetchAllPhysicians();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les Médecins'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoadingPhysicians
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(child: Text(provider.error!))
                : ListView.builder(
                    itemCount: provider.physicians?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      PhysicianModel? doc = provider.physicians?.data![index];
                      return Card(
                        child: ListTile(
                          leading: _buildPhysicianImage(doc),
                          title: Text(doc?.name ?? 'Nom non disponible'),
                          subtitle: Text(
                              doc?.specialty ?? 'Spécialité non disponible'),
                          onTap: () {
                            NavigationHelper.navigateToPayment(context);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildPhysicianImage(PhysicianModel? physician) {
    if (physician == null ||
        physician.image == null ||
        physician.image!.isEmpty) {
      return CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.2),
        child: const Icon(Icons.person, color: primaryColor),
      );
    }

    try {
      if (physician.image!.startsWith('<svg')) {
        return CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: SvgPicture.string(
            physician.image!,
            width: 40,
            height: 40,
            placeholderBuilder: (context) => const CircularProgressIndicator(),
          ),
        );
      } else {
        Uint8List imageBytes = base64Decode(physician.image!);
        return CircleAvatar(
          backgroundImage: MemoryImage(imageBytes),
        );
      }
    } catch (e) {
      return CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.2),
        child: const Icon(Icons.person, color: primaryColor),
      );
    }
  }
}
