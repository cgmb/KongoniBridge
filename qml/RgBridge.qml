import QtQuick 2.2

Rectangle {
    id: bridge
    color: 'darkgrey'

    property var selectedNode: null
    property var nodes: []
    property var beams: []

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var node = createNode(mouse.x, mouse.y)
            if (selectedNode)
                createBeam(selectedNode, node)
            node.selected = true
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
        bridge.nodes.push(node)
        return node
    }

    function createBeam(left, right)
    {
        var beamComponent = Qt.createComponent("RgBeam.qml");
        var beam = beamComponent.createObject(window,
            { "leftAnchor": left, "rightAnchor": right });
        bridge.beams.push(beam)
    }
}
