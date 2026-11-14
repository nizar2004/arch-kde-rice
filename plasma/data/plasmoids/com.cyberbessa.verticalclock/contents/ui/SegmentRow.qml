import QtQuick
import org.kde.kirigami as Kirigami

// One row of seven-segment digits, drawn as vector shapes on a canvas.
//
// Each segment is a chamfered hexagon rather than a plain rectangle — that
// bevel where segments meet is what makes the shape read as a real LED display
// instead of a blocky imitation.
//
// `ghost` also paints the unlit segments at low opacity, the way a physical
// elevator indicator shows its whole grid behind the lit digits.
//
// Without that grid a "1" reads as misaligned: it lights only the two
// right-hand segments, so it hangs off the right edge of its cell with nothing
// to show the cell is wider than the digit. In clean mode it is shifted to the
// middle of its cell instead. Only "1" gets this — centring digits in general
// would make them slide sideways as the time changes.
Canvas {
    id: row

    property string digits: "00"
    property real digitWidth: 10
    property real digitHeight: 18
    property real gap: 3
    property bool ghost: false
    property color ink: Kirigami.Theme.textColor

    // Which of the seven segments each digit lights, in the order a b c d e f g:
    //
    //      aaa
    //     f   b
    //      ggg
    //     e   c
    //      ddd
    readonly property var segmentTable: ({
        "0": [1, 1, 1, 1, 1, 1, 0],
        "1": [0, 1, 1, 0, 0, 0, 0],
        "2": [1, 1, 0, 1, 1, 0, 1],
        "3": [1, 1, 1, 1, 0, 0, 1],
        "4": [0, 1, 1, 0, 0, 1, 1],
        "5": [1, 0, 1, 1, 0, 1, 1],
        "6": [1, 0, 1, 1, 1, 1, 1],
        "7": [1, 1, 1, 0, 0, 0, 0],
        "8": [1, 1, 1, 1, 1, 1, 1],
        "9": [1, 1, 1, 1, 0, 1, 1]
    })

    implicitWidth: Math.max(1, digits.length * digitWidth
                               + Math.max(0, digits.length - 1) * gap)
    implicitHeight: Math.max(1, digitHeight)

    onDigitsChanged: requestPaint()
    onDigitWidthChanged: requestPaint()
    onDigitHeightChanged: requestPaint()
    onGapChanged: requestPaint()
    onGhostChanged: requestPaint()
    onInkChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // Horizontal segment: spans x..x+len, centred on y, `t` thick.
    function bar(ctx, x, y, len, t) {
        var h = t / 2;
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x + h, y - h);
        ctx.lineTo(x + len - h, y - h);
        ctx.lineTo(x + len, y);
        ctx.lineTo(x + len - h, y + h);
        ctx.lineTo(x + h, y + h);
        ctx.closePath();
        ctx.fill();
    }

    // Vertical segment: spans y..y+len, centred on x, `t` thick.
    function post(ctx, x, y, len, t) {
        var h = t / 2;
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x + h, y + h);
        ctx.lineTo(x + h, y + len - h);
        ctx.lineTo(x, y + len);
        ctx.lineTo(x - h, y + len - h);
        ctx.lineTo(x - h, y + h);
        ctx.closePath();
        ctx.fill();
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.clearRect(0, 0, width, height);

        var dw = digitWidth;
        var dh = digitHeight;
        var t = dw * 0.20;        // segment thickness
        var h = t / 2;
        var sep = t * 0.30;       // gap where two segments meet

        var barLen = dw - t - 2 * sep;
        var postLen = dh / 2 - 1.5 * t - 2 * sep;
        if (barLen <= 0 || postLen <= 0) {
            return;
        }

        ctx.fillStyle = ink;

        for (var i = 0; i < digits.length; i++) {
            var lit = segmentTable[digits.charAt(i)];
            if (!lit) {
                continue;
            }
            var lone = !ghost && digits.charAt(i) === "1";
            var ox = i * (dw + gap) + (lone ? -(dw - t) / 2 : 0);

            for (var s = 0; s < 7; s++) {
                var alpha = lit[s] ? 1.0 : (ghost ? 0.10 : 0.0);
                if (alpha === 0) {
                    continue;
                }
                ctx.globalAlpha = alpha;

                if (s === 0) {
                    row.bar(ctx, ox + h + sep, h, barLen, t);
                } else if (s === 1) {
                    row.post(ctx, ox + dw - h, t + sep, postLen, t);
                } else if (s === 2) {
                    row.post(ctx, ox + dw - h, dh / 2 + h + sep, postLen, t);
                } else if (s === 3) {
                    row.bar(ctx, ox + h + sep, dh - h, barLen, t);
                } else if (s === 4) {
                    row.post(ctx, ox + h, dh / 2 + h + sep, postLen, t);
                } else if (s === 5) {
                    row.post(ctx, ox + h, t + sep, postLen, t);
                } else {
                    row.bar(ctx, ox + h + sep, dh / 2, barLen, t);
                }
            }
        }
    }
}
