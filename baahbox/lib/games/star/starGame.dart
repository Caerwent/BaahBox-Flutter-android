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

import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:get/get.dart';
import 'package:baahbox/controllers/appController.dart';
import 'package:baahbox/constants/enums.dart';
import 'package:baahbox/games/BBGame.dart';
import '../../model/GameInput.dart';
import 'starSprite.dart';
import 'package:baahbox/services/settings/settingsController.dart';

class StarGame extends BBGame with TapCallbacks {
  final Controller appController = Get.find();
  final SettingsController settingsController = Get.find();
  late final TextComponent scoreText;

  late Size screenSize;
  late StarSprite _star;

  late GameInput gameInput;

  double input = 0;
  final instructionTitle = 'Fais briller l\'étoile';
  var instructionSubtitleMuscle = 'en contractant ton muscle';
  var instructionSubtitleJoystick = 'pousse le joystick en haut';
  var instructionSubtitleFinger = 'glisse le doigt de bas en haut';

  final feedBackTitle = 'encore un effort!';
  @override
  Color backgroundColor() => BBGameList.star.baseColor.color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Flame.images.loadAll(<String>[
      'Games/Star/game_star.png',
      'Games/Star/game_star_shining.png',
    ]);
   // loadInfoComponents();
    title = instructionTitle;
    setInstructions();
    feedback = feedBackTitle;
    input = 0;
    _star = StarSprite();
    await add(_star);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (appController.isActive) {
      appController.updateConnectionState();
      if (isRunning) {
        refreshInput();
       //scoreText.text = 'Score: $input';
        updateOverlaysAndState();
      }
      else {
        setInstructions();
      }
    }
  }

  void loadInfoComponents() {
    addAll([
      scoreText = TextComponent(
        position: Vector2(size.x - 5, size.y - 10),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    ]);
  }

  void refreshInput() {
    if (appController.isConnectedToBox) {
      input=-gameInput.delta.y;
    }
  }

  void updateOverlaysAndState() {
    if (input < 0.3) {
      title = instructionTitle;
      setInstructions();
    } else if (input < 0.75) {
      displayFeedBack();
    } else {
      endGame();
    }
  }

  void resize(Size size) {
    screenSize = size;
  }

  @override
  void startGame() {
    input =0;
    gameInput = GameInput(
        axes: GameInputAxes.vertical,
        directionType: GameInputDirectionType.analogic);
    _star.initialize();
    super.startGame();
  }

  @override
  void endGame() {
    state = GameState.won;
    super.endGame();
  }

  @override
  void resetGame() {
    super.resetGame();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (appController.isConnectedToBox || state != GameState.running) {
      input = 0;
    } else {
      var yPos = info.eventPosition.global.y;
      input = (canvasSize.y - yPos)  / canvasSize.y;
      // print(
      //     "panInput : ${panInput} :::  panY : ${yPos} vs game ${canvasSize.y}");
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
   // print("state : $state ");
  }
}
