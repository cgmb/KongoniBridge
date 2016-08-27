import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Button {
    id: button
    style: ButtonStyle {
        label: RgText {
            text: button.text
        }
    }
}
