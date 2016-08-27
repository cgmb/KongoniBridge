import QtQuick 2.2

Rectangle {
    id: field
    width: childrenRect.width + 8
    height: childrenRect.height + 8
    color: "black"

    function toggle(x, y) {
        var item = repeater.itemAt(y * grid.columns + x)
        if (item) {
            if (Qt.colorEqual(item.color, "red")) {
                item.color = "white"
            } else {
                item.color = "red"
            }
        }
    }

    Grid {
        id: grid
        x: 4; y: 4
        rows: 11
        columns: 22
        spacing: 4

        Repeater {
            id: repeater
            model: parent.rows * parent.columns
            Rectangle {
                width: 48
                height: 48
                color: "white"
                MouseArea {
                    anchors.fill: parent
                    onClicked: msgr.requestPlaceBlock(1, index % grid.columns, index / grid.columns);
                }
            }
        }
    }
}
