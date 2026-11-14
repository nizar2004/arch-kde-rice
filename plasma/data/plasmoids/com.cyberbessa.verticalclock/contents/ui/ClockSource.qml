import QtQuick
import org.kde.plasma.plasmoid

// The widget's time source.
//
// A single Timer that reschedules itself on every tick with the exact interval
// left until the next rollover — instead of a repeating 1000 ms Timer, which
// drifts and wakes the CPU off the beat. The happy side effect is that it
// resynchronises after suspend on its own: the first tick after waking already
// lands on the correct rollover.
Item {
    id: clock

    visible: false
    width: 0
    height: 0

    // Current instant. Only changes on a tick — everything else derives from it.
    property date now: new Date()

    // 1 s while seconds are shown, 1 min otherwise.
    readonly property int period: Plasmoid.configuration.showSeconds ? 1000 : 60000

    readonly property bool is12h: !Plasmoid.configuration.use24Hour

    readonly property string hh: {
        var h = now.getHours();
        if (is12h) {
            h = h % 12;
            if (h === 0) {
                h = 12;
            }
            return h < 10 ? "0" + h : String(h);
        }
        return h < 10 ? "0" + h : String(h);
    }

    readonly property string mm: {
        var m = now.getMinutes();
        return m < 10 ? "0" + m : String(m);
    }

    readonly property string ss: {
        var s = now.getSeconds();
        return s < 10 ? "0" + s : String(s);
    }

    readonly property string ampm: is12h ? (now.getHours() < 12 ? "AM" : "PM") : ""

    // One-line time — used by the spine styles and the horizontal fallback.
    readonly property string timeText: {
        var t = hh + ":" + mm;
        if (Plasmoid.configuration.showSeconds) {
            t += ":" + ss;
        }
        if (ampm !== "") {
            t += " " + ampm;
        }
        return t;
    }

    // The date as one string. The stacked styles use dateTokens instead.
    readonly property string dateText: {
        var bits = "";
        if (Plasmoid.configuration.showWeekday) {
            bits = Qt.formatDate(now, "ddd");
        }
        if (Plasmoid.configuration.showDate) {
            var body = Qt.formatDate(now, Plasmoid.configuration.dateFormat);
            bits = bits === "" ? body : bits + " " + body;
        }
        return bits;
    }

    // The same date split into words, one per line.
    //
    // This is what makes the date readable on a narrow panel: "19 Aug" set on
    // one line has to squeeze six glyphs into the panel width, so each one ends
    // up tiny. Stacked as "19" over "Aug", each line is two or three glyphs and
    // can be several times larger in the same space.
    readonly property var dateTokens: {
        var words = dateText.split(" ");
        var out = new Array(words.length);
        var kept = 0;
        for (var i = 0; i < words.length; i++) {
            if (words[i].length > 0) {
                out[kept] = words[i];
                kept++;
            }
        }
        out.length = kept;
        return out;
    }

    readonly property bool hasDate: dateText.length > 0

    // Fractions elapsed — the progress underline reads one of these.
    readonly property real dayFraction:
        (now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()) / 86400
    readonly property real hourFraction:
        (now.getMinutes() * 60 + now.getSeconds()) / 3600

    // For the panel tooltip.
    readonly property string longTime: Qt.formatTime(now, is12h ? "h:mm:ss AP" : "HH:mm:ss")
    readonly property string longDate: Qt.formatDate(now, Qt.locale(), Locale.LongFormat)

    function tick() {
        now = new Date();
        // Time left until the next full rollover. The 50 ms floor prevents a
        // burst of ticks if the clock happens to wake right on the boundary.
        ticker.interval = Math.max(50, period - (now.getTime() % period));
        ticker.restart();
    }

    Timer {
        id: ticker
        repeat: false
        onTriggered: clock.tick()
    }

    onPeriodChanged: tick()
    Component.onCompleted: tick()
}
