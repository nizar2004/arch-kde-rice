import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

// Hour over minute, each line filling the full panel width.
//
// In `hierarchy` the hour comes in a heavy weight and the minute in a light one
// a little smaller, with an accent rule between them — the hour reads first.
// Without hierarchy both share the same weight and size.
Item {
    id: face

    property var clock
    property real available: width
    property bool hierarchy: true

    // Guarded access: a binding to `undefined` takes the whole drawing down,
    // so every field has a fallback for as long as `clock` is not yet set.
    readonly property string hh: clock ? clock.hh : "00"
    readonly property string mm: clock ? clock.mm : "00"
    readonly property string ss: clock ? clock.ss : "00"
    readonly property string ampm: clock ? clock.ampm : ""
    readonly property bool hasDate: clock ? clock.hasDate : false

    implicitWidth: available
    implicitHeight: column.implicitHeight

    Metrics {
        id: digits
        boxWidth: face.available
        weight: face.hierarchy ? Font.DemiBold : Font.Medium
    }

    ColumnLayout {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: face.available
        spacing: 0

        FitLabel {
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight
            font.weight: face.hierarchy ? Font.DemiBold : Font.Medium
            text: face.hh
        }

        // Accent rule — hierarchy only, and only when the blinking dot is not
        // already taking that spot.
        Rectangle {
            visible: face.hierarchy && !Plasmoid.configuration.blinkSeparator
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Math.round(face.available * 0.05)
            Layout.bottomMargin: Math.round(face.available * 0.05)
            Layout.preferredWidth: Math.round(face.available * 0.34)
            Layout.preferredHeight: Math.max(1, Math.round(face.available * 0.035))
            radius: height / 2
            color: Kirigami.Theme.highlightColor
        }

        BlinkDot {
            visible: Plasmoid.configuration.blinkSeparator
            blinking: Plasmoid.configuration.blinkSeparator
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Math.round(face.available * 0.04)
            Layout.bottomMargin: Math.round(face.available * 0.04)
            Layout.preferredWidth: Math.max(3, Math.round(face.available * 0.085))
            Layout.preferredHeight: Layout.preferredWidth
        }

        FitLabel {
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight * (face.hierarchy ? 0.92 : 1.0)
            font.weight: face.hierarchy ? Font.Light : Font.Medium
            text: face.mm
        }

        FitLabel {
            visible: Plasmoid.configuration.showSeconds
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight * 0.42
            Layout.topMargin: Math.round(face.available * 0.02)
            opacity: 0.75
            text: face.ss
        }

        FitLabel {
            visible: face.ampm !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight * 0.30
            Layout.topMargin: Math.round(face.available * 0.03)
            font.weight: Font.DemiBold
            opacity: 0.70
            text: face.ampm
        }

        ProgressUnderline {
            visible: Plasmoid.configuration.showProgressUnderline
            clock: face.clock
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.14)
            Layout.bottomMargin: Math.round(face.available * 0.04)
            Layout.preferredHeight: Math.max(2, Math.round(face.available * 0.06))
        }

        DateBlock {
            visible: face.hasDate
            clock: face.clock
            available: face.available
            digitHeight: digits.naturalHeight
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.08)
            Layout.preferredHeight: implicitHeight
        }
    }
}
