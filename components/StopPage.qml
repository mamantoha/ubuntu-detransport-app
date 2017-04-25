import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

Page {
    id: stopPage
    title: pageTitle
    tools: stopPageToolbar

    ToolbarItems {
        id: stopPageToolbar

            ToolbarButton {
              action: refreshVehiclesAction
            }

        ToolbarButton {
            action: searchStopAction
        }

        ToolbarButton {
            action: aboutAction
        }
    }

    ActivityIndicator {
        id: activity
        objectName: "ActivityIndicator"
        anchors.right: parent.right
        //running: stopsFetcher.status === ListModel.Loading
    }

    Column {
        id: pageLayout

        anchors {
            fill: parent
            margins: root.margins
        }
        spacing: units.gu(1)

        Row {
            id: stopSelectRow
            spacing: units.gu(1)
        }

        // Define a highlight with customized movement between items.
        Component {
            id: highlightBar
            Rectangle {
                width: vehiclesListView.currentItem.width
                height: vehiclesListView.currentItem.height - units.gu(2)
                color: "lightsteelblue"
                smooth: true
                radius: 5
                y: vehiclesListView.currentItem.y;
                //Behavior on y { SpringAnimation { spring: 2; damping: 0.1 } }
            }
        }

        UbuntuListView {
            id: vehiclesListView
            objectName: "vehiclesListView"
            width: parent.width
            height: pageLayout.height - stopSelectRow.height
            model: vehicleModel
            clip: true
            focus: false

            // Set the highlight delegate. Note we must also set highlightFollowsCurrentItem
            // to false so the highlight delegate can control how the highlight is moved.
            // highlight: highlightBar
            // highlightFollowsCurrentItem: false

            delegate: vehicleDelegate

            pullToRefresh {
                enabled: !!(currentStop >= 0)
                onRefresh: model.refresh()
                refreshing: model.refreshing
            }
        }
    }
}
