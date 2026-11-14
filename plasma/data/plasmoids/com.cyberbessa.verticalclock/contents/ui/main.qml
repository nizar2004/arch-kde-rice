import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

// A clock for vertical panels.
//
// The clock itself is the compact representation, the one that lives in the
// panel; clicking it opens Plasma's month view as the full representation, the
// same way the built-in digital clock behaves.
//
// No org.kde.plasma.private.* anywhere — that is what makes the digital-clock
// forks stop loading after a Plasma update.
PlasmoidItem {
    id: root

    ClockSource {
        id: clockSource
    }

    toolTipMainText: clockSource.longTime
    toolTipSubText: clockSource.longDate

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground

    preferredRepresentation: compactRepresentation

    // ---------------------------------------------------------------- popup
    fullRepresentation: Loader {
        id: popupLoader

        source: "CalendarPopup.qml"

        Layout.minimumWidth: Kirigami.Units.gridUnit * 22
        Layout.minimumHeight: Kirigami.Units.gridUnit * 25
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        onLoaded: item.clock = clockSource

        Binding {
            target: popupLoader.item
            property: "expanded"
            value: root.expanded
            when: popupLoader.status === Loader.Ready
        }

        // Only ever seen if the workspace calendar module is missing, which
        // would otherwise leave a blank popup with no explanation.
        PlasmaComponents.Label {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit * 2
            visible: popupLoader.status === Loader.Error
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "The calendar could not be loaded. It needs the QML module "
                + "org.kde.plasma.workspace.calendar, which normally ships with Plasma."
        }
    }

    // ---------------------------------------------------------------- clock
    //
    // A MouseArea, not a plain Item: Plasma does not open the popup by itself
    // for a compact representation that ignores the mouse. The clock has to
    // toggle `expanded` on its own, the same way the built-in one does.
    compactRepresentation: MouseArea {
        id: widget

        // Plasma closes the popup on press, before the click ever lands — so
        // reading `expanded` inside onClicked would find it already false and
        // reopen what the user meant to close. Capturing the state at press
        // time is what makes a click on an open popup close it.
        property bool wasExpanded: false

        acceptedButtons: Qt.LeftButton
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Accessible.role: Accessible.Button
        Accessible.name: root.toolTipMainText
        Accessible.description: root.toolTipSubText
        Accessible.onPressAction: root.expanded = !root.expanded

        readonly property bool isHorizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property bool inPanel: isHorizontal || isVertical

        // On a vertical panel the panel dictates the width and the widget asks
        // for height; on a horizontal one it is the other way round. Off-panel
        // the user's own sizing wins, so take the smaller side.
        readonly property real available: isVertical ? width
            : isHorizontal ? height
            : Math.min(width, height)

        // Seven-segment cells and rotated spine text both run flush to their
        // own edges along the panel axis — neither carries the empty
        // ascender-and-descender band an upright line of text brings along.
        // Ornaments next to them need markedly more clearance to read as
        // separated rather than crowded.
        readonly property bool flushStyle: {
            var s = Plasmoid.configuration.clockStyle;
            return s === "segmentClean" || s === "segmentGhost"
                || s === "spineTime" || s === "spineBoth";
        }

        Layout.fillWidth: isVertical
        Layout.fillHeight: isHorizontal

        Layout.minimumWidth: isHorizontal ? stack.implicitWidth
            : (inPanel ? -1 : Kirigami.Units.gridUnit * 3)
        Layout.minimumHeight: isVertical ? stack.implicitHeight
            : (inPanel ? -1 : Kirigami.Units.gridUnit * 3)

        Layout.preferredWidth: inPanel ? stack.implicitWidth : Kirigami.Units.gridUnit * 6
        Layout.preferredHeight: inPanel ? stack.implicitHeight : Kirigami.Units.gridUnit * 6

        ColumnLayout {
            id: stack

            anchors.centerIn: parent
            width: widget.isHorizontal ? implicitWidth : parent.width
            spacing: 0

            // Ornament: hairline above the clock, separating it from the tray.
            Rectangle {
                visible: Plasmoid.configuration.showTopSeparator && !widget.isHorizontal
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: Math.round(widget.available * (widget.flushStyle ? 0.34 : 0.18))
                Layout.preferredWidth: Math.round(widget.available * 0.55)
                Layout.preferredHeight: Math.max(1, Math.round(widget.available * 0.025))
                radius: height / 2
                color: Kirigami.Theme.textColor
                opacity: 0.25
            }

            Loader {
                id: face

                Layout.fillWidth: !widget.isHorizontal
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight

                sourceComponent: {
                    if (widget.isHorizontal) {
                        return horizontalFace;
                    }
                    switch (Plasmoid.configuration.clockStyle) {
                    case "stackedSymmetric":
                    case "stackedHierarchy":
                        return stackedFace;
                    case "blocksTwo":
                    case "blocksOne":
                        return blocksFace;
                    case "spineTime":
                    case "spineBoth":
                        return spineFace;
                    case "segmentClean":
                    case "segmentGhost":
                        return segmentFace;
                    }
                    return stackedFace;
                }
            }
        }

        Component {
            id: stackedFace
            Stacked {
                clock: clockSource
                available: widget.available
                hierarchy: Plasmoid.configuration.clockStyle === "stackedHierarchy"
            }
        }

        Component {
            id: blocksFace
            Blocks {
                clock: clockSource
                available: widget.available
                single: Plasmoid.configuration.clockStyle === "blocksOne"
            }
        }

        Component {
            id: spineFace
            Spine {
                clock: clockSource
                available: widget.available
                withDate: Plasmoid.configuration.clockStyle === "spineBoth"
            }
        }

        Component {
            id: segmentFace
            SevenSegment {
                clock: clockSource
                available: widget.available
                ghost: Plasmoid.configuration.clockStyle === "segmentGhost"
            }
        }

        Component {
            id: horizontalFace
            Horizontal {
                clock: clockSource
                available: widget.available
            }
        }
    }
}
