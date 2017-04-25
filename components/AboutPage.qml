import QtQuick 2.0
import Ubuntu.Components 1.1

Page {
    id: aboutPage
    title: i18n.tr("About")
    visible:false

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true

        contentHeight: aboutColumn.height + 2 * aboutColumn.marginTop //doubled marginTop to get the same margin at the bottom

        Column {
            id: aboutColumn
            spacing: units.gu(2)
            width: parent.width
            property real marginTop: units.gu(3)
            y: marginTop

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("<b>Detransport Ternopil</b>")
                fontSize: "x-large"
            }

            UbuntuShape {
                property real maxWidth: units.gu(45)
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, maxWidth)/2
                height: Math.min(parent.width, maxWidth)/2
                image: Image {
                    source: "../detransport.png"
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("<b>About:</b>")
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Ubuntu Touch mobile version of the <br/><a href=\"http://detransport.com.ua\">http://detransport.com.ua</a> site"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("<b>Author:</b>")
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Anton Maminov<br><a href=\"mailto:anton.maminov@gmail.com\">anton.maminov@gmail.com</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("<b>Source code:</b>")
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<a href=\"https://launchpad.net/ubuntu-detransport-app\">ubuntu-detransport-app</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Version: <b>0.5</b>")
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                text: "2014"
            }
        }
    }
}
