import QtQuick 2.2

Rectangle {
    id: beam
    color: "blue"

    property var leftAnchor
    property var rightAnchor

    x: leftAnchor.x + leftAnchor.width / 2  - 4
    y: leftAnchor.y + leftAnchor.height / 2 - height / 2

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
    height: 10

    border.color: "black"
    border.width: 1.5
    radius: 4

    transform: Rotation {
        origin.x: 4
        origin.y: beam.height / 2
        angle: calcAngle() * (180 / Math.PI)
    }
}
