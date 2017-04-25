import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import "components" as Components

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    applicationName: "com.ubuntu.developer.anton.maminov.detransport"

    useDeprecatedToolbar: false
    automaticOrientation: true

    width: units.gu(50)
    height: units.gu(90)

    property string pageTitle: i18n.tr("Detransport")

    property real margins: units.gu(2)
    property real buttonWidth: units.gu(20)

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
        text: i18n.tr("Refresh")
        enabled: !!(currentStop >= 0)
        onTriggered: {
            vehicleModel.refresh()
        }
    }

    Action {
        id: refreshStopsAction
        objectName: "StopsRefreshButton"
        iconName: "reload"
        text: i18n.tr("Refresh")
        onTriggered: {
            loadStops()
        }
    }

    Action {
        id: searchStopAction
        objectName: "SearchStopButton"
        iconName: "search"
        text: i18n.tr("Search Stop")
        onTriggered: {
            pageStack.push(addStopPage)
        }
    }

    Action {
        id: aboutAction
        objectName: 'AboutButton'
        iconName: 'info'
        text: i18n.tr('About')
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
            height: units.gu(14)

            Item {
                id: listItem

                anchors {
                    fill: parent
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }

                // used as footer for list
                ListItem.ThinDivider {
                    anchors.bottom: parent.bottom
                }

                Item {
                    id: vehicleShape
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: listItem.height / 3

                    Image {
                        anchors.centerIn: parent
                        source: selectIcon()
                        width: units.gu(8)
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
                        anchors.verticalCenterOffset: -units.gu(1)
                        text: name
                        fontSize: "normal"
                        font.weight: Font.DemiBold
                    }
                }

                Column {
                    id: content

                    anchors {
                        fill: parent; topMargin: units.gu(1.5); bottomMargin: units.gu(1.5);
                        leftMargin: listItem.height + units.gu(0.5); rightMargin: units.gu(1.5)
                    }
                    spacing: units.gu(1)

                    Label {
                        id: labelTime
                        objectName: "LabelTime"
                        text: i18n.tr("%1 minutes").arg(secondsToMinutes(time))
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        opacity: 0.6
                    }

                    Label {
                        id: labelDistance
                        objectName: "LabelDistance"
                        text: i18n.tr("%1 meters").arg(distance)
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        opacity: 0.6
                    }

                    Label {
                        id: labelNext
                        objectName: "LabelNext"
                        text: i18n.tr("Next in %1 minutes / %2 meters").arg(secondsToMinutes(timenext)).arg(distancenext)
                        fontSize: "x-small"
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

                for (var i in list.sort(sortByTime)) {
                    vehicleModel.append({
                                            "id": list[i].id,
                                            "name": list[i].name,
                                            "time": list[i].time,
                                            "distance": list[i].distance,
                                            "timenext": list[i].timenext,
                                            "distancenext": list[i].distancenext,
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

    PageStack {
        id: pageStack

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
