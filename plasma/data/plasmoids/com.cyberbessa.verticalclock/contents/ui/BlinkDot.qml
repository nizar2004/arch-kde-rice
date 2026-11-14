import QtQuick
import org.kde.kirigami as Kirigami

// Accent dot that blinks once a second.
//
// It carries its own Timer because the ornament can be on while seconds are
// off — and in that case the clock's own tick only wakes once a minute.
Rectangle {
    id: dot

    property bool blinking: false
    property bool lit: true

    radius: width / 2
    color: Kirigami.Theme.highlightColor
    opacity: lit ? 1.0 : 0.18

    Behavior on opacity {
        NumberAnimation { duration: 120 }
    }

    Timer {
        interval: 1000
        repeat: true
        running: dot.blinking && dot.visible
        onTriggered: dot.lit = !dot.lit
        onRunningChanged: {
            if (!running) {
                dot.lit = true;
            }
        }
    }
}
