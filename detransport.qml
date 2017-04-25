//import QtQuick 2.0
import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

//import Ubuntu.Components 1.1
//import Ubuntu.Components.ListItems 1.0 as ListItem
//import Ubuntu.Components.Popups 1.0
import "components" as Components

ApplicationWindow {
    visible: true
    width: 400
    height: 600

    toolBar:ToolBar {
            RowLayout {
                anchors.fill: parent
                ToolButton {
                    action: searchStopAction
                }
                ToolButton {
                    action: aboutAction
                }
                Item { Layout.fillWidth: true }
            }
        }

    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"


    property string pageTitle: "Detransport"

    property real margins: 2
    property real buttonWidth: 20

    property string source: "http://api.detransport.com.ua"
    property int currentStop: -1

    /* --- Models --- */

    ListModel {
        id: stopModel
    }

    ListModel {
        id: filterStopModel
    }

    ListModel {
        id: vehicleModel

        property bool refreshing: refreshTimer.running

        function refresh() {
            loadVehicles(currentStop)
            refreshTimer.restart(); // TODO
        }
    }

    /* --- Actions --- */

    Action {
        id: refreshVehiclesAction
        objectName: "VehiclesRefreshButton"
        iconName: "reload"
        text: "Refresh"
        enabled: !!(currentStop >= 0)
        onTriggered: {
            vehicleModel.refresh()
        }
    }

    Action {
        id: refreshStopsAction
        objectName: "StopsRefreshButton"
        iconName: "reload"
        text: "Refresh"
        onTriggered: {
            loadStops()
        }
    }

    Action {
        id: searchStopAction
        objectName: "SearchStopButton"
        iconName: "search"
        text: "Search Stop"
        onTriggered: {
            pageStack.push(addStopPage)
        }
    }

    Action {
        id: aboutAction
        objectName: 'AboutButton'
        iconName: 'info'
        text: 'About'
        onTriggered: {
            pageStack.push(aboutPage)
        }
    }

    Component {
        id: vehicleDelegate

        Item {
            id: vehicleItem

            anchors {
                left: parent.left
                right: parent.right
            }
            height: 140

            Item {
                id: listItem

                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                    topMargin: 10
                    bottomMargin: 10
                }

                Item {
                    id: vehicleShape
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: listItem.height / 3

                    Image {
                        anchors.centerIn: parent
                        source: selectIcon()
                        width: 80
                        height: width
                        sourceSize.width: width
                        sourceSize.height: width
                        smooth: true

                        function selectIcon() {
                            switch (vehicletype) {
                            case '1':
                                var img_path = "img/blue.svg"
                                break
                            case '2':
                                var img_path = "img/green.svg"
                                break
                            case '3':
                                var img_path = "img/red.svg"
                                break
                            default:
                                var img_path = "img/violet.svg"
                                break
                            }

                            return Qt.resolvedUrl(img_path);
                        }
                    }

                    Label {
                        id: labelName
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1
                        text: name
                        font.weight: Font.DemiBold
                    }
                }

                Column {
                    id: content

                    anchors {
                        fill: parent; topMargin: 15; bottomMargin: 15;
                        leftMargin: listItem.height + 5; rightMargin: 15
                    }
                    spacing: 1

                    Label {
                        id: labelTime
                        objectName: "LabelTime"
                        text: "%1 minutes".arg(secondsToMinutes(time))
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        opacity: 0.6
                    }

                    Label {
                        id: labelDistance
                        objectName: "LabelDistance"
                        text: "%1 meters".arg(distance)
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        opacity: 0.6
                    }

                    Label {
                        id: labelNext
                        objectName: "LabelNext"
                        text: "Next in %1 minutes / %2 meters".arg(secondsToMinutes(timenext)).arg(distancenext)
                        //wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        opacity: 0.6
                    }
                } // Column

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        vehicleItem.ListView.view.currentIndex = index
                        console.log("clicked()")
                    }
                }
            }
        } // Item

    } // Component

    Timer {
        id: refreshTimer
        interval: 400
    }

    Component.onCompleted: {
        loadStops()

        if (currentStop > 0) {
            pageStack.push(stopPage)
        } else {
            pageStack.push(addStopPage)
        }
    }

    function loadStops() {
        var url = source + '/stops/list';
        var xhr = new XMLHttpRequest;
        xhr.open("POST", url);

        console.log("loadStops()");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status == 200) {
                var list = JSON.parse(xhr.responseText)['stops'];
                stopModel.clear()
                filterStopModel.clear()

                for (var i in list) {
                    stopModel.append({
                                         "name": list[i].name,
                                         "id": list[i].id,
                                     })
                    filterStopModel.append({
                                               "name": list[i].name,
                                               "id": list[i].id,
                                           })
                }
            }
        }
        xhr.send();
    }

    function loadVehicles(stopId) {
        console.log('loadVehicles:' + stopId)

        var url = source + '/vehicles/info';
        var params = "stop=" + stopId;

        var xhr = new XMLHttpRequest;
        xhr.open("POST", url, true)

        // Send the proper header informaion along with the request
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        xhr.setRequestHeader('Content-Lenth', params.length)
        xhr.setRequestHeader('Connection', 'close')

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var list = JSON.parse(xhr.responseText)['vehicles'];
                vehicleModel.clear();

                console.log(list)
                for (var i in list.sort(sortByTime)) {
                    console.log(list[i].timenext)
                    vehicleModel.append({
                                            "id": list[i].id,
                                            "name": list[i].name,
                                            "time": list[i].time,
                                            "distance": list[i].distance,
                                            "timenext": list[i].timenext || 9999999999,
                                            "distancenext": list[i].distancenext || "Unknown",
                                            "vehicletype": list[i].type.toString()
                                        });
                }
            }
        }
        xhr.send(params);
    }

    function sortByTime(a,b) {
        if (a.time < b.time)
            return -1;
        if (a.time > b.time)
            return 1;
        return 0;
    }

    function secondsToMinutes(time) {
        var mins = Math.floor(time / 60)
        var secs = time - mins * 60

        var ret = ''

        ret += "" + mins + ":" + (secs < 10 ? "0" : "")
        ret += "" + secs
        return ret
    }

    StackView {
        id: pageStack
        anchors.fill: parent
        // Implements back key navigation
        focus: true

        Components.StopPage {
            id: stopPage
            visible: false
        }

        Components.AddStopPage {
            id: addStopPage
            visible: false
        }

        Components.AboutPage {
            id: aboutPage
            visible: false
        }
    }
}
