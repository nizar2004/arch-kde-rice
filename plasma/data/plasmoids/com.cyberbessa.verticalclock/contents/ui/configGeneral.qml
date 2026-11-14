import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// The settings dialog reads and writes every property on this root named
// cfg_<key>. Plain bools and strings alias straight to their control; the two
// combo boxes and the slider keep the value in a property of their own and sync
// the control, because what the config stores is the key, not a position.
Kirigami.FormLayout {
    id: page

    property string cfg_clockStyle: "stackedHierarchy"
    property string cfg_blockColor: "neutral"
    property string cfg_progressPeriod: "hour"
    property int cfg_firstDayOfWeek: -1
    property string cfg_fontFamily: ""
    property int cfg_dateScale: 45

    property alias cfg_showDate: showDate.checked
    property alias cfg_showWeekday: showWeekday.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_use24Hour: use24Hour.checked
    property alias cfg_dateFormat: dateFormat.text
    property alias cfg_showProgressUnderline: progressUnderline.checked
    property alias cfg_showTopSeparator: topSeparator.checked
    property alias cfg_blinkSeparator: blinkSeparator.checked
    property alias cfg_spineTopToBottom: spineTopToBottom.checked
    property alias cfg_showWeekNumbers: showWeekNumbers.checked

    readonly property var styles: [
        { key: "stackedHierarchy", label: "Stacked · hierarchy" },
        { key: "stackedSymmetric", label: "Stacked · symmetric" },
        { key: "blocksTwo",        label: "Blocks · two pills" },
        { key: "blocksOne",        label: "Blocks · single pill" },
        { key: "spineTime",        label: "Spine · time only" },
        { key: "spineBoth",        label: "Spine · time and date" },
        { key: "segmentClean",     label: "Seven-segment · clean" },
        { key: "segmentGhost",     label: "Seven-segment · with ghost segments" }
    ]

    readonly property var blockColors: [
        { key: "neutral", label: "Neutral (follows the theme)" },
        { key: "white",   label: "White" },
        { key: "gray",    label: "Gray" },
        { key: "black",   label: "Black" },
        { key: "blue",    label: "Blue" },
        { key: "orange",  label: "Orange" },
        { key: "yellow",  label: "Yellow" }
    ]

    readonly property var periods: [
        { key: "hour", label: "Current hour" },
        { key: "day",  label: "Whole day" }
    ]

    readonly property var weekStarts: [
        { day: -1, label: "Follow the system locale" },
        { day: 0,  label: "Sunday" },
        { day: 1,  label: "Monday" },
        { day: 6,  label: "Saturday" }
    ]

    function indexOfWeekStart(day) {
        for (var i = 0; i < weekStarts.length; i++) {
            if (weekStarts[i].day === day) {
                return i;
            }
        }
        return 0;
    }

    // Index 0 is the theme font; the rest come from the system.
    readonly property var fontChoices: {
        var families = Qt.fontFamilies();
        var out = new Array(families.length + 1);
        out[0] = "Theme font";
        for (var i = 0; i < families.length; i++) {
            out[i + 1] = families[i];
        }
        return out;
    }

    readonly property bool spineSelected:
        cfg_clockStyle === "spineTime" || cfg_clockStyle === "spineBoth"
    readonly property bool blocksSelected:
        cfg_clockStyle === "blocksTwo" || cfg_clockStyle === "blocksOne"
    readonly property bool stackedSelected:
        cfg_clockStyle === "stackedHierarchy" || cfg_clockStyle === "stackedSymmetric"

    // Kept in step with metadata.json by build.sh, which refuses to package if
    // the two disagree. It is here so that "did my install actually take?" has
    // an answer that does not involve digging through ~/.local/share.
    readonly property string widgetVersion: "2.8"

    function indexIn(table, key) {
        for (var i = 0; i < table.length; i++) {
            if (table[i].key === key) {
                return i;
            }
        }
        return 0;
    }

    function indexOfFont(family) {
        if (family === "") {
            return 0;
        }
        var at = fontChoices.indexOf(family);
        return at < 0 ? 0 : at;
    }

    onCfg_clockStyleChanged: styleBox.currentIndex = indexIn(styles, cfg_clockStyle)
    onCfg_blockColorChanged: colorBox.currentIndex = indexIn(blockColors, cfg_blockColor)
    onCfg_progressPeriodChanged: periodBox.currentIndex = indexIn(periods, cfg_progressPeriod)
    onCfg_firstDayOfWeekChanged: weekBox.currentIndex = indexOfWeekStart(cfg_firstDayOfWeek)
    onCfg_fontFamilyChanged: fontBox.currentIndex = indexOfFont(cfg_fontFamily)

    QQC2.ComboBox {
        id: styleBox

        Kirigami.FormData.label: "Style:"
        Layout.fillWidth: true

        textRole: "label"
        model: page.styles

        onActivated: page.cfg_clockStyle = page.styles[currentIndex].key
        Component.onCompleted: currentIndex = page.indexIn(page.styles, page.cfg_clockStyle)
    }

    QQC2.CheckBox {
        id: spineTopToBottom
        text: "Spine reads top to bottom"
        enabled: page.spineSelected
    }

    QQC2.ComboBox {
        id: colorBox

        Kirigami.FormData.label: "Pill colour:"
        Layout.fillWidth: true
        enabled: page.blocksSelected

        textRole: "label"
        model: page.blockColors

        onActivated: page.cfg_blockColor = page.blockColors[currentIndex].key
        Component.onCompleted: currentIndex = page.indexIn(page.blockColors, page.cfg_blockColor)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "What to show"
    }

    QQC2.CheckBox {
        id: use24Hour
        text: "24-hour clock"
    }

    QQC2.CheckBox {
        id: showSeconds
        text: "Show seconds"
    }

    QQC2.Label {
        text: "Makes the clock wake every second instead of every minute."
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    }

    QQC2.CheckBox {
        id: showDate
        text: "Show date"
    }

    QQC2.CheckBox {
        id: showWeekday
        text: "Show weekday"
    }

    QQC2.TextField {
        id: dateFormat

        Kirigami.FormData.label: "Date format:"
        enabled: showDate.checked
        placeholderText: "d MMM"
    }

    QQC2.Label {
        text: "d = day · MMM = short month · MMMM = full month · yy = year."
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    }

    RowLayout {
        Kirigami.FormData.label: "Date size:"
        Layout.fillWidth: true

        QQC2.Slider {
            id: dateScale
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 14
            from: 20
            to: 80
            stepSize: 5
            snapMode: QQC2.Slider.SnapAlways
            enabled: showDate.checked || showWeekday.checked
            value: page.cfg_dateScale
            onMoved: page.cfg_dateScale = value
        }

        QQC2.Label {
            text: page.cfg_dateScale + "%"
            opacity: 0.8
        }
    }

    QQC2.Label {
        text: "Height of each date line, relative to the clock digits. The date "
            + "is stacked one word per line, so a short format reads much larger."
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Ornaments"
    }

    QQC2.CheckBox {
        id: progressUnderline
        text: "Progress underline"
    }

    QQC2.ComboBox {
        id: periodBox

        Kirigami.FormData.label: "Underline tracks:"
        Layout.fillWidth: true
        enabled: progressUnderline.checked

        textRole: "label"
        model: page.periods

        onActivated: page.cfg_progressPeriod = page.periods[currentIndex].key
        Component.onCompleted: currentIndex = page.indexIn(page.periods, page.cfg_progressPeriod)
    }

    QQC2.CheckBox {
        id: topSeparator
        text: "Separator hairline above the clock"
    }

    QQC2.CheckBox {
        id: blinkSeparator
        text: "Blinking separator dot"
        enabled: page.stackedSelected
    }

    QQC2.Label {
        text: "Stacked styles only — it takes the accent rule's place between the "
            + "hour and the minute. The other styles have no gap where a dot would read "
            + "as a separator rather than as a stray mark."
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Calendar"
    }

    QQC2.Label {
        text: "Clicking the clock opens Plasma's month view, the same one the built-in "
            + "digital clock shows."
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
    }

    QQC2.CheckBox {
        id: showWeekNumbers
        text: "Show week numbers"
    }

    QQC2.ComboBox {
        id: weekBox

        Kirigami.FormData.label: "Week starts on:"
        Layout.fillWidth: true

        textRole: "label"
        model: page.weekStarts

        onActivated: page.cfg_firstDayOfWeek = page.weekStarts[currentIndex].day
        Component.onCompleted: currentIndex = page.indexOfWeekStart(page.cfg_firstDayOfWeek)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Typography"
    }

    QQC2.ComboBox {
        id: fontBox

        Kirigami.FormData.label: "Font:"
        Layout.fillWidth: true

        model: page.fontChoices

        onActivated: page.cfg_fontFamily = currentIndex === 0 ? "" : page.fontChoices[currentIndex]
        Component.onCompleted: currentIndex = page.indexOfFont(page.cfg_fontFamily)
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "About"
    }

    QQC2.Label {
        text: "Vertical Clock " + page.widgetVersion
        font: Kirigami.Theme.smallFont
        opacity: 0.7
    }
}
