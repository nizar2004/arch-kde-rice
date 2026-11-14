import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// The date, one word per line.
//
// On a narrow panel the date is width-bound, not height-bound: "19 Aug" on a
// single line has to fit six glyphs across the panel, which leaves each one
// tiny. Split into "19" over "Aug", every line is two or three glyphs wide and
// scales up several times in exactly the same space.
//
// `dateScale` then caps each line against the clock's digit height, so the date
// stays subordinate to the time instead of competing with it.
Item {
    id: block

    property var clock
    property real available: width
    property real digitHeight: 0

    readonly property var tokens: clock ? clock.dateTokens : []
    readonly property real lineHeight:
        Math.max(1, digitHeight * (Plasmoid.configuration.dateScale / 100))

    implicitWidth: available
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: block.available
        spacing: Math.round(block.available * 0.015)

        Repeater {
            model: block.tokens

            FitLabel {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: block.lineHeight
                font.weight: Font.Medium
                opacity: 0.82
                text: modelData
            }
        }
    }
}
