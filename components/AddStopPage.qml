import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

Page {
    id: addStopPage
    objectName: "AddStopPage"
    title: i18n.tr("Select stop")
    anchors.fill: parent
    visible: false
    tools: addStopPageToolbar

    ToolbarItems {
        id: addStopPageToolbar

        ToolbarButton {
            action: refreshStopsAction
        }

        ToolbarButton {
            action: aboutAction
        }
    }

    readonly property real headerHeight: units.gu(9.5)
    readonly property real bottomHeight: units.gu(9.5)

    function clear() {
        locationString.text = ''
        vehicleModel.clear()
        //searching.running = false
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
            //searching.running = true
            //searching.running = false
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
                topMargin: headerHeight + units.gu(1)
                margins: units.gu(2)
                right: parent.right
                left: parent.left
                bottom: parent.bottom
                bottomMargin: bottomHeight
            }

            Rectangle {
                id: searchInput
                height: units.gu(5)
                anchors {
                    right: parent.right
                    rightMargin: units.gu(1)
                    left: parent.left
                    leftMargin: units.gu(1)
                }
                color: 'transparent'

                TextField {
                    id: locationString
                    objectName: 'SearchField'
                    anchors.fill: parent

                    placeholderText: i18n.tr('Search...')
                    hasClearButton: true
                    inputMethodHints: Qt.ImhNoPredictiveText

                    onAccepted: {
                        doSearch();
                        search_timer.stop()
                        locationString.focus = false
                    }

                    primaryItem: Image {
                        id: locationImage
                        height: parent.height * 0.5
                        width: height
                        anchors {
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -units.gu(0.1)
                        }
                        source: Qt.resolvedUrl("image://theme/search")
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

                ActivityIndicator {
                    id: searching
                    objectName: "SearchingSpinner"
                    anchors {
                        right: locationString.right
                        rightMargin: units.gu(2)
                        verticalCenter: locationString.verticalCenter
                    }
                }
            }

            Rectangle {
                id: stopList
                anchors {
                    top: searchInput.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: units.gu(2)
                }
                height: addStopPage.height - searchInput.height - units.gu(9.5)
                color: 'transparent'
                visible: true
                ListView {
                    id: listView
                    objectName: "SearchResultList"
                    clip: true
                    anchors.fill: parent
                    model: filterStopModel

                    delegate: ListItem.Subtitled {
                        text: name
                        //iconName: "empty"
                        progression: true

                        onClicked: {
                            currentStop = id
                            pageTitle = name
                            loadVehicles(id)

                            pageStack.clear()
                            pageStack.push(stopPage)

                            clear()
                        }
                    }

                    Scrollbar {
                        flickableItem: listView
                        align: Qt.AlignTrailing
                    }
                }
            }
        }
    }
}
