window.getTabs = function() {
    let tabs = getTabsNative()

    console.log("getTabs.length=", tabs.length)
    if (tabs.length == 0) {
        let defaultTab = {}
        defaultTab.title = "Unnamed"
        defaultTab.isChecked = true
        tabs.push(defaultTab)
    }

    let addTab = {}
    addTab.isAddTab = true
    tabs.push(addTab)

    return tabs
}

function getTabsNative() {
    return []
}