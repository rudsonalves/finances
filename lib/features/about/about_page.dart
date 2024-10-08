// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/app_info.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/constants/themes/icons/trademark_icons.dart';

const String youtubeVideoEn = 'https://youtu.be/aJMk4NdGc40';
const String youtubeVideoPt = 'https://youtu.be/K-qeNaxyl6I';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const routeName = '/about';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    const double height = 30;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.aboutPageTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              AppInfo.name,
              style: AppTextStyles.textStyleSemiBold20,
              textAlign: TextAlign.center,
            ),
            Text(
              '${locale.aboutPageVersion}: ${AppInfo.version}',
              style: AppTextStyles.textStyleSemiBold14.copyWith(
                color: primary,
              ),
            ),
            const SizedBox(height: height * 2),
            Text(
              locale.aboutPageDev,
              style: AppTextStyles.textStyleSemiBold14,
              textAlign: TextAlign.center,
            ),
            const TextButton(
              onPressed: AppInfo.launchMailto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                  ),
                  SizedBox(width: 6),
                  Text(
                    AppInfo.email,
                    style: AppTextStyles.textStyleSemiBold14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: height),
            Text(
              locale.aboutPageVideos,
              style: AppTextStyles.textStyleSemiBold14,
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      TrademarkIcons.youtube,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '[en] $youtubeVideoEn',
                      style: AppTextStyles.textStyleSemiBold14
                          .copyWith(color: primary),
                    ),
                  ],
                ),
              ),
              onTap: () => AppInfo.launchUrl(youtubeVideoEn),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      TrademarkIcons.youtube,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '[pt_BR] $youtubeVideoPt',
                      style: AppTextStyles.textStyleSemiBold14
                          .copyWith(color: primary),
                    ),
                  ],
                ),
              ),
              onTap: () => AppInfo.launchUrl(youtubeVideoPt),
            ),
            const SizedBox(height: height),
            Text(
              locale.aboutPagePolice,
              style: AppTextStyles.textStyleSemiBold14,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  color: primary,
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => AppInfo.launchUrl(AppInfo.privacyPolicyUrl),
                  child: const Text(
                    AppInfo.privacyPolicyUrl,
                    style: AppTextStyles.textStyleSemiBold14,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
