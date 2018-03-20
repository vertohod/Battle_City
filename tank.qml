import QtQuick 2.0
import QtMultimedia 5.8
import "properties.js" as Properties

Item {
    id: tank

    width: 2 * Properties.scale
    height: 2 * Properties.scale
    visible: false

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: 0
    anchors.leftMargin: 0

    property int your_strange_id: 1

    Rectangle {
        id: armor
        width: parent.width - 8
        height: parent.height - 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "yellow"
        radius: 5
    }

    function change_view() {
        armor.color = "blue";
        armor.width = tank.width - 10;
        armor.height = tank.height - 2;
        armor.radius = 2;
    }

    Rectangle {
        id: gun
        color: "red"
        border.width: 1
        border.color: "black"
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
    property int last_direction: Qt.Key_Up
    property int steps_left: 0
    property int steps_done: 0
    property int item_id: 0
    property var call_back_function: null
    property var get_next_direction: null

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
            duration: Properties.tank_speed
        }
        onStopped: {
            tank.move(tank.last_direction);
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
            duration: Properties.tank_speed
        }
        onStopped: {
            tank.move(tank.last_direction);
        }
    }

    function rotate(direction) {
        if (direction === Qt.Key_Up) {
            rotation = 0;
        } else if (direction === Qt.Key_Down) {
            rotation = 180;
        } else if (direction === Qt.Key_Left) {
            rotation = 270;
        } else if (direction === Qt.Key_Right) {
            rotation = 90;
        }
    }

    function move(direction) {
        last_direction = direction;
        if (steps_left === 0) {
            var direction_pair = [0, 0];
            if (get_next_direction !== null) {
                direction_pair = get_next_direction();
            }
            if (direction_pair[0] !== 0) {
                last_direction = direction_pair[0];
                steps_done = 0;
                steps_left = direction_pair[1];
                rotate(last_direction);
            } else {
                moving = false;
                return;
            }
        }

        if (last_direction == Qt.Key_Down || last_direction == Qt.Key_Up) {
            var y_to = y_current + (last_direction == Qt.Key_Down ? 1 : -1);
            call_back_function(tank, get_x(), y_to);
            if (steps_left === 0) {
                moving = false;
                return;
            }

            y_animation.y_from = tank.y_current;
            tank.y_current = y_to;
            y_animation.y_to = y_to;
            steps_done++;
            steps_left--;
            y_animation.start();
        }
        if (last_direction == Qt.Key_Left || last_direction == Qt.Key_Right) {
            var x_to = x_current + (last_direction == Qt.Key_Right ? 1 : -1);
            call_back_function(tank, x_to, get_y());
            if (steps_left === 0) {
                moving = false;
                return;
            }

            x_animation.x_from = tank.x_current;
            tank.x_current = x_to;
            x_animation.x_to = x_to;
            steps_done++;
            steps_left--;
            x_animation.start();
        }
    }

    function go(direction, steps) {
        if (moving) return false;

        steps_done = 0;
        rotate(direction);
        last_direction = direction; // it necessary to fire in right direction

        if (steps !== 0) {
            steps_left = steps;
            moving = true;
            move(direction);
        }
        return true;
    }

    function stop() {
        steps_left = 0;
    }

    function fire() {
        gun.fire();
    }

    function get_your_stranger_id() {
        return tank.your_strange_id;
    }

    function set_your_stranger_id(id) {
        tank.your_strange_id = id;
    }

    function get_x() {
        return tank.x_current;
    }

    function get_y() {
        return tank.y_current;
    }

    function get_direction() {
        return last_direction;
    }

    function get_steps_done() {
        return steps_done;
    }

    function get_item_id() {
        return item_id;
    }

    function set_item_id(it_id) {
        item_id = it_id;
    }

    function set_call_back(func) {
        call_back_function = func;
    }

    function set_function_get_next_direction(func) {
        get_next_direction = func;
    }
}
