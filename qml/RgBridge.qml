import QtQuick 2.2
import QtMultimedia 5.6
import rustgolem 1.0

Rectangle {
    id: bridge
    color: 'transparent'

    property var selectedNode: null
    property var nodes: []
    property var beams: []

    FEAnalyzer {
        id: analyzer
        onProcessingComplete: {
            for (var i = 0; i < nodeOffsets.length; ++i) {
                nodes[i].x += nodeOffsets[i].x
                nodes[i].y += nodeOffsets[i].y
            }
            for (var i = 0; i < beamStress.length; ++i) {
                beams[i].stress = beamStress[i]
            }
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

    function doAnalysis() {
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
        anchors.fill: parent
        onClicked: {
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
            }
        }
    }

    function updateSelection(node) {
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
        var node = nodeComponent.createObject(window, { "x": x, "y": y });
        node.x -=  node.width / 2
        node.y -=  node.height / 2
        node.nodeSelected.connect(updateSelection)
        node.nodeRemoved.connect(handleNodeRemoved)
        node.wantBeamTo.connect(tryCreateBeamToNode)
        bridge.nodes.push(node)
        return node
    }

    function createBeam(left, right)
    {
        var beamComponent = Qt.createComponent("RgBeam.qml");
        var beam = beamComponent.createObject(window,
            { "leftAnchor": left, "rightAnchor": right });
        beam.beamRemoved.connect(handleBeamRemoved)
        bridge.beams.push(beam)
    }

    Component.onCompleted: {
        var structures = [
            { "x": 500, "y": 300 },
            { "x": 1000, "y": 300 }
        ];

        for (var i = 0; i < structures.length; ++i) {
            var structure = structures[i]
            var node = createNode(snapToGrid(structure.x),
                                  snapToGrid(structure.y))
            node.structural = true
        }
    }
}
