import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "properties.js" as Properties
import "first_screen.js" as FirstScreen
import "map_levels.js" as MapLevels
import "logic.js" as Logic

Window {
    id: main

    visible: true
    width: (Properties.field_width + 7) * Properties.scale
    height: (Properties.field_height + 4) * Properties.scale
    title: qsTr("Battle City")
    color: "black"

    Rectangle {
        id: first_screen
        width: Properties.field_width * Properties.scale
        height: Properties.field_height * Properties.scale
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "black"
        visible: false
        opacity: 0
        SequentialAnimation {
            id: first_screen_animation
            running: false
            NumberAnimation { duration: 1000; }
            NumberAnimation { target: first_screen; property: "opacity"; to: 1.0; duration: 400; }
            NumberAnimation { duration: 2000; }
            NumberAnimation { target: first_screen; property: "opacity"; to: 0.0; duration: 400; }

            onStopped: {
                first_screen.visible = false;
                second_screen.start();
            }
        }
        Component.onCompleted: {
            draw_level(first_screen, FirstScreen.firstScreen);
            first_screen.visible = true;
            first_screen_animation.start();
        }
    }

    Rectangle {
        id: second_screen
        anchors.fill: parent
        color: "gray"
        opacity: 0
        visible: false;

        TextField {
            id: nickname
            horizontalAlignment: TextInput.AlignHCenter
            maximumLength: 8
            font.pointSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Keys.onPressed: {
                if (event.key === Qt.Key_Enter || event.key + 1 === Qt.Key_Enter || nickname.left === nickname.maximumLength) {
                    nickname.focus = false;
                    Logic.set_user_name(nickname.text);
                    second_screen_hide.start();
                }
            }
        }
        Text {
            text: "Enter name:"
            color: "black"
            font.pointSize: 24
            anchors.left: nickname.left
            anchors.bottom: nickname.top

        }
        SequentialAnimation {
            id: second_screen_show
            running: false
            NumberAnimation { duration: 1000; }
            NumberAnimation { target: second_screen; property: "opacity"; to: 1.0; duration: 400; }
            onStopped: {
                nickname.focus = true;
            }
        }
        SequentialAnimation {
            id: second_screen_hide
            running: false
            NumberAnimation { duration: 500; }
            NumberAnimation { target: second_screen; property: "opacity"; to: 0.0; duration: 400; }
            onStopped: {
                second_screen.visible = false;
                game_screen.start();
            }
        }
        function start() {
            second_screen.visible = true;
            second_screen_show.start();
        }
    }

    property int amount_enemies_left: 0
    property int lives_left: 0
    property int current_level: 0

    Timer {
        id: timer
        interval: Properties.timer_interval
        repeat: true
        running: false
        onTriggered: {
            Logic.timer_tick()
            var amount = Logic.get_amount_enemies_left();
            if (amount_enemies_left !== amount) {
                amount_enemies_left = amount;
                draw_amount_enemies();

                if (amount === 0) winner.show();
            }
            var lives = Logic.get_lives_left();
            if (lives_left !== lives) {
                lives_left = lives;
                print_lives(lives_left);

                if (lives === 0) loser.show();
            }
            var level = Logic.get_current_level() + 1;
            if (level !== current_level) {
                current_level = level;
                print_level(level);
            }
        }
    }

    Rectangle {
        id: game_screen
        anchors.fill: parent
        color: "gray"
        opacity: 0
        visible: false

        SequentialAnimation {
            id: game_screen_show
            running: false
            NumberAnimation { duration: 1000; }
            NumberAnimation { target: game_screen; property: "opacity"; to: 1.0; duration: 400; }
            onStopped: {
                game_screen.start_game();
            }
        }

        Rectangle {
            id: battle_field
            width: Properties.field_width * Properties.scale
            height: Properties.field_height * Properties.scale
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 2 * Properties.scale
            anchors.topMargin: 2 * Properties.scale
            color: "black"

            Keys.onPressed: {
                Logic.pressed(event.key);
            }
            Keys.onReleased: {
                Logic.released(event.key);
            }
        }

        Rectangle {
            id: game_info
            anchors.left: battle_field.right
            anchors.top: battle_field.top
            width: 5 * Properties.scale
            height: battle_field.height
            color: "gray"

            Item {
                width: parent.width
                height: parent.height / 2
                anchors.top: parent.top
                anchors.left: parent.left

                Column {
                    id: info_amount_enemies_output
                    spacing: Properties.scale / 2
                    width: parent.width
                }
            }

            Item {
                id: user_name
                width: parent.width
                height: Properties.scale
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8 * Properties.scale
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: info_user_name_output
                    text: ""
                    color: "black"
                    font.pointSize: Properties.scale
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    horizontalAlignment: Text.AlignHCenter
                }

                function set_name(name) {
                    info_user_name_output.text = name;
                }
            }

            Item {
                id: amount_lives_left
                width: parent.width
                height: Properties.scale
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4 * Properties.scale
                anchors.left: parent.left
                anchors.leftMargin: 0

                property string info_text: "Lives: "

                Text {
                    id: info_amount_lives_left_output
                    text: ""
                    color: "black"
                    font.pointSize: Properties.scale
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    horizontalAlignment: Text.AlignHCenter
                }

                function set_lives(amount) {
                    info_amount_lives_left_output.text = info_text + amount;
                }
            }

            Item {
                id: level_number
                width: parent.width
                height: Properties.scale
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                property string info_text: "Level: "

                Text {
                    id: info_level_number_output
                    text: ""
                    color: "black"
                    font.pointSize: Properties.scale
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        function start() {
            game_screen.visible = true;
            draw_level(battle_field, MapLevels.mapLevels[Logic.get_current_level()]);
            game_screen_show.start();
        }

        function start_game() {
            if (!timer.running) timer.start();
            user_name.set_name(Logic.get_user_name());
            battle_field.focus = true;
            Logic.start(battle_field);
        }
    }

    Rectangle {
        id: winner
        height: 6 * Properties.scale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: "darkgray"
        visible: false
        focus: false

        Text {
            text: "Win!"
            color: "green"
            font.pointSize: 1.5 * Properties.scale
            font.bold: true
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Properties.scale
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: "Click Enter to start again"
            color: "white"
            font.pointSize: Properties.scale
            font.bold: true
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Properties.scale
            horizontalAlignment: Text.AlignHCenter
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Enter || event.key + 1 === Qt.Key_Enter) {
                visible = false;
                focus = false;
                game_screen.start_game();
            }
        }

        function show() {
            visible = true;
            focus = true;
        }
    }

    Rectangle {
        id: loser
        height: 6 * Properties.scale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: "darkgray"
        visible: false
        focus: false

        Text {
            text: "You lose"
            color: "red"
            font.pointSize: 1.5 * Properties.scale
            font.bold: true
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: Properties.scale
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: "Click Enter to start again"
            color: "white"
            font.pointSize: Properties.scale
            font.bold: true
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Properties.scale
            horizontalAlignment: Text.AlignHCenter
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Enter || event.key + 1 === Qt.Key_Enter) {
                visible = false;
                focus = false;
                game_screen.start_game();
            }
        }

        function show() {
            visible = true;
            focus = true;
        }
    }

    function print_lives(amount) {
        amount_lives_left.set_lives(amount);
    }

    function print_level(level) {
        info_level_number_output.text = level_number.info_text + level;
    }

    function draw_amount_enemies() {
        for (var i = info_amount_enemies_output.children.length; i > 0; i--) {
            info_amount_enemies_output.children[i - 1].destroy();
        }
        var pairs = Math.floor(Logic.get_amount_enemies_left() / 2);
        var component1 = Qt.createComponent("counter_enemie_1.qml");
        var component2 = Qt.createComponent("counter_enemie_2.qml");
        for (var j = 0; j < pairs; j++) {
            component2.createObject(info_amount_enemies_output);
        }
        if (pairs * 2 !== Logic.get_amount_enemies_left()) {
            component1.createObject(info_amount_enemies_output);
        }
    }

    function draw_level(container, map_level) {
        var tail_brick = Qt.createComponent("tail_brick.qml");
        var tail_concrete = Qt.createComponent("tail_concrete.qml");
        for (var y = 0; y < map_level.length; ++y) {
            var line = map_level[y];
            for (var x = 0; x < line.length; ++x) {
                if (line[x] === 1) {
                    var object = tail_brick.createObject(container);
                    if (object !== null) object.set_position(x, y);
                } else if (line[x] === 2) {
                    var object = tail_concrete.createObject(container);
                    if (object !== null) object.set_position(x, y);
                }
            }
        }
    }

    function clear_level(container) {
        for (var i = container.children.length; i > 0; i--) {
            container.children[i - 1].destroy();
        }
    }
}
