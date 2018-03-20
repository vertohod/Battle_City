import QtQuick 2.0
import "properties.js" as Properties

Rectangle {
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

    Rectangle {
        width: Properties.scale
        height: Properties.scale
        color: "blue"
        anchors.left: parent.left
        anchors.leftMargin: 2.5 * Properties.scale
    }
}
