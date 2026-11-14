import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

// Seven-segment display — the elevator floor indicator.
//
// Hour on one row, minute below it, both drawn as vector segments rather than
// set in a typeface, so the shape is exact at any panel thickness instead of
// depending on which fonts happen to be installed.
//
// `ghost` shows the unlit segments faintly behind the lit ones, the way a real
// LED panel does.
//
// No blinking dot here: the segments already are the display, and a dot below
// them reads as a stray element rather than a separator. The settings grey the
// option out while a seven-segment style is selected.
Item {
    id: face

    property var clock
    property real available: width
    property bool ghost: false

    readonly property string hh: clock ? clock.hh : "00"
    readonly property string mm: clock ? clock.mm : "00"
    readonly property string ss: clock ? clock.ss : "00"
    readonly property string ampm: clock ? clock.ampm : ""
    readonly property bool hasDate: clock ? clock.hasDate : false

    readonly property real sidePad: Math.round(available * 0.05)
    readonly property real innerGap: Math.max(2, Math.round(available * 0.06))

    // Two digits plus the gap between them fill the panel width.
    readonly property real digitWidth: (available - sidePad * 2 - innerGap) / 2
    readonly property real digitHeight: digitWidth * 1.85

    readonly property real smallDigitWidth: digitWidth * 0.58
    readonly property real smallDigitHeight: smallDigitWidth * 1.85

    implicitWidth: available
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: face.available
        spacing: Math.round(face.available * 0.08)

        SegmentRow {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            digits: face.hh
            digitWidth: face.digitWidth
            digitHeight: face.digitHeight
            gap: face.innerGap
            ghost: face.ghost
        }

        SegmentRow {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            digits: face.mm
            digitWidth: face.digitWidth
            digitHeight: face.digitHeight
            gap: face.innerGap
            ghost: face.ghost
        }

        SegmentRow {
            visible: Plasmoid.configuration.showSeconds
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            digits: face.ss
            digitWidth: face.smallDigitWidth
            digitHeight: face.smallDigitHeight
            gap: Math.max(1, Math.round(face.innerGap * 0.6))
            ghost: face.ghost
            opacity: 0.8
        }

        FitLabel {
            visible: face.ampm !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: face.digitHeight * 0.32
            font.weight: Font.DemiBold
            opacity: 0.70
            text: face.ampm
        }

        // Segments run to the very edge of their cell, with none of the empty
        // ascender-and-descender band a line of text carries along. The margin
        // that reads as breathing room under type reads as crowding here, so
        // everything below the digits gets markedly more of it.
        //
        // These numbers are smaller than the spine's because the column already
        // adds `spacing` on top of them: the gap that lands on screen is
        // spacing + margin, and both styles end up at the same 0.32 and 0.28.
        //
        // The bottom margin only applies when no date follows, so the underline
        // never sits flush against the panel edge.
        ProgressUnderline {
            visible: Plasmoid.configuration.showProgressUnderline
            clock: face.clock
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.24)
            Layout.bottomMargin: face.hasDate ? 0 : Math.round(face.available * 0.16)
            Layout.preferredHeight: Math.max(2, Math.round(face.available * 0.06))
        }

        DateBlock {
            visible: face.hasDate
            clock: face.clock
            available: face.available
            digitHeight: face.digitHeight
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.20)
            Layout.preferredHeight: implicitHeight
        }
    }
}
