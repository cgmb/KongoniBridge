#include "FEAnalyzer.h"

#include <math.h>
#include <algorithm>
#include <array>
#include <vector>
#include <Eigen/Dense>
#include <QQuickItem>
#include <QVariant>
#include <QVariantList>
#include <QQmlProperty>
#include <iostream>

struct InputNode
{
    Vec2f pos; // a vector2 with the (x , y) postion of the node in world space in mm
    bool isSupport; // true if input node cannot move
};

struct InputMember
{
    float area; // cross sectioal area of the memmber in mm^2
    float youngsModulus; // the youngs modulus of the member in (kN / mm^2) or GPa
    unsigned nodeI; // the starting node index of the member
    unsigned nodeJ; // the end node index of the member
};

struct Output {
    std::vector<Vec2f> nodeOffsets;
    std::vector<float> memberStressIndicator;
};

struct Node
{
    int id; // the nodes id#
    Vec2f pos; // a vector2 with the (x , y) postion of the node in world space in mm
    bool isSupport; // true if input node cannot move
};

struct Member
{
    float area; // cross sectioal area of the memmber in mm^2
    float youngsModulus; // the youngs modulus of the member in (kN / mm^2) or GPa
    Node nodeI; // the starting node of the member
    Node nodeJ; // the end node of the member
    float length; // the length of the member in mm
    float theta; // the angle of the beam
    std::array<unsigned, 4> dofs; // global degrees of freedom
    // values above this line should be supplied when passing into ComputeDisplacements
    float stress; // will be the stress in the member in (kN/mm^2)
    Eigen::MatrixXf k; // the local stiffness matrix
};

float pixelToWorldX(float x) {
    return x;
}

float worldToPixelOffsetX(float x) {
    return x;
}

float pixelToWorldY(float y) {
    return 900 - y;
}

float worldToPixelOffsetY(float y) {
    return -y;
}

Output computeDisplacements(std::vector<InputNode> inNodes,
                            std::vector<InputMember> inMembers,
                            Eigen::VectorXf externalForces) {

    std::vector<Node> nodes;
    for (unsigned i = 0; i < inNodes.size(); ++i) {
        InputNode in = inNodes[i];
        Node node;
        node.id = i;
        node.pos = in.pos;
        node.isSupport = in.isSupport;
        nodes.push_back(node);
    }

    std::vector<Member> members;
    for (unsigned i = 0; i < inMembers.size(); ++i) {
        InputMember in = inMembers[i];
        Member m;
        m.area = in.area;
        m.youngsModulus = in.youngsModulus;
        m.nodeI = nodes[in.nodeI];
        m.nodeJ = nodes[in.nodeJ];
        Vec2f memberVector = m.nodeJ.pos - m.nodeI.pos;
        m.length = magnitude(memberVector);
        m.theta = atan2f(memberVector.y, memberVector.x);
        m.dofs = {
            in.nodeI * 2,
            in.nodeI * 2 + 1,
            in.nodeJ * 2,
            in.nodeJ * 2 + 1
        };

        float C = cos(m.theta);
        float S = sin(m.theta);

        //construct the member stiffness matrixes 'k' for each member
        Eigen::MatrixXf matA(2, 2);
        matA << C*C, C*S, C*S, S*S;
        Eigen::MatrixXf k(4, 4);
        k << matA, -matA, -matA, matA;

        m.k = (m.area * m.youngsModulus / m.length) * k;
        members.push_back(m);
    }

    Eigen::MatrixXf K(2*nodes.size(), 2*nodes.size());
    K.setZero();  // new matrix size dof, dof, of floats is the struture stiffness matrix
    for (Member& member : members) {
        //distribute the member stiffnesses to the structure stiffness matrix
        for (unsigned i = 0; i < 4; i++) {
            for (unsigned j = 0; j < 4; j++) {
                int A = member.dofs[i];
                int B = member.dofs[j];
                K(A, B) += member.k(i, j);
            }
        }
    }

    for (Node& node : nodes) {
        if (node.isSupport) {
            K.row(node.id * 2).setZero();
            K.col(node.id * 2).setZero();
            K.row(node.id * 2 + 1).setZero();
            K.col(node.id * 2 + 1).setZero();
        }
    }

    Eigen::VectorXf& F = externalForces;
    // std::cout << F<< std::endl;
    // solve [K]{u}={F}
    Eigen::VectorXf u = K.fullPivLu().solve(F);

    for (unsigned i = 0; i < members.size(); ++i) {
        Member& m = members[i];
        Vec2f displacementI = { u(m.nodeI.id * 2), u(m.nodeI.id * 2 + 1) };
        Vec2f displacementJ = { u(m.nodeJ.id * 2), u(m.nodeJ.id * 2 + 1) };
        Vec2f totalDisplacement = displacementJ - displacementI;
        Vec2f memberVector = m.nodeJ.pos - m.nodeI.pos;
        Vec2f memberDirection = memberVector / magnitude(memberVector);
        float projectedDisplacement = dot(totalDisplacement, memberDirection);
        m.stress = projectedDisplacement * m.youngsModulus / m.length;
        /*
        std::cout << i << std::endl;
        std::cout << "Total Displacement: " << totalDisplacement.x << "," << totalDisplacement.y << std::endl;
        std::cout << "Stress: " << m.stress << std::endl;
        */
    }

    Output o;
    o.nodeOffsets.resize(nodes.size());
    for (unsigned i = 0; i < o.nodeOffsets.size(); ++i) {
        o.nodeOffsets[i] = { u(i * 2), u(i * 2 + 1) };
    }
    o.memberStressIndicator.resize(members.size());
    for (unsigned i = 0; i < o.memberStressIndicator.size(); ++i) {
        o.memberStressIndicator[i] = members[i].stress;
    }
    return o;
}

template <class T>
int index_of(const std::vector<T>& v, const T& value) {
    auto it = std::find(v.cbegin(), v.cend(), value);
    if (it == v.cend()) {
        return -1;
    } else {
        return std::distance(v.cbegin(), it);
    }
}

void addBeamWeightToNodes(Eigen::VectorXf& forces,
  const std::vector<InputNode>& inNodes,
  const std::vector<InputMember>& inMembers) {
  const float density = 1.0; // kg/m^3
  const float g = -9.81; //gravity m/s^2 in the y axis
  for (unsigned i = 0; i < inMembers.size(); ++i) {
    Vec2f v = inNodes[inMembers[i].nodeJ].pos - inNodes[inMembers[i].nodeI].pos;
    float length = magnitude(v);
    float mass = density * length * inMembers[i].area;
    float force = mass * g;
    float force_per_node = force / 2;
    forces(2*inMembers[i].nodeI+1) += force_per_node;
    forces(2*inMembers[i].nodeJ+1) += force_per_node;
  }
}

void FEAnalyzer::processBridge(const QVariantList& nodes,
                               const QVariantList& beams) {
    std::vector<InputNode> inNodes;
    std::vector<QQuickItem*> items;
    foreach(QVariant v, nodes) {
        QQuickItem* node = qobject_cast<QQuickItem*>(v.value<QObject*>());
        items.push_back(node);
        InputNode n;
        QVariant support = QQmlProperty::read(node, QStringLiteral("structural"));
        n.isSupport = support.toBool();
        QVariant x = QQmlProperty::read(node, QStringLiteral("x"));
        n.pos.x = pixelToWorldX(x.toReal());
        QVariant y = QQmlProperty::read(node, QStringLiteral("y"));
        n.pos.y = pixelToWorldY(y.toReal());
        inNodes.push_back(n);
    }

    std::vector<InputMember> inMembers;
    foreach(QVariant v, beams) {
        QQuickItem* beam = qobject_cast<QQuickItem*>(v.value<QObject*>());

        QVariant lav = QQmlProperty::read(beam, QStringLiteral("leftAnchor"));
        QQuickItem* la = qobject_cast<QQuickItem*>(lav.value<QObject*>());
        int left_index = index_of(items, la);
        if (left_index < 0) {
            qWarning("beam leftAnchor not in list");
            return;
        }
        QVariant rav = QQmlProperty::read(beam, QStringLiteral("rightAnchor"));
        QQuickItem* ra = qobject_cast<QQuickItem*>(rav.value<QObject*>());
        int right_index = index_of(items, ra);
        if (right_index < 0) {
            qWarning("beam rightAnchor not in list");
            return;
        }
        InputMember m = { 1.0, 1e5,
                          (unsigned)left_index, (unsigned)right_index };
        inMembers.push_back(m);
    }

    Eigen::VectorXf forces(2 * nodes.size());
    forces.setZero();
    addBeamWeightToNodes(forces, inNodes, inMembers);
    Output o = computeDisplacements(inNodes, inMembers, forces);
    QVariantList nodeOffsets;
    for (unsigned i = 0; i < o.nodeOffsets.size(); ++i) {
        QVariantMap offset;
        offset.insert("x", worldToPixelOffsetX(o.nodeOffsets[i].x));
        offset.insert("y", worldToPixelOffsetY(o.nodeOffsets[i].y));
        nodeOffsets.append(QVariant::fromValue(offset));
    }
    QVariantList beamStress;
    for (unsigned i = 0; i < o.memberStressIndicator.size(); ++i) {
        beamStress.append(QVariant::fromValue(o.memberStressIndicator[i]));
    }
    emit processingComplete(nodeOffsets, beamStress);
}

/*
int main()
{
	std::vector<InputNode> nodes = {
		{{0,40}, true},
	  {{20,40}, false},
		{{20,0}, true},
		{{50,0}, true},
	};
	std::vector<InputMember> members = {
		{ 1.5, 1e7, 0, 1 },
		{ 1.0, 1e7, 2, 1 },
		{ 3.0, 1e7, 3, 1 },
	};

	Eigen::VectorXf F(2 * nodes.size());
	F.setZero();
	F(2) = -4000;
	F(3) = -8000;
	Output o = computeDisplacements(nodes, members, F);
	std::cout << "displacements:" << std::endl;
	for (unsigned i = 0; i < o.nodeOffsets.size(); ++i) {
		Vec2f offset = o.nodeOffsets[i];
		std::cout << offset.x << "," << offset.y << std::endl;
	}
	return 0;
}
*/
