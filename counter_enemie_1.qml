import QtQuick 2.0
import "properties.js" as Properties

Rectangle {
    id: enemie_one
    width: parent.width
    height: Properties.scale
    color: "gray"

    Rectangle {
        width: Properties.scale
        height: Properties.scale
        color: "blue"
        anchors.left: parent.left
        anchors.leftMargin: Properties.scale
    }
}
