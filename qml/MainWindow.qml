import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.1

ApplicationWindow {
    id: window
    visible: true
    title: "Bridge"
    color: "skyblue"

    FontLoader {
        source: "qrc:/fonts/SourceSansPro-Regular.otf"
    }

    width: 1440
    height: 900

    RgBridge {
        id: bridge
        anchors.fill: parent
    }

    RgButton {
        id: quitButton
        text: "Quit"
        onClicked: Qt.quit()

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
    }

    RgButton {
        id: testButton
        text: "Test"
        onClicked: bridge.doAnalysis()

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    RgText {
        id: description
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        text: "If you build it, they will come..."
        wrapMode: Text.WordWrap
    }

   Component.onCompleted: {

   }
}
