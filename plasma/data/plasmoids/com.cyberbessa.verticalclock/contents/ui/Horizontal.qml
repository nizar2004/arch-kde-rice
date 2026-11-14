import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// Fallback for horizontal panels and for the desktop.
//
// The widget is built for vertical panels, but nothing stops someone dragging
// it onto a horizontal one — so here it falls back to a single line, sized by
// the available height instead of the width.
Item {
    id: face

    property var clock
    property real available: height

    readonly property string timeText: clock ? clock.timeText : "00:00"
    readonly property string dateText: clock ? clock.dateText : ""
    readonly property bool stackDate: dateText !== ""

    // Two lines when there is a date: a little over half the height each.
    readonly property real lineHeight: stackDate ? available * 0.56 : available
    readonly property real dateHeight: available * 0.34

    implicitWidth: Math.ceil(Math.max(timeProbe.contentWidth,
                                      stackDate ? dateProbe.contentWidth : 0))
    implicitHeight: available

    ProbeText {
        id: timeProbe
        label: face.timeText
        boxHeight: face.lineHeight
        weight: Font.DemiBold
    }

    ProbeText {
        id: dateProbe
        label: face.dateText
        boxHeight: face.dateHeight
        weight: Font.Medium
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        FitLabel {
            Layout.fillWidth: true
            Layout.preferredHeight: face.lineHeight
            font.weight: Font.DemiBold
            text: face.timeText
        }

        FitLabel {
            visible: face.stackDate
            Layout.fillWidth: true
            Layout.preferredHeight: face.dateHeight
            font.weight: Font.Medium
            opacity: 0.78
            text: face.dateText
        }
    }
}
