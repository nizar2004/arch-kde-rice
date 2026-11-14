import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

// Ornament: a rule under the digits that fills left to right as the current
// hour — or the whole day — goes by.
//
// It runs horizontally, across the width the widget already has, rather than
// squeezing a vertical bar in beside the text.
Item {
    id: bar

    property var clock

    readonly property real fraction: {
        if (!clock) {
            return 0;
        }
        return Plasmoid.configuration.progressPeriod === "day"
            ? clock.dayFraction
            : clock.hourFraction;
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(Kirigami.Theme.textColor.r,
                       Kirigami.Theme.textColor.g,
                       Kirigami.Theme.textColor.b, 0.18)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Math.max(parent.height, parent.width * bar.fraction)
        radius: height / 2
        color: Kirigami.Theme.highlightColor

        Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }
}
