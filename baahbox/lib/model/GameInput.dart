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

import 'package:baahbox/constants/enums.dart';
import 'package:baahbox/model/sensorInput.dart';
import 'package:flame/components.dart';

import '../controllers/appController.dart';
import '../services/settings/settingsController.dart';
import 'package:get/get.dart';

enum GameInputAxes {
  vertical,
  horizontal,
  both;
}

enum GameInputDirectionType {
  analogic,
  digital;
}

enum GameInputDirection {
  up,
  upLeft,
  upRight,
  right,
  down,
  downRight,
  downLeft,
  left,
  idle,
}

class GameInput {
  GameInputAxes axes = GameInputAxes.both;
  GameInputDirectionType directionType = GameInputDirectionType.digital;

  final SettingsController settingsController = Get.find();
  final Controller appController = Get.find();

  final Vector2 _delta = Vector2.zero();

  GameInput({required this.axes, required this.directionType});

  static const double _eighthOfPi = pi / 8;

  Vector2 get delta {
    switch (settingsController.currentSensor) {
      case Sensor.none:
        _delta.setValues(0, 0);
      case Sensor.muscle:
        convertMuscleInput();
      case Sensor.arcadeJoystick:
        convertArcadeJoystickInput();
      case Sensor.button:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Sensor.analogJoystick:
        convertAnalogJoystickInput();
      case Sensor.wheelChairJoystick:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Sensor.handle:
        convertHandleInput();
    }
    return _delta;
  }

  GameInputDirection get direction {
    var currentDelta = delta;
    if (currentDelta.isZero()) {
      return GameInputDirection.idle;
    }

    var joystickAngle = currentDelta.screenAngle();
    // Since screenAngle and angleTo doesn't care about "direction" of the angle
    // we have to use angleToSigned and create an only increasing angle by
    // removing negative angles from 2*pi.
    joystickAngle = joystickAngle < 0 ? 2 * pi + joystickAngle : joystickAngle;
    if (joystickAngle >= 0 && joystickAngle <= _eighthOfPi) {
      return GameInputDirection.up;
    } else if (joystickAngle > 1 * _eighthOfPi &&
        joystickAngle <= 3 * _eighthOfPi) {
      return GameInputDirection.upRight;
    } else if (joystickAngle > 3 * _eighthOfPi &&
        joystickAngle <= 5 * _eighthOfPi) {
      return GameInputDirection.right;
    } else if (joystickAngle > 5 * _eighthOfPi &&
        joystickAngle <= 7 * _eighthOfPi) {
      return GameInputDirection.downRight;
    } else if (joystickAngle > 7 * _eighthOfPi &&
        joystickAngle <= 9 * _eighthOfPi) {
      return GameInputDirection.down;
    } else if (joystickAngle > 9 * _eighthOfPi &&
        joystickAngle <= 11 * _eighthOfPi) {
      return GameInputDirection.downLeft;
    } else if (joystickAngle > 11 * _eighthOfPi &&
        joystickAngle <= 13 * _eighthOfPi) {
      return GameInputDirection.left;
    } else if (joystickAngle > 13 * _eighthOfPi &&
        joystickAngle <= 15 * _eighthOfPi) {
      return GameInputDirection.upLeft;
    } else if (joystickAngle > 15 * _eighthOfPi) {
      return GameInputDirection.up;
    } else {
      return GameInputDirection.idle;
    }
  }

  void convertArcadeJoystickInput() {
    var joystickInput = appController.digitalInputs;

    if (joystickInput.right) {
      switch (axes) {
        case GameInputAxes.vertical:
          _delta.setValues(0, -1);
        case GameInputAxes.horizontal:
          _delta.setValues(1, 0);
        case GameInputAxes.both:
          _delta.setValues(1, 0);
      }
    } else if (joystickInput.left) {
      switch (axes) {
        case GameInputAxes.vertical:
          _delta.setValues(0, 1);
        case GameInputAxes.horizontal:
          _delta.setValues(-1, 0);
        case GameInputAxes.both:
          _delta.setValues(-1, 0);
      }
    } else if (joystickInput.up) {
      switch (axes) {
        case GameInputAxes.vertical:
          _delta.setValues(1, 0);
        case GameInputAxes.horizontal:
          _delta.setValues(-1, 0);
        case GameInputAxes.both:
          _delta.setValues(-1, 0);
      }
    } else if (joystickInput.down) {
      switch (axes) {
        case GameInputAxes.vertical:
          _delta.setValues(-1, 0);
        case GameInputAxes.horizontal:
          _delta.setValues(1, 0);
        case GameInputAxes.both:
          _delta.setValues(1, 0);
      }
    } else {}
  }

  void convertAnalogJoystickInput() {
    var joystickInput = appController.analogInput;

    double analog1 =
        (calibrateAnalogInput(joystickInput.analog1, 0, 180) - 500) / 500;
    // up is Y positive on joystick, need to be inverted
    double analog2 =
        (500 - calibrateAnalogInput(joystickInput.analog2, 0, 180)) / 500;
    switch (axes) {
      case GameInputAxes.horizontal:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(analog1, 0);
        } else {
          _delta.setValues(analog1.abs() >= 0.5 ? analog1.sign : 0, 0);
        }
      case GameInputAxes.vertical:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(0, analog2);
        } else {
          _delta.setValues(analog2.abs() >= 0.5 ? analog2.sign : 0, 0);
        }
      case GameInputAxes.both:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(analog1, analog2);
        } else {
          _delta.setValues(analog1.abs() >= 0.5 ? analog1.sign : 0,
              analog2.abs() >= 0.5 ? analog2.sign : 0);
        }
    }
  }

  void convertMuscleInput() {
    var joystickInput = appController.analogInput;
    var hasMuscle1 = settingsController.genericSettings["isSensor1On"];
    var hasMuscle2 = settingsController.genericSettings["isSensor2On"];
    double analog1 = calibrateAnalogInput(joystickInput.analog1, 0, 180) / 1000;
    double analog2 = calibrateAnalogInput(joystickInput.analog2, 0, 180) / 1000;
    switch (axes) {
      case GameInputAxes.horizontal:
        if (hasMuscle1 && hasMuscle2) {
          if (directionType == GameInputDirectionType.analogic) {
            if (analog1 > analog2) {
              _delta.setValues(-analog1, 0);
            } else {
              _delta.setValues(analog2, 0);
            }
          } else {
            if (analog1 > analog2) {
              _delta.setValues(analog1 >= 0.5 ? -1 : 0, 0);
            } else {
              _delta.setValues(analog2 >= 0.5 ? 1 : 0, 0);
            }
          }
        } else if (hasMuscle1) {
          if (directionType == GameInputDirectionType.analogic) {
            _delta.setValues(analog1, 0);
          } else {
            _delta.setValues(analog1 >= 0.5 ? 1 : 0, 0);
          }
        } else if (hasMuscle2) {
          if (directionType == GameInputDirectionType.analogic) {
            _delta.setValues(analog2, 0);
          } else {
            _delta.setValues(analog2 >= 0.5 ? 1 : 0, 0);
          }
        } else {
          _delta.setValues(0, 0);
        }

      case GameInputAxes.vertical:
        if (hasMuscle1 && hasMuscle2) {
          if (directionType == GameInputDirectionType.analogic) {
            if (analog1 > analog2) {
              _delta.setValues(0, -analog1);
            } else {
              _delta.setValues(0, analog2);
            }
          } else {
            if (analog1 > analog2) {
              _delta.setValues(0, analog1 >= 0.5 ? -1 : 0);
            } else {
              _delta.setValues(0, analog2 >= 0.5 ? 1 : 0);
            }
          }
        } else if (hasMuscle1) {
          if (directionType == GameInputDirectionType.analogic) {
            _delta.setValues(0, analog1);
          } else {
            _delta.setValues(0, analog1 >= 0.5 ? 1 : 0);
          }
        } else if (hasMuscle2) {
          if (directionType == GameInputDirectionType.analogic) {
            _delta.setValues(0, analog2);
          } else {
            _delta.setValues(0, analog2 >= 0.5 ? 1 : 0);
          }
        } else {
          _delta.setValues(0, 0);
        }
      case GameInputAxes.both:
        bool hasUp = analog1 > 0.8 && analog2 > 0.8;

        if (directionType == GameInputDirectionType.analogic) {
          if (analog1 > analog2) {
            _delta.setValues(-analog1, hasUp ? 1 : 0);
          } else {
            _delta.setValues(analog2, hasUp ? 1 : 0);
          }
        } else {
          if (analog1 > analog2) {
            _delta.setValues(analog1 >= 0.5 ? -1 : 0, hasUp ? 1 : 0);
          } else {
            _delta.setValues(analog2 >= 0.5 ? 1 : 0, hasUp ? 1 : 0);
          }
        }
    }
  }

  void convertHandleInput() {
    var joystickInput = appController.analogInput;

    double analog1 = calibrateAnalogInput(
            joystickInput.analog1,
            settingsController.getHandleRangeLower(),
            settingsController.getHandleRangeUpper()) /
        1000;

    switch (axes) {
      case GameInputAxes.horizontal:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(analog1, 0);
        } else {
          _delta.setValues(analog1 >= 0.5 ? 1 : 0, 0);
        }
      case GameInputAxes.vertical:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(0, -1 * analog1);
        } else {
          _delta.setValues(0, analog1 >= 0.5 ? -1 : 0);
        }
      case GameInputAxes.both:
        if (directionType == GameInputDirectionType.analogic) {
          _delta.setValues(analog1, 0);
        } else {
          _delta.setValues(analog1 >= 0.5 ? 1 : 0, 0);
        }
    }
  }
}
