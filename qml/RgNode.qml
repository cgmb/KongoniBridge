import QtQuick 2.2

Rectangle {
    id: node
    color: selected ? "white" : structural ? "grey" : "lightsteelblue"
    z: 2

    property bool structural: false
    property bool selected: false
    property bool editingEnabled: true
    signal nodeSelected(var node)
    signal nodeRemoved(var node)
    signal wantBeamTo(var node)

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
        onPressed: {
            if (mouse.button === Qt.LeftButton) {
                if (mouse.modifiers & Qt.ShiftModifier) {
                    wantBeamTo(node)
                }
                node.selected = true
            } else {
                if (!structural) {
                    nodeRemoved(node)
                }
            }
        }
        drag.target: node.structural ? null : node
        drag.threshold: 0

        enabled: node.editingEnabled
    }

    NumberAnimation on scale {
        id: createAnimation
        easing {
            type: Easing.InOutSine
            amplitude: 100
            period: 10
        }
        from: 1.1
        to: 1
    }

    Component.onCompleted: {
        createAnimation.start()
    }
}
