import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.1
import QtMultimedia 5.6

ApplicationWindow {
    id: window
    visible: true
    title: "Bridge"
    color: "skyblue"

    FontLoader {
        source: "qrc:/fonts/SourceSansPro-Regular.otf"
    }

    Audio {
        source: "qrc:/assets/caravanLooping.ogg"
        loops: Audio.Infinite
        autoPlay: true
    }

    width: 1440
    height: 900

    RgBridge {
        id: bridge
        anchors.fill: parent
    }

    RgButton {
        id: testButton
        text: "Test"
        onClicked: bridge.doAnalysis()

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    Instructions {
        anchors.fill: parent
    }
}
