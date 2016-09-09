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

        visible: bridge.state == "build"

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
/*
    Slider {
        id: stressSlider
        minimumValue: -3.5e8
        maximumValue: 3.5e8

        onValueChanged: {
            for (var i = 0; i < bridge.beams.length; ++i) {
                bridge.beams[i].stress = value
            }
        }

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 600
    }

    Text {
        id: stressValue
        text: 'stress: ' + Math.round(stressSlider.value / 1e6) + 'MPa'
        anchors.margins: 20
        anchors.bottom: stressSlider.top
        anchors.left: parent.left
    }
*/
    Instructions {
        anchors.fill: parent
    }
}
