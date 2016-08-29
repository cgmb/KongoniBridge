import QtQuick 2.2

Image {
    id: instructions
    source: "qrc:/assets/fadedLandscape.png"

    RgText {
        id: title
        text: "Instructions"
        font.pointSize: 48

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: instructionTextBox
        color: Qt.rgba(0, 0, 0, 0.5)
        radius: 10

        anchors.margins: 40
        anchors.top: title.bottom

        anchors.left: parent.left
        anchors.right: parent.right

        height: instructionText.height + 60

        RgText {
            id: instructionText
            color: "white"
            text: {
                "1. Click to select or place nodes.\n" +
                "2. Right click to delete nodes and beams.\n" +
                "3. Shift + Click to connect existing nodes."
            }
            lineHeight: 1.5

            anchors.leftMargin: 60
            anchors.rightMargin: 60
            anchors.bottomMargin: 60
            anchors.topMargin: 50
            anchors.top: parent.top
            anchors.left: parent.left
        }
    }

    RgText {
        text: "Click to Start!"
        font.pointSize: 36
        color: "grey"

        anchors.margins: 50
        anchors.top: instructionTextBox.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: instructions.visible = false
    }
}
