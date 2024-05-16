var tabCount = 0;
var headerTabs;
var lastSelectedTabIndex = 0;

function showHeaders() {
    // 获取 s-tab 元素
    var tab = document.getElementById("headerTabs");
    tab.setAttribute("onchange", "onTabSelected(this.selectIndex)")

    window.getTabs((tabs) => {
        headerTabs = tabs
        tabCount = tabs.length;
        tabs.forEach(function(item, index) {

            var tabItem = document.createElement("s-tab-item");
            tabItem.setAttribute("checked", index == 0)

            if (item.isAddTab) {
                var sIcon = document.createElement("s-icon");
                sIcon.setAttribute("slot", "icon")
                sIcon.setAttribute("type", "add")
                tabItem.appendChild(sIcon);
            } else {
                tabItem.setAttribute("id", getTabElementId(item));
                // 创建 div 元素，并设置 slot 属性和内容
                var divElement = document.createElement("div");
                divElement.setAttribute("slot", "text");
                divElement.textContent = item.title;
                
                tabItem.appendChild(divElement);
            }
            // tabItem.setAttribute("checked", item.isChecked)
            tab.appendChild(tabItem);
        })
        
        onTabSelected(0)
    })
}

function getTabElementId(tab) {
    return "tab_" + tab.id;
}

function onTabSelected(index) {
    var lastTab = headerTabs[lastSelectedTabIndex];
    if (!lastTab.isAddTab) {
        var lastTabElementId = getTabElementId(lastTab);
        document.getElementById(lastTabElementId).removeEventListener("contextmenu", onTabRightClick);
    }
    

    let selectedTab = headerTabs[index];
    if (!selectedTab.isAddTab) {
        var tabElementId = getTabElementId(selectedTab);
        var tabItem = document.getElementById(tabElementId);
        tabItem.addEventListener('contextmenu', onTabRightClick);
    }

    if (selectedTab.isAddTab) {
        setVisibility("dataTableContainer", false);
        setVisibility("newTabPage", true);
    } else {
        setVisibility("dataTableContainer", true);
        setVisibility("newTabPage", false);
    }

    lastSelectedTabIndex = index;
}

function onTabRightClick(event) {
    console.log("onTabRightClick");
    var currentId = getTabElementId(headerTabs[lastSelectedTabIndex]);
    var currentTab = document.getElementById(currentId)
    document.querySelector('#menu').show(currentTab);
}

function setVisibility(id, visible) {
    let element = document.getElementById(id);
    if (visible) {
        element.style.display = "flex";
    } else {
        element.style.display = "none";
    }
}