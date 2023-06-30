import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart' hide Draggable;

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget.controlled(gameFactory: VeryGoodShooter.new),
      ),
    ),
  );
}

class Enemy extends SpriteAnimationComponent
    with HasGameRef<VeryGoodShooter>, CollisionCallbacks {
  Enemy({
    required super.position,
  }) : super(size: Vector2(20, 40), children: [
          RectangleHitbox(), // used for collision detection. Flame doesn't know the collision area so we need to use this.
        ]);

  @override
  FutureOr<void> onLoad() async {
    final image = await gameRef.images.load('enemy.png');
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        textureSize: Vector2(16, 16),
        stepTime: .2,
        amount: 4,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Starts on top of the screen and moves down.
    position.y += 100 * dt;

    // Remove enemy when it leaves the screen
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
    }
  }
}

class Bullet extends SpriteAnimationComponent with HasGameRef<VeryGoodShooter> {
  Bullet({
    required super.position,
  }) : super(size: Vector2(20, 40), children: [RectangleHitbox()]);

  @override
  FutureOr<void> onLoad() async {
    final image = await gameRef.images.load('player2.png');
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        textureSize: Vector2(8, 16),
        stepTime: 1.0,
        amount: 4,
        texturePosition: Vector2(0, 39),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += -400 * dt;

    // Remove bullet when it leaves the screen
    if (position.y + -size.y < 0) {
      removeFromParent();
    }
  }
}

class Player extends SpriteAnimationComponent
    with Draggable, HasGameRef<VeryGoodShooter> {
  Player({
    required super.position,
  }) : super(size: Vector2(80, 100));

  late final _shootingTimer = Timer(
    .2,
    onTick: () {
      gameRef.add(
        Bullet(
          position: position +
              Vector2(
                25,
                -40,
              ), // 25: half of X player - half of X bullet -5.
          // -40: height of bullet
        ),
      );
    },
    autoStart: false,
    repeat: true,
  );

  @override
  FutureOr<void> onLoad() async {
    final image = await gameRef.images.load('player2.png');
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        textureSize: Vector2(32, 39),
        stepTime: 1.0,
        amount: 4,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shootingTimer.update(dt);
  }

  @override
  bool onDragStart(_) {
    _shootingTimer.start();
    return true;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    _shootingTimer.stop();
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    position += info.delta.game;
    return true;
  }
}

final _rng = Random();

class VeryGoodShooter extends FlameGame
    with HasDraggables, HasCollisionDetection {
  VeryGoodShooter()
      : super(
          children: [
            Player(position: Vector2(200, 400)),
            for (var i = 0; i < 10; i++)
              Enemy(
                position: Vector2(_rng.nextDouble() * 200, -20),
              ),
          ],
        );
}

// class Square extends RectangleComponent {
//   Square()
//       : super(
//           paint: Paint()..color = Colors.amber,
//           size: Vector2.all(10),
//           position: Vector2.zero(),
//           children: [
//             RectangleComponent(
//               size: Vector2.all(5),
//               position: Vector2.all(2),
//               paint: Paint()..color = Colors.red,
//             )
//           ],
//         );

//   @override
//   void update(double dt) {
//     position += Vector2.all(1) * 100 * dt;
//   }
// }

// class VeryGoodShooter extends FlameGame {
//   VeryGoodShooter()
//       : super(children: [
//           Square(),
//         ]);
// }
