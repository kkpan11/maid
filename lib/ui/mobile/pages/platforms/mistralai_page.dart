import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/appbars/generic_app_bar.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/api_key_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/seed_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/temperature_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/top_p_parameter.dart';
import 'package:maid/ui/mobile/widgets/parameter_widgets/url_parameter.dart';
import 'package:maid/ui/mobile/widgets/session_busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MistralAiPage extends StatelessWidget {
  const MistralAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(title: "MistralAI Parameters"),
      body: SessionBusyOverlay(
        child: Consumer<Session>(
          builder: (context, session, child) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("mistral_ai_model", json.encode(session.model.toMap()));
            });

            return ListView(
              children: [
                const ApiKeyParameter(),
                Divider(
                  height: 20,
                  indent: 10,
                  endIndent: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const UrlParameter(),
                const SizedBox(height: 20.0),
                const SeedParameter(),
                const TopPParameter(),
                const TemperatureParameter(),
              ]
            );
          },
        ),
      )
    );
  }
}
