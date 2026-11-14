import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

// A label that shrinks its font until it fits the box it is given.
//
// The large pixelSize is a starting point, not a final size: with fontSizeMode
// Fit, Qt only scales down, never up. That is how the text follows the panel
// thickness instead of being clipped — the same technique the upstream clock
// uses.
PlasmaComponents.Label {
    font.family: Plasmoid.configuration.fontFamily !== ""
        ? Plasmoid.configuration.fontFamily
        : Kirigami.Theme.defaultFont.family
    font.pixelSize: 1024
    minimumPixelSize: 1
    fontSizeMode: Text.Fit
    maximumLineCount: 1
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    textFormat: Text.PlainText
}
