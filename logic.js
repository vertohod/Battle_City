Qt.include("properties.js");
Qt.include("map_levels.js");

var field = null;
var tank = null;
var enemies = [];
var pressed_key = 0;
var current_level = 0;

function start(battle_field) {
    field = battle_field;
    var component_tank = Qt.createComponent("tank.qml");
    tank = component_tank.createObject(field);
    tank.set_position(0, 0);

    field.level_draw(current_level);
}

function pressed(key) {
    if (key === Qt.Key_Down || key === Qt.Key_Up || key === Qt.Key_Left || key === Qt.Key_Right) {
        pressed_key = key;
        if (tank == null) return;
        tank.go(key, get_max_distance(tank.x_current, tank.y_current, key));
    }
    if (key === Qt.Key_Space) {
        tank.fire();
    }
}

function released(key) {
    if (key === pressed_key) {
        pressed_key = 0;
        tank.stop();
    }
}

function get_max_distance(x_current, y_current, direction) {
    var level = mapLevels[current_level];
    var counter = 0;
    if (direction === Qt.Key_Up) {
        for (var i = y_current - 1; i >= 0; i--) {
            var line = level[i];
            if (line[x_current] === 0 && line[x_current + 1] === 0) counter++;
            else break;
        }
    } else if (direction === Qt.Key_Down) {
        for (var i = y_current + 2; i < level.length; i++) {
            var line = level[i];
            if (line[x_current] === 0 && line[x_current + 1] === 0) counter++;
            else break;
        }
    } else if (direction === Qt.Key_Left) {
        var line1 = level[y_current];
        var line2 = level[y_current + 1];
        for (var i = x_current - 1; i >= 0; i--) {
            if (line1[i] === 0 && line2[i] === 0) counter++;
            else break;
        }
    } else if (direction === Qt.Key_Right) {
        var line1 = level[y_current];
        var line2 = level[y_current + 1];
        for (var i = x_current + 2; i < line1.length; i++) {
            if (line1[i] === 0 && line2[i] === 0) counter++;
            else break;
        }
    }
    return counter;
}
