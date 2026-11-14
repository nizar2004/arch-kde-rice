import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

// A single column of text rotated 90 degrees.
//
// The invisible probe measures the text *before* the rotation: its width
// becomes the column's height, and its height becomes the width. Without that
// measurement there is no way to tell the panel how much height the spine takes
// — and binding the label's width to its own contentWidth would be a loop.
//
// `heightBoost` exists because Text.VerticalFit fits the *line box* — ascender
// through descender — into the height it is given, while digits only occupy
// about 72% of that band. Sizing against a taller box makes the glyphs
// themselves fill the column instead of stopping well short of it. The extra
// band is empty space above and below the digits, so it does not collide with
// the neighbouring column.
Item {
    id: spine

    property string label: ""
    property real colWidth: 0
    property int weight: Font.DemiBold
    property bool topToBottom: true
    property real heightBoost: 1.28

    readonly property real fitHeight: Math.max(1, colWidth * heightBoost)

    readonly property string faceFamily: Plasmoid.configuration.fontFamily !== ""
        ? Plasmoid.configuration.fontFamily
        : Kirigami.Theme.defaultFont.family

    implicitWidth: colWidth
    implicitHeight: Math.ceil(probe.contentWidth)

    PlasmaComponents.Label {
        id: probe

        visible: false
        text: spine.label
        width: 8192
        height: spine.fitHeight

        font.family: spine.faceFamily
        font.weight: spine.weight
        font.pixelSize: 1024
        minimumPixelSize: 1
        fontSizeMode: Text.VerticalFit
        maximumLineCount: 1
        textFormat: Text.PlainText
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent

        // Size before the rotation. Rotated 90 degrees the box becomes
        // (fitHeight x contentWidth), centred on the column.
        width: Math.max(1, Math.ceil(probe.contentWidth))
        height: spine.fitHeight
        rotation: spine.topToBottom ? 90 : -90

        text: spine.label
        font.family: spine.faceFamily
        font.weight: spine.weight
        font.pixelSize: 1024
        minimumPixelSize: 1
        fontSizeMode: Text.VerticalFit
        maximumLineCount: 1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
    }
}
