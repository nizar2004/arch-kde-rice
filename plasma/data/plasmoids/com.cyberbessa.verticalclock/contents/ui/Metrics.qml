import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

// Measures how much height a piece of text takes once scaled to fill `boxWidth`.
//
// This is the piece that solves the vertical panel problem: the widget has to
// tell the panel how much height it needs *before* it draws, and that depends
// on the width the panel handed it. The probe is invisible, but Qt lays it out
// all the same — `naturalHeight` comes from there.
//
// The default sample is "00" on purpose: pinning the height to two fixed digits
// keeps the size steady when 11 becomes 08, instead of the clock jumping size
// every minute.
Item {
    id: metrics

    property real boxWidth: 0
    property string sample: "00"
    property int weight: Font.Normal

    readonly property real naturalHeight: probe.contentHeight

    visible: false
    width: 0
    height: 0

    PlasmaComponents.Label {
        id: probe

        visible: false
        text: metrics.sample
        width: Math.max(1, metrics.boxWidth)
        height: 4096

        font.family: Plasmoid.configuration.fontFamily !== ""
            ? Plasmoid.configuration.fontFamily
            : Kirigami.Theme.defaultFont.family
        font.weight: metrics.weight
        font.pixelSize: 1024
        minimumPixelSize: 1
        fontSizeMode: Text.HorizontalFit
        maximumLineCount: 1
        textFormat: Text.PlainText
    }
}
