import QtQuick 2.0
import QtMultimedia 5.8
import "properties.js" as Properties

Item {
    id: bullet
    width: 2 * Properties.scale
    height: 2 * Properties.scale
    visible: false

    anchors.top: parent.top
    anchors.left: parent.left

    property int your_strange_id: 1;

    property int x_current: 0
    property int y_current: 0
    property int last_direction: Qt.Key_Up
    property int steps_left: 0
    property var call_back: null

    Component.onCompleted: {
        sound_shot.play();
    }

    Rectangle {
        width: 6
        height: 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        radius: 2
        border.width: 1
        border.color: "red"
    }

    Rectangle {
        id: bang
        width: 1
        height: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        radius: 10;
        border.width: 2
        border.color: "red"
        visible: false

        ParallelAnimation {
            id: bang_animation
            running: false
            NumberAnimation { target: bang; property: "width"; to: 2 * Properties.scale; duration: Properties.bang_speed }
            NumberAnimation { target: bang; property: "height"; to: 2 * Properties.scale; duration: Properties.bang_speed }
            onStopped: {
                bullet.visible = false;
                bang_hide.start();
            }
        }
        SequentialAnimation {
            id: bang_hide
            running: false
            NumberAnimation { target: bang; property: "opacity"; to: 0; duration: 2 * Properties.bang_speed }
            PauseAnimation { duration: 5000 }
            onStopped: {
                bullet.destroy();
            }
        }
        function start() {
            visible = true;
            bang_animation.start();
        }
    }

    SequentialAnimation {
        id: y_animation
        running: false
        property int y_from: 0
        property int y_to: 0
        NumberAnimation {
            target: bullet
            property: "anchors.topMargin"
            from: y_animation.y_from * Properties.scale
            to: y_animation.y_to * Properties.scale
            duration: Properties.bullet_speed
        }
        onStopped: {
            bullet.y_current = y_animation.y_to;
            if (bullet.call_back) bullet.call_back(bullet, bullet.x_current, bullet.y_current);
            if (bullet.steps_left > 0) bullet.move();
            else {
                bang.start();
                sound_bang.play();
            }
        }
    }

    SequentialAnimation {
        id: x_animation
        running: false
        property int x_from: 0
        property int x_to: 0
        NumberAnimation {
            target: bullet
            property: "anchors.leftMargin"
            from: x_animation.x_from * Properties.scale
            to: x_animation.x_to * Properties.scale
            duration: Properties.bullet_speed
        }
        onStopped: {
            bullet.x_current = x_animation.x_to;
            if (bullet.call_back) bullet.call_back(bullet, bullet.x_current, bullet.y_current);
            if (bullet.steps_left > 0) bullet.move()
            else {
                bang.start();
                sound_bang.play();
            }
        }
    }

    function fly(x_shot, y_shot, direction, steps) {
        bullet.x_current = x_shot;
        bullet.y_current = y_shot;
        bullet.last_direction = direction;
        bullet.steps_left = steps;
        move();
    }

    function move() {
        steps_left--;
        if (bullet.last_direction === Qt.Key_Up || bullet.last_direction === Qt.Key_Down) {
            rotation = 0;
            var y_to = y_current + (bullet.last_direction === Qt.Key_Down ? 1 : -1);
            y_animation.y_from = y_current;
            y_animation.y_to = y_to;
            bullet.anchors.leftMargin = x_current * Properties.scale;
            bullet.visible = true;
            y_animation.start();
        } else {
            rotation = 90;
            var x_to = x_current + (bullet.last_direction === Qt.Key_Right ? 1 : -1);
            x_animation.x_from = x_current;
            x_animation.x_to = x_to;
            bullet.anchors.topMargin = y_current * Properties.scale;
            bullet.visible = true;
            x_animation.start();
        }
    }

    MediaPlayer {
        id: sound_shot
        volume: 1
        source: "shot.mp3"
    }
    MediaPlayer {
        id: sound_bang
        volume: 0.4
        source: "bang.mp3"
    }

    function blow_up() {
        bullet.steps_left = 0;
    }

    function set_call_back(func) {
        bullet.call_back = func;
    }

    function get_your_stranger_id() {
        return bullet.your_strange_id;
    }

    function set_your_stranger_id(id) {
        bullet.your_strange_id = id;
    }
}
