import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.1
import rustgolem 1.0

ApplicationWindow {
    visible: true
    title: "Rust"
    color: "grey"

    FontLoader {
        source: "qrc:/fonts/SourceSansPro-Regular.otf"
    }

   RgButton {
       id: quitButton
       text: "Quit"
       onClicked: Qt.quit()

       anchors.margins: 20
       anchors.bottom: parent.bottom
       anchors.left: parent.left
   }

    width: 1440
    height: 900

    Field {
        id: field
        x: 50
        y: 50
    }

    Card {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
    }

    Rectangle {
        width: 660
        height: 70

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.left: quitButton.right

        color: "lightgrey"
        border.color: "black"
        border.width: 4
        radius: 10

        Row {
            x: 10; y: 10
            spacing: 10
            anchors.margins: 20

            RgButton {
                text: 'Create Game'
                onClicked: msgr.requestCreateGame()
            }

            SpinBox {
                id: joinGameEdit
                font.family: "Source Sans Pro"
                font.pointSize: 24
                minimumValue: 0
                maximumValue: 128
            }

            RgButton {
                text: 'Join Game'
                onClicked: msgr.requestJoinGame(joinGameEdit.value)
            }

            RgText {
                id: gameDisplay
                text: 'Game: N/A'
            }
        }
    }

    Rectangle {
        id: connectionStatus
        color: msgr.isConnected ? "green" : "red"

        width: 50
        height: width

        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        border.color: "black"
        border.width: 1
        radius: width / 2.0

        MouseArea {
            anchors.fill: parent
            onClicked: msgr.connect()
        }
    }

    SoftwareUpdater {
        id: updater
        onUpdateAvailable: updateDialog.visible = true
        onDownloadProgressChanged: progressBar.value = percentage
        onDownloadFinished: {
            progressBar.indeterminate = true
            description.text = "Installing..."
            installUpdates()
        }
        onInstallFinished: {
            updateDialog.visible = false
            destroy()
        }
    }

    Messenger {
        id: msgr
        onJoinedGame: gameDisplay.text = 'Game: ' + gameId
        onPlacedBlock: field.toggle(x,y)
    }

    Rectangle {
        id: updateDialog
        width: 400
        height: 200
        anchors.centerIn: parent
        visible: false

        color: "lightBlue"
        border.color: "black"
        border.width: 4
        radius: 10

        RgText {
            id: description
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            text: "An update is available. Download now?"
            wrapMode: Text.WordWrap
        }

        ProgressBar {
            id: progressBar
            visible: false
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 30
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: description.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 5
            RgButton {
                text: 'Download'
                onClicked: {
                    updater.downloadUpdates()
                    parent.visible = false
                    progressBar.visible = true
                }
            }
            RgButton {
                text: 'Cancel'
                onClicked: updateDialog.visible = false
            }
        }
    }

   Component.onCompleted: {
       updater.checkForUpdates()
   }
}
