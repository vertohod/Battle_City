import QtQuick 2.0
import "properties.js" as Properties

Rectangle {
    width: Properties.scale
    height: Properties.scale
    color: "white"
    visible: false;

    function set_position(x_new, y_new) {
        x = x_new * Properties.scale;
        y = y_new * Properties.scale;
        visible = true;
    }
}
