import QtQuick 2.0
import "properties.js" as Properties

Rectangle {
    id: tank

    width: 2 * Properties.scale
    height: 2 * Properties.scale
    color: "yellow"
    radius: 5
    visible: false

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 0
    anchors.leftMargin: 0

    Rectangle {
        id: gun
        color: "black"
        width: 6
        height: 15
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        SequentialAnimation {
            id: fire_animation_front
            NumberAnimation {
                target: gun
                property: "anchors.topMargin"
                from: 5
                to: 0
                duration: 80
            }
            onStopped: {

            }
        }
        SequentialAnimation {
            id: fire_animation_back
            NumberAnimation {
                target: gun
                property: "anchors.topMargin"
                from: 0
                to: 5
                duration: 80
            }
            onStopped: {
                fire_animation_front.start();
            }
        }
        function fire() {
            fire_animation_back.start();
        }
    }

    property bool moving: false
    property int x_current: 0
    property int y_current: 0
    property int last_direction: 0
    property int steps_left: 0

    function set_position(fl_x, fl_y) {
        x_current = fl_x;
        y_current = fl_y;
        anchors.leftMargin = fl_x * Properties.scale
        anchors.topMargin = fl_y * Properties.scale
        visible = true
    }

    SequentialAnimation {
        id: y_animation
        running: false
        property int y_from: 0
        property int y_to: 0
        NumberAnimation {
            target: tank
            property: "anchors.topMargin"
            from: y_animation.y_from * Properties.scale
            to: y_animation.y_to * Properties.scale
            duration: Properties.duration
        }
        onStopped: {
            tank.move();
        }
    }

    SequentialAnimation {
        id: x_animation
        running: false
        property int x_from: 0
        property int x_to: 0
        NumberAnimation {
            target: tank
            property: "anchors.leftMargin"
            from: x_animation.x_from * Properties.scale
            to: x_animation.x_to * Properties.scale
            duration: Properties.duration
        }
        onStopped: {
            tank.move();
        }
    }

    function rotate(direction) {
        if (direction == Qt.Key_Up) {
            rotation = 0;
        } else if (direction == Qt.Key_Down) {
            rotation = 180;
        } else if (direction == Qt.Key_Left) {
            rotation = 270;
        } else if (direction == Qt.Key_Right) {
            rotation = 90;
        }
    }

    function move() {
        if (steps_left > 0) --tank.steps_left;
        else {
            moving = false;
            return;
        }

        if (last_direction == Qt.Key_Down || last_direction == Qt.Key_Up) {
            var y_to = y_current + (last_direction == Qt.Key_Down ? 1 : -1);

            y_animation.y_from = y_current;
            y_animation.y_to = y_to;
            y_current = y_to;

            y_animation.start();
        }
        if (last_direction == Qt.Key_Left || last_direction == Qt.Key_Right) {
            var x_to = x_current + (last_direction == Qt.Key_Right ? 1 : -1);

            x_animation.x_from = x_current;
            x_animation.x_to = x_to;
            x_current = x_to;

            x_animation.start();
        }
    }

    function go(direction, steps) {
        if (moving || steps === 0) return;

        last_direction = direction;
        steps_left = steps;

        moving = true;
        rotate(direction);

        move(direction);
    }

    function stop() {
        steps_left = 0;
    }

    function fire() {
        gun.fire();
    }
}
