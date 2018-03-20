import QtQuick 2.9
import QtQuick.Window 2.2
import "properties.js" as Properties
import "logic.js" as Logic

Window {
    id: main

    property string battle_field_file: "battle_field.qml"

    visible: true
    width: (Properties.field_width + 6) * Properties.scale
    height: (Properties.field_height + 4) * Properties.scale
    title: qsTr("Battle City")
    color: "gray"

    Item {
        id: battle_field_container
        x: 2 * Properties.scale
        y: 2 * Properties.scale
        width: Properties.field_width * Properties.scale
        height: Properties.field_height * Properties.scale
        Loader {
            id: battle_field_loader
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            source: main.battle_field_file

            onLoaded: {
                Logic.start(item)
            }
        }

        focus: true
        Keys.onPressed: {
            Logic.pressed(event.key)
        }
        Keys.onReleased: {
            Logic.released(event.key)
        }
    }

    Rectangle {
        id: game_info_container
        anchors.left: battle_field_container.right
        anchors.top: battle_field_container.top
        width: 4 * Properties.scale
        height: Properties.field_height * Properties.scale
        color: "gray"
    }
}
