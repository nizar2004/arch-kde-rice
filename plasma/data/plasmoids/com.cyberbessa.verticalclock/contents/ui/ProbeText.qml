import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

// Invisible probe: measures how much width a piece of text takes once scaled to
// fill `boxHeight`. The mirror image of Metrics.qml for the swapped axis — used
// by the horizontal fallback, which has to ask the panel for width.
Item {
    id: probe

    property string label: ""
    property real boxHeight: 0
    property int weight: Font.Normal

    readonly property real contentWidth: text.contentWidth

    visible: false
    width: 0
    height: 0

    PlasmaComponents.Label {
        id: text

        visible: false
        text: probe.label
        width: 8192
        height: Math.max(1, probe.boxHeight)

        font.family: Plasmoid.configuration.fontFamily !== ""
            ? Plasmoid.configuration.fontFamily
            : Kirigami.Theme.defaultFont.family
        font.weight: probe.weight
        font.pixelSize: 1024
        minimumPixelSize: 1
        fontSizeMode: Text.VerticalFit
        maximumLineCount: 1
        textFormat: Text.PlainText
    }
}
