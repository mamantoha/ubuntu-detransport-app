import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Particles 2.0

Page {
    id: aboutPage
    transformOrigin: Item.Center
    title: "About"
    visible:true
    anchors.fill: parent

    Flickable {
        id: flickable
        anchors.rightMargin: 0
        anchors.fill: parent
        clip: true

        contentHeight: aboutColumn.height + 2 * aboutColumn.marginTop //doubled marginTop to get the same margin at the bottom

        Column {
            id: aboutColumn
            spacing: 2
            width: parent.width
            property real marginTop: 3
            y: marginTop

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 22
                text: "<b>Detransport Ternopil</b>"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../detransport.png"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<b>About:</b>"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "QML version of the <br/><a href=\"http://detransport.com.ua\">http://detransport.com.ua</a> site"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<b>Author:</b>"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Anton Maminov<br><a href=\"mailto:anton.maminov@gmail.com\">anton.maminov@gmail.com</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<b>Source code:</b>"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<a href=\"https://github.com/mamantoha/ubuntu-detransport-app\">Gihub</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Version: <b>0.6</b>"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                text: "2014-2017"
            }
        }
    }
}
