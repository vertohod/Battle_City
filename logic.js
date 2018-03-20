Qt.include("properties.js");
Qt.include("map_levels.js");

var keys_queue = [];
var field = null;
var tank = null;
var enemies = [];
var current_level = 0;
var killed_enemies = 0;
var killed_tank = 0;
var item_number = 0;
var user_name = "";

function start(battle_field) {
    field = battle_field;

    killed_enemies = 0;
    killed_tank = 0;

    if (tank === null) create_tank();
}

function create_tank() {
    if (killed_tank === max_tanks) return;

    var component_tank = Qt.createComponent("tank.qml");
    tank = component_tank.createObject(field);

    tank.set_your_stranger_id(tank_id);
    tank.set_item_id(get_item_id());
    tank.set_call_back(machine_call_back);
    tank.set_function_get_next_direction(get_next_direction);
    var position = get_random_position();
    tank.set_position(position[0], position[1]);
}

function get_item_id() {
    return ++item_number;
}

function pressed(key) {
    if (key === Qt.Key_Down || key === Qt.Key_Up || key === Qt.Key_Left || key === Qt.Key_Right) {
        if (tank !== null) {
            if (!tank.go(key, get_max_distance(tank.get_x(), tank.get_y(), key))) {
                keys_queue.push(key);
            }
        }
    }
    if (key === Qt.Key_Space) {
        if (tank !== null) {
            tank.fire();
            var component_bullet = Qt.createComponent("bullet.qml");
            var bullet = component_bullet.createObject(field);
            bullet.set_your_stranger_id(tank.get_your_stranger_id());
            bullet.set_call_back(bullet_call_back);
            bullet.fly(tank.get_x(), tank.get_y(), tank.get_direction(), 1 + get_max_distance(tank.get_x(), tank.get_y(), tank.get_direction()));
        }
    }
}

function released(key) {
    if (tank === null) return;
    if (key === Qt.Key_Down || key === Qt.Key_Up || key === Qt.Key_Left || key === Qt.Key_Right) {
        if (tank.get_direction() === key) tank.stop();
        for (var i = keys_queue.length; i > 0; i--) {
            if (keys_queue[i - 1] === key) {
                keys_queue.splice(i - 1, 1);
            }
        }
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

function get_random_position() {
    var level = mapLevels[current_level];
    var result = [0, 0];
    var y = Math.round(Math.random() * (level.length - 1));
    var x = Math.round(Math.random() * (level[y].length - 1));

    var y1 = y - 3 > 0 ? y - 3 : 0;
    var y2 = y + 3 >= level.length ? level.length - 1 : y + 3;
    y1 += y2 - (y + 3);
    y2 += y1 - (y - 3);

    var x1 = x - 3 > 0 ? x - 3 : 0;
    var x2 = x + 3 >= level[y].length ? level[y].length - 1 : x + 3;
    x1 += x2 - (x + 3);
    x2 += x1 - (x - 3);

    for (y = y1; y < y2; y++) {
        for (x = x1; x < x2; x++) {
            if (level[y][x] === 0 && level[y][x + 1] === 0 && level[y + 1][x] === 0 && level[y + 1][x + 1] === 0) {
                result[0] = x;
                result[1] = y;
                return result;
            }
        }
    }
    return result;
}

function bullet_call_back(bullet, x, y) {
    if (check_collision_tank(x, y)) {
        if (tank.get_your_stranger_id() !== bullet.get_your_stranger_id()) {
            bullet.blow_up();
            tank.destroy();
            tank = null;
            killed_tank++;
        }
    }
    for (var i = 0; i < enemies.length; i++) {
        var enemie = enemies[i];
        if ((enemie.get_x() === x || enemie.get_x() + 1 === x || enemie.get_x() === x + 1) &&
            (enemie.get_y() === y || enemie.get_y() + 1 === y || enemie.get_y() === y + 1)) {
            if (enemie.get_your_stranger_id() !== bullet.get_your_stranger_id()) {
                killed_enemies++;
                enemie.destroy();
                enemies.splice(i, 1);
                bullet.blow_up();
                break;
            }
        }
    }
}

function machine_call_back(machine, x, y) {
    if (tank !== null && tank.get_item_id() !== machine.get_item_id() && check_collision_tank(x, y)) machine.stop();
    if (check_collision_enemies(machine.get_item_id(), x, y)) machine.stop();
}

function check_collision_tank(x, y) {
    if (tank !== null) {
        if ((tank.get_x() === x || tank.get_x() + 1 === x || tank.get_x() === x + 1) &&
            (tank.get_y() === y || tank.get_y() + 1 === y || tank.get_y() === y + 1)) return true;
    }
    return false;
}

function check_collision_enemies(it_num, x, y) {
    for (var i = 0; i < enemies.length; i++) {
        var enemie = enemies[i];
        if (enemie.get_item_id() === it_num) continue;
        if ((enemie.get_x() === x || enemie.get_x() + 1 === x || enemie.get_x() === x + 1) &&
            (enemie.get_y() === y || enemie.get_y() + 1 === y || enemie.get_y() === y + 1)) return true;
    }
    return false;
}

function timer_tick() {
    if (tank === null) create_tank();

    check_enemies();
    move_enemies();
    fire_enemies();
}

function check_enemies() {
    if (enemies.length < max_enemies_att && (killed_enemies + enemies.length) < max_enemies) {
        var component_tank = Qt.createComponent("tank.qml");
        var enemie = component_tank.createObject(field);

        enemie.change_view();
        enemie.set_your_stranger_id(enemie_id);
        enemie.set_item_id(get_item_id());
        enemie.set_call_back(machine_call_back);
        while (true) {
            var position = get_random_position();
            if (!check_collision_tank(position[0], position[1]) && !check_collision_enemies(enemie, position[0], position[1])) {
                enemie.set_position(position[0], position[1]);
                break;
            }
        }
        enemies.push(enemie);
    }
}

function move_enemies() {
    if (tank === null) return;
    for (var i = 0; i < enemies.length; i++) {
        var enemie = enemies[i];
        var x_div = tank.get_x() - enemie.get_x();
        var y_div = tank.get_y() - enemie.get_y();
        var distance = 0;
        var key = Qt.Key_Down;
        var key_horizontal = Qt.Key_Right;
        var key_vertical = Qt.Key_Down;
        if (x_div !== 0 && y_div !==0) {
            if (Math.round(Math.random() * 1) === 1) {
                key_horizontal = x_div > 0 ? Qt.Key_Right : Qt.Key_Left;
                key = key_horizontal;
                distance = random_distance(Math.abs(x_div), get_max_distance(enemie.get_x(), enemie.get_y(), key));
            } else {
                key_vertical = y_div > 0 ? Qt.Key_Down : Qt.Key_Up;
                key = key_vertical;
                distance = random_distance(Math.abs(y_div), get_max_distance(enemie.get_x(), enemie.get_y(), key));
            }
        }
        if (distance === 0) {
            key_horizontal = x_div > 0 ? Qt.Key_Right : Qt.Key_Left;
            key = key_horizontal;
            distance = random_distance(Math.abs(x_div), get_max_distance(enemie.get_x(), enemie.get_y(), key));
        }
        if (distance === 0) {
            key_vertical = y_div > 0 ? Qt.Key_Down : Qt.Key_Up;
            key = key_vertical;
            distance = random_distance(Math.abs(y_div), get_max_distance(enemie.get_x(), enemie.get_y(), key));
        }
        if (distance === 0) {
            key = (key_horizontal === Qt.Key_Right ? Qt.Key_Left : Qt.Key_Right);
            distance = get_max_distance(enemie.get_x(), enemie.get_y(), key);
        }
        if (distance === 0) {
            key = (key_vertical === Qt.Key_Down ? Qt.Key_Up : Qt.Key_Down);
            distance = get_max_distance(enemie.get_x(), enemie.get_y(), key);
        }
        enemie.go(key, distance);
    }
}

function random_distance(dist_count, dist_max) {
    var distance = 0;
    if (dist_count < dist_max) {
        distance = (Math.round(Math.random() * probability_for_random_distance) == 1) ? dist_max : dist_count;
    } else {
        distance = dist_max;
    }
    return distance;
}

function fire_enemies() {
    if (tank === null) return;
    for (var i = 0; i < enemies.length; i++) {
        var enemie = enemies[i];

        if (Math.round(Math.random() * probability_fire_without_steps) !== 1) {
            if (enemie.get_steps_done() < fire_after_steps) continue;
        }

        var fire = false;
        var distance = 0;
        var direction = Qt.Key_Down;
        if (tank.get_x() === enemie.get_x()) {
            distance = Math.abs(tank.get_y() - enemie.get_y());
            direction = tank.get_y() - enemie.get_y() > 0 ? Qt.Key_Down : Qt.Key_Up;
            if (direction === enemie.get_direction() && distance <= get_max_distance(enemie.get_x(), enemie.get_y(), enemie.get_direction())) {
                fire = true;
            }
        }
        if (tank.get_y() === enemie.get_y()) {
            distance = Math.abs(tank.get_x() - enemie.get_x());
            direction = tank.get_x() - enemie.get_x() > 0 ? Qt.Key_Right : Qt.Key_Left;
            if (direction === enemie.get_direction() && distance <= get_max_distance(enemie.get_x(), enemie.get_y(), enemie.get_direction())) {
                fire = true;
            }
        }
        if (fire) {
            enemie.fire();
            var component_bullet = Qt.createComponent("bullet.qml");
            var bullet = component_bullet.createObject(field);
            bullet.set_your_stranger_id(enemie.get_your_stranger_id());
            bullet.set_call_back(bullet_call_back);
            bullet.fly(enemie.get_x(), enemie.get_y(), enemie.get_direction(), 1 + get_max_distance(enemie.get_x(), enemie.get_y(), enemie.get_direction()));
        }
    }
}

function get_amount_enemies_left() {
    return max_enemies - killed_enemies;
}

function get_current_level() {
    return current_level;
}

function get_lives_left() {
    return max_tanks - killed_tank;
}

function get_next_direction() {
    var direction = [0, 0];
    if (keys_queue.length > 0) {
        direction = [keys_queue[0], get_max_distance(tank.get_x(), tank.get_y(), keys_queue[0])];
        keys_queue.splice(0, 1);
    }
    return direction;
}

function set_user_name(name) {
    user_name = name;
}

function get_user_name() {
    return user_name;
}
