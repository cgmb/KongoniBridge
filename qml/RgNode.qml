import QtQuick 2.2

Rectangle {
    id: node
    color: selected ? "white" : "grey"

    property bool selected: false
    signal nodeSelected(var node)
    signal nodeRemoved(var node)

    width: 50
    height: width

    border.color: "black"
    border.width: 1.5
    radius: width / 2.0

    onSelectedChanged: {
        if (selected) {
            nodeSelected(node)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                node.selected = true
            } else {
                nodeRemoved(node)
            }
        }
    }
}
