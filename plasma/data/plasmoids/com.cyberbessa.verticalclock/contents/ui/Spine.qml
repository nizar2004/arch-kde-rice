import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

// Spine: the whole time rotated 90 degrees, read like the spine of a book.
// It is the style that spends the least panel height.
//
// `withDate` puts the date in a second rotated column beside it. Under the
// clockwise rotation (the default) the right-hand column is the one that reads
// as the first line, so the time goes there; flipping the direction swaps them.
Item {
    id: face

    property var clock
    property real available: width
    property bool withDate: false

    readonly property string timeText: clock ? clock.timeText : "00:00"
    readonly property string dateText: clock ? clock.dateText : ""
    readonly property bool twoColumns: withDate && dateText !== ""
    readonly property bool dateBelow: !twoColumns && dateText !== ""
    readonly property bool topToBottom: Plasmoid.configuration.spineTopToBottom

    // Kept tight on purpose: every pixel of gap comes straight out of the
    // column widths, and the columns are what set the font size.
    readonly property real gap: twoColumns ? Math.max(1, Math.round(available * 0.02)) : 0
    readonly property real timeColumn: twoColumns ? (available - gap) * 0.60 : available
    readonly property real dateColumn: (available - gap) * 0.40

    implicitWidth: available
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: face.available
        spacing: 0

        RowLayout {
            id: row

            Layout.alignment: Qt.AlignHCenter
            spacing: face.gap

            // Under the clockwise rotation the time belongs on the right, under
            // the anticlockwise one on the left. Mirroring the row gets that
            // without writing the two children twice.
            LayoutMirroring.enabled: face.topToBottom
            LayoutMirroring.childrenInherit: false

            SpineText {
                label: face.timeText
                colWidth: face.timeColumn
                weight: Font.DemiBold
                topToBottom: face.topToBottom
                Layout.alignment: face.topToBottom ? Qt.AlignTop : Qt.AlignBottom
            }

            SpineText {
                visible: face.twoColumns
                label: face.dateText
                colWidth: face.dateColumn
                weight: Font.Medium
                topToBottom: face.topToBottom
                opacity: 0.78
                Layout.alignment: face.topToBottom ? Qt.AlignTop : Qt.AlignBottom
            }
        }

        // Rotated text runs flush to its own ends along the panel axis: the
        // empty ascender-and-descender band that gives an upright line its
        // breathing room lies to the sides here, not above and below. So
        // everything stacked under a spine needs markedly more clearance than
        // the same thing under a line of type.
        //
        // The bottom margin only applies when nothing follows — with the date in
        // a column of its own the underline is the last item in the widget and
        // would otherwise sit flush against the panel edge.
        ProgressUnderline {
            visible: Plasmoid.configuration.showProgressUnderline
            clock: face.clock
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.32)
            Layout.bottomMargin: face.dateBelow ? 0 : Math.round(face.available * 0.16)
            Layout.preferredHeight: Math.max(2, Math.round(face.available * 0.06))
        }

        // With the date already in its own column there is nothing left to put
        // below. Without it, the date (if on) goes under the spine, upright.
        DateBlock {
            visible: face.dateBelow
            clock: face.clock
            available: face.available
            digitHeight: face.available
            Layout.fillWidth: true
            Layout.topMargin: Math.round(face.available * 0.28)
            Layout.preferredHeight: implicitHeight
        }
    }
}
