import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

// Numbers inside rounded pills — separates hour from minute without needing a
// colon. `single` wraps both in one pill and pushes the date outside it.
//
// The pill colour is picked in the settings. "neutral" derives from the theme's
// own text colour, so it tracks light and dark without looking tinted.
Item {
    id: face

    property var clock
    property real available: width
    property bool single: false

    readonly property string hh: clock ? clock.hh : "00"
    readonly property string mm: clock ? clock.mm : "00"
    readonly property string ss: clock ? clock.ss : "00"
    readonly property string ampm: clock ? clock.ampm : ""
    readonly property bool hasDate: clock ? clock.hasDate : false

    readonly property real pad: Math.round(available * 0.09)
    readonly property real corner: Math.round(available * 0.24)

    readonly property bool solidPill: Plasmoid.configuration.blockColor !== "neutral"

    readonly property color pillColor: {
        switch (Plasmoid.configuration.blockColor) {
        case "white":  return "#f2f4f6";
        case "gray":   return "#6f7880";
        case "black":  return "#16181b";
        case "blue":   return "#2f6fb0";
        case "orange": return "#d4780f";
        case "yellow": return "#e0b400";
        }
        // neutral — the theme's text colour at low alpha, so the pill reads as
        // a tint of the panel instead of a colour of its own.
        return Qt.rgba(Kirigami.Theme.textColor.r,
                       Kirigami.Theme.textColor.g,
                       Kirigami.Theme.textColor.b, 0.14);
    }

    // On a solid pill the theme's text colour can disappear — white on white.
    // So the digits switch to near-black or near-white by the pill's luminance.
    readonly property color pillTextColor: {
        if (!solidPill) {
            return Kirigami.Theme.textColor;
        }
        var luma = 0.299 * pillColor.r + 0.587 * pillColor.g + 0.114 * pillColor.b;
        return luma > 0.55 ? "#16181b" : "#f5f7f8";
    }

    implicitWidth: available
    implicitHeight: column.implicitHeight

    Metrics {
        id: digits
        boxWidth: face.available * 0.78
        weight: Font.DemiBold
    }

    ColumnLayout {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: face.available
        spacing: 0

        // --- one pill: hour and minute together ---
        Rectangle {
            visible: face.single
            Layout.fillWidth: true
            Layout.preferredHeight: singleStack.implicitHeight + face.pad * 2
            radius: face.corner
            color: face.pillColor

            ColumnLayout {
                id: singleStack
                anchors.centerIn: parent
                width: parent.width
                spacing: 0

                FitLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: digits.naturalHeight
                    font.weight: Font.DemiBold
                    color: face.pillTextColor
                    text: face.hh
                }
                FitLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: digits.naturalHeight
                    font.weight: Font.Light
                    color: face.pillTextColor
                    text: face.mm
                }
                FitLabel {
                    visible: Plasmoid.configuration.showSeconds
                    Layout.fillWidth: true
                    Layout.preferredHeight: digits.naturalHeight * 0.44
                    opacity: 0.8
                    color: face.pillTextColor
                    text: face.ss
                }
            }
        }

        // --- two pills: one per field ---
        Rectangle {
            visible: !face.single
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight + face.pad * 2
            radius: face.corner
            color: face.pillColor

            FitLabel {
                anchors.centerIn: parent
                width: parent.width
                height: digits.naturalHeight
                font.weight: Font.DemiBold
                color: face.pillTextColor
                text: face.hh
            }
        }

        Item {
            visible: !face.single
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(face.available * 0.09)
        }

        Rectangle {
            visible: !face.single
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight + face.pad * 2
            radius: face.corner
            color: face.pillColor

            FitLabel {
                anchors.centerIn: parent
                width: parent.width
                height: digits.naturalHeight
                font.weight: Font.DemiBold
                color: face.pillTextColor
                text: face.mm
            }
        }

        Rectangle {
            visible: !face.single && Plasmoid.configuration.showSeconds
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.06)
            Layout.preferredHeight: digits.naturalHeight * 0.50 + face.pad
            radius: face.corner
            color: face.pillColor

            FitLabel {
                anchors.centerIn: parent
                width: parent.width
                height: digits.naturalHeight * 0.50
                opacity: 0.85
                color: face.pillTextColor
                text: face.ss
            }
        }

        FitLabel {
            visible: face.ampm !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: digits.naturalHeight * 0.30
            Layout.topMargin: Math.round(face.available * 0.05)
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
