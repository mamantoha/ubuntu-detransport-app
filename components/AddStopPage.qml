import QtQuick 2.7
import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Page {
    id: addStopPage
    objectName: "AddStopPage"
    title: "Select stop"
    anchors.fill: parent
    visible: true

    readonly property real headerHeight: 9.5
    readonly property real bottomHeight: 9.5

    function clear() {
        locationString.text = ''
        vehicleModel.clear()
        searching.running = false
    }

    function doSearch() {
        filterStopModel.clear()

        if (locationString.text != "") {
            console.log("doSearch: ", locationString.text)
            stopList.visible = true
            for (var i = 0; i < stopModel.count; i++) {
                var expr = new RegExp('.*?' + locationString.text + '.*?', 'ig')
                if (stopModel.get(i).name.match(expr)) {
                    filterStopModel.append(stopModel.get(i))
                }
            }
            searching.running = true
            searching.running = false
        } else {
            for (var i = 0; i < stopModel.count; i++) {
                filterStopModel.append(stopModel.get(i))
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Item {
            anchors {
                top: parent.top
                topMargin: headerHeight + 1
                margins: 2
                right: parent.right
                left: parent.left
                bottom: parent.bottom
                bottomMargin: bottomHeight
            }

            Rectangle {
                id: searchInput
                height: 30
                anchors {
                    right: parent.right
                    rightMargin: 1
                    left: parent.left
                    leftMargin: 1
                }
                color: 'transparent'


                TextField {
                    id: locationString
                    objectName: 'SearchField'
                    anchors.fill: parent

                    placeholderText: 'Search...'
                    inputMethodHints: Qt.ImhNoPredictiveText

                    onAccepted: {
                        console.log('search')
                        doSearch();
                        search_timer.stop()
                        locationString.focus = false
                    }

                    style: TextFieldStyle {
                        textColor: "black"
                        background: Rectangle {
                            radius: 20
                            border.width: 1
                        }
                    }

                    Timer {
                        id: search_timer
                        interval: 1000
                        repeat: false
                        onTriggered: {
                            if (locationString.Text != "") {
                                doSearch();
                            }
                        }
                    }

                    onTextChanged: {
                        search_timer.restart()
                    }
                } //TextField

                BusyIndicator {
                    id: searching
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    objectName: "SearchingSpinner"
                    running: false
                }
            }

            Rectangle {
                id: stopList
                anchors {
                    top: searchInput.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 20
                }
                height: addStopPage.height - searchInput.height - 9.5
                color: 'transparent'
                visible: true

                ListView {
                    id: listView
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 18
                    anchors.leftMargin: 0
                    anchors.topMargin: -18
                    objectName: "SearchResultList"
                    clip: true
                    anchors.fill: parent
                    model: filterStopModel

                    delegate:Component {
                        Item {
                            id: container
                            width: ListView.view.width; height: 60; anchors.leftMargin: 10; anchors.rightMargin: 10

                            Rectangle {
                                id: content
                                anchors.centerIn: parent; width: container.width - 40; height: container.height - 10
                                color: "transparent"
                                antialiasing: true
                                radius: 10

                                Rectangle { anchors.fill: parent; anchors.margins: 3; color: "#91AA9D"; antialiasing: true; radius: 8 }
                            }

                            Text {
                                id: label
                                anchors.centerIn: content
                                text: name
                                color: "#193441"
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    currentStop = id
                                    pageTitle = name
                                    loadVehicles(id)

                                    pageStack.clear()
                                    pageStack.push(stopPage)

                                    clear()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
