/*
 * Baah Box
 * Copyright (c) 2024. Orange SA
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baahbox/services/settings/settingsController.dart';


class MuscleSettingsView extends GetView<SettingsController> {

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Card(
              shape: ContinuousRectangleBorder(),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Muscle utilisé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Sélectionnez le ou les muscles à travailler',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ]))),
          const SizedBox(
            height: 12,
          ),
          Obx(() => SwitchListTile.adaptive(
              title: const Text("Muscle1"),
              value: controller.genericSettings["isSensor1On"],
              onChanged: (bool newValue) {
                controller.setMuscle1To(newValue);
              })),
          const SizedBox(
            height: 5,
          ),
          Obx(() => SwitchListTile.adaptive(
              title: const Text("Muscle2"),
              value: controller.genericSettings["isSensor2On"],
              onChanged: (bool newValue) {
                controller.setMuscle2To(newValue);
              })),
        ]));
  }
}
