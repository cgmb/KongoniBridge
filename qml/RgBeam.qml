import QtQuick 2.2
import "qrc:/js/colormap.js" as ColorMap

Rectangle {
    id: beam

    property int index: -1
    property var leftAnchor
    property var rightAnchor
    property var stress
    property real maxStress: 3.5e8
    signal beamRemoved(var beam)

    x: leftAnchor.x + leftAnchor.width / 2  - 4
    y: leftAnchor.y + leftAnchor.height / 2 - height / 2
    z: 1

    function clamp(low, x, high) {
        return Math.min(Math.max(low, x), high)
    }

    function calcColor() {
        if (stress === undefined) {
            return "lightgrey"
        }

        var normalizedStress = clamp(-1, stress / maxStress, 1)
        normalizedStress += 1;
        normalizedStress /= 2;

        var c = ColorMap.map(normalizedStress)
        return Qt.rgba(c[0], c[1], c[2], 1)
    }

    color: calcColor()

    function calcWidth() {
        var dx = rightAnchor.x - leftAnchor.x
        var dy = rightAnchor.y - leftAnchor.y
        return Math.sqrt(dx*dx + dy*dy)
    }

    function calcAngle() {
        var dx = rightAnchor.x - leftAnchor.x
        var dy = rightAnchor.y - leftAnchor.y
        return Math.atan2(dy, dx)
    }

    width: calcWidth() + 8
    height: 12

    border.color: "black"
    border.width: 1.5
    radius: 4

    Text {
        text: beam.index
        anchors.centerIn: parent
        color: "green"
        font.pointSize: 36
        visible: beam.index >= 0
    }

    transform: Rotation {
        origin.x: 4
        origin.y: beam.height / 2
        angle: calcAngle() * (180 / Math.PI)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                beamRemoved(beam)
            }
        }
    }
}
