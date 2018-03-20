import QtQuick 2.0
import "properties.js" as Properties
import "map_levels.js" as Levels

Rectangle {
    id: battle_field
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    color: "black"

    property Item walls_container: null

    function level_draw(level) {
        walls_container = Qt.createQmlObject("import QtQuick 2.0; Item { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right }", battle_field);

        var map_level = Levels.mapLevels[level];
        var tail_brick = Qt.createComponent("tail_brick.qml");
        var tail_concrete = Qt.createComponent("tail_concrete.qml");
        for (var y = 0; y < map_level.length; ++y) {
            var line = map_level[y];
            for (var x = 0; x < line.length; ++x) {
                if (line[x] === 1) {
                    var object = tail_brick.createObject(walls_container);
                    if (object !== null) object.set_position(x, y);
                } else if (line[x] === 2) {
                    var object = tail_concrete.createObject(walls_container);
                    if (object !== null) object.set_position(x, y);
                }
            }
        }
    }

    function level_clear() {
        if (walls_container !== null) walls_container.destroy();
    }
}
