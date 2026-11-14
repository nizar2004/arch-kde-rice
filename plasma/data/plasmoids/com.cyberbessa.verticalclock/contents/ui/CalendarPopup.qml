import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.calendar as PlasmaCalendar

// The calendar popup: Plasma's own month view — the same component the built-in
// digital clock shows when you click it, with the same navigation, week numbers
// and keyboard handling.
//
// This lives in a file of its own, reached through a Loader, on purpose.
// MonthView comes from org.kde.plasma.workspace.calendar, which ships with
// plasma-workspace rather than with the frameworks, so it is a notch less
// settled than kirigami or components. Behind a Loader a failed import fails
// alone: the clock in the panel keeps working and only the popup comes up
// empty. Imported from main.qml it would take the whole widget down with it.
PlasmaExtras.Representation {
    id: popup

    property var clock
    property bool expanded: false

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    Layout.minimumWidth: Kirigami.Units.gridUnit * 22
    Layout.minimumHeight: Kirigami.Units.gridUnit * 25
    Layout.maximumWidth: Kirigami.Units.gridUnit * 40
    Layout.maximumHeight: Kirigami.Units.gridUnit * 40

    // The month view draws its own header, so the Representation's is left at
    // zero rather than stacked on top of it.
    collapseMarginsHint: true

    // Back to the current month every time the popup opens or closes, so it
    // never reopens on whichever month was browsed to last.
    onExpandedChanged: monthView.resetToToday()

    PlasmaCalendar.MonthView {
        id: monthView

        // No top margin, on purpose: the month view's own header is meant to sit
        // flush against the top of the popup. Spacing it away leaves a sliver of
        // dead band above the month name that the built-in calendar does not
        // have, and that reads as a misalignment rather than as breathing room.
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.bottomMargin: Kirigami.Units.smallSpacing

        borderOpacity: 0.25

        // Bound to the widget's own tick, so the "today" highlight moves at
        // midnight without the popup having to be reopened.
        today: popup.clock ? popup.clock.now : new Date()

        firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek > -1
            ? Plasmoid.configuration.firstDayOfWeek
            : Qt.locale().firstDayOfWeek
        showWeekNumbers: Plasmoid.configuration.showWeekNumbers

        // That header shows the time and the configured time zones, and reads
        // them off the private digital-clock interface. Off.
        showDigitalClockHeader: false
    }
}
