import QtQuick 2.2
import QtMultimedia 5.6
import rustgolem 1.0

Image {
    id: bridge
    //color: 'transparent'
    //source: "qrc:/assets/colored_desert.png" // desert background
    source: "qrc:/assets/mountainBG.png" // ice background

    property var selectedNode: null
    property var nodes: []
    property var beams: []
    property var save: ({})

    property bool editingEnabled: state == "build"

    states: [
        State {
            name: "build"
            PropertyChanges {
                target: gameTextBox
                visible: false
            }
            StateChangeScript {
                name: "restoreBridge"
                script: restoreBridgeFromTesting()
            }
            PropertyChanges {
                target: mouseArea
                acceptedButtons: Qt.LeftButton
            }
        },
        State {
            name: "test"
            PropertyChanges {
                target: mouseArea
                acceptedButtons: Qt.AllButtons
            }
        }

    ]

    FEAnalyzer {
        id: analyzer
        relaxation: 1
        onProcessingComplete: {
            for (var i = 0; i < nodeOffsets.length; ++i) {
                nodes[i].x += nodeOffsets[i].x * relaxation
                nodes[i].y += nodeOffsets[i].y * relaxation
            }
            for (var i = 0; i < beamStress.length; ++i) {
                beams[i].stress = beamStress[i]
            }
        }
        onFailed: {
            gameTextBox.visible = true
            gameText.text = "Bridge Collapsed!"
            gameText.color = "#fd9500"
        }
        onConverged: {
            gameTextBox.visible = true
            gameText.text = "Success!"
            gameText.color = "#00b050"
        }
    }

    Rectangle {
        id: gameTextBox
        color: Qt.rgba(0, 0, 0, 0.5)
        radius: 10
        z: 3
        visible: false
        anchors.centerIn: parent
        width: gameText.width + 20
        height: gameText.height + 20

        RgText {
            id: gameText
            anchors.centerIn: parent
            font.pointSize: 48
        }
    }

    SoundEffect {
        id: constructSound
        source: "qrc:/assets/construct.wav"
        volume: 0.5
    }

    SoundEffect {
        id: deconstructSound
        source: "qrc:/assets/deconstruct.wav"
        volume: 0.5
    }

    function saveBridgeForTesting() {
        var xPositions = []
        var yPositions = []
        for (var i = 0; i < nodes.length; ++i) {
            xPositions.push(nodes[i].x)
            yPositions.push(nodes[i].y)
        }
        save.xPositions = xPositions;
        save.yPositions = yPositions;
    }

    function restoreBridgeFromTesting() {
        if (save.xPositions && save.yPositions) {
            for (var i = 0; i < nodes.length; ++i) {
                nodes[i].x = save.xPositions[i]
                nodes[i].y = save.yPositions[i]
            }
        }
        for (i = 0; i < beams.length; ++i) {
            beams[i].stress = 0
        }
    }

    function doAnalysis() {
        bridge.state = "test"
        saveBridgeForTesting()
        analyzer.processBridge(nodes, beams)
    }

    function snapToGrid(x) {
        /*
        var scale = 100
        return scale * Math.round(x / scale)
        */
        return x // we need to sort a few other things out before doing this
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (bridge.state == "test") {
                bridge.state = "build"
                return
            }

            var node = createNode(snapToGrid(mouse.x),
                                  snapToGrid(mouse.y))
            if (selectedNode)
                createBeam(selectedNode, node)
            node.selected = true
            constructSound.play()
        }
    }

    function tryCreateBeamToNode(node) {
        if (selectedNode && node !== selectedNode) {
            var alreadyExists = false
            for (var i = 0; i < bridge.beams.length; ++i) {
                var beam = bridge.beams[i]
                if ((beam.leftAnchor === selectedNode &&
                     beam.rightAnchor === node)||
                    (beam.leftAnchor === node &&
                     beam.rightAnchor === selectedNode)) {
                    alreadyExists = true
                }
            }
            if (!alreadyExists) {
                createBeam(selectedNode, node)
                constructSound.play()
                bridge.state = "build"
            }
        }
    }

    function updateSelection(node) {
        bridge.state = "build"

        if (selectedNode) {
            selectedNode.selected = false
        }
        selectedNode = node
        selectedNode.selected = true
    }

    function handleNodeRemoved(node) {
        if (selectedNode === node) {
            selectedNode = null
        }
        for (var i = bridge.beams.length - 1; i >= 0; --i) {
            var beam = bridge.beams[i];
            if (beam.leftAnchor === node ||
                beam.rightAnchor === node) {
                bridge.beams.splice(i, 1);
                beam.destroy()
            }
        }

        removeItemFromList(node, bridge.nodes)
        node.destroy()
        deconstructSound.play()
    }

    function handleBeamRemoved(beam) {
        removeItemFromList(beam, bridge.beams)
        beam.destroy()
        deconstructSound.play()
    }

    function removeItemFromList(item, list) {
        var index = list.indexOf(item)
        if (index >= 0) {
            list.splice(index, 1);
        }
    }

    function createNode(x, y)
    {        
        var nodeComponent = Qt.createComponent("RgNode.qml");
        var node = nodeComponent.createObject(bridge, { "x": x, "y": y });
        node.x -=  node.width / 2
        node.y -=  node.height / 2
        node.nodeSelected.connect(updateSelection)
        node.nodeRemoved.connect(handleNodeRemoved)
        node.wantBeamTo.connect(tryCreateBeamToNode)
        node.editingEnabled = Qt.binding(function () { return bridge.editingEnabled })
        bridge.nodes.push(node)
        return node
    }

    function createBeam(left, right)
    {
        var beamComponent = Qt.createComponent("RgBeam.qml");
        var beam = beamComponent.createObject(bridge,
            { "leftAnchor": left, "rightAnchor": right });
        beam.beamRemoved.connect(handleBeamRemoved)
        beam.editingEnabled = Qt.binding(function () { return bridge.editingEnabled })
        bridge.beams.push(beam)
    }

    Component.onCompleted: {
        /*
        // support locations for Desert
        var structures = [
            { "x": 450, "y": 660},
            { "x": 1100, "y": 650 }
        ];
        */

        // support locations for ice
        var structures = [
            { "x": 350, "y": 645},
            { "x": 1250, "y": 645},
            {"x": 795, "y": 825}
        ];

        for (var i = 0; i < structures.length; ++i) {
            var structure = structures[i]
            var node = createNode(snapToGrid(structure.x),
                                  snapToGrid(structure.y))
            node.structural = true
        }

        state = "build"
    }
}
