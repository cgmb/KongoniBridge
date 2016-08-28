import QtQuick 2.2

Rectangle {
    id: bridge
    color: 'darkgrey'

    property var selectedNode: null
    property var nodes: []

    MouseArea {
        anchors.fill: parent
        onClicked: {
            createNode(mouse.x, mouse.y)
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
    }
}
