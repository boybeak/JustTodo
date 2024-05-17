var tabCount = 0;
var headerTabs = [];
var lastSelectedTabIndex = 0;
var lastTabId = "";
const ADD_TAB_ID = "tab_add";

function showHeaders() {
    // 获取 s-tab 元素
    var tab = document.getElementById("headerTabs");
    // 必须加setTimeout，比如在创建新tab时，出现获取this.selectIndex为-1的情况
    tab.setAttribute("onchange", "setTimeout(()=>{ onTabSelected(this.selectIndex) }, 0)")

    window.getTabs((tabs) => {
        headerTabs = tabs
        tabCount = tabs.length;
        tabs.forEach(function(item, index) {

            var tabItem = document.createElement("s-tab-item");
            tabItem.setAttribute("checked", index == 0);
            tabItem.setAttribute("id", getTabElementId(item));

            if (item.isAddTab) {
                var sIcon = document.createElement("s-icon");
                sIcon.setAttribute("slot", "icon")
                sIcon.setAttribute("type", "add")
                tabItem.appendChild(sIcon);
            } else {
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

function newNormalTabEle(tabItem, checked) {
    var tabItemEle = document.createElement("s-tab-item");
    tabItemEle.setAttribute("checked", checked);
    tabItemEle.setAttribute("id", getTabElementId(tabItem));

    var divElement = document.createElement("div");
    divElement.setAttribute("slot", "text");
    divElement.textContent = tabItem.title;

    tabItemEle.appendChild(divElement);

    return tabItemEle;
}

function getTabElementId(tab) {
    if (tab.isAddTab) {
        return ADD_TAB_ID;
    }
    return "tab_" + tab.id;
}

function onTabSelected(index) {
    if (lastTabId.length > 0) {
        var lastTabEle = document.getElementById(lastTabId);
        if (lastTabEle) {
            // 检查合法性在执行，不然在删除时，会有错误出现
            lastTabEle.removeEventListener("contextmenu", onTabRightClick);
        }
    } 

    let selectedTab = headerTabs[index];
    if (!selectedTab.isAddTab) {
        var tabElementId = getTabElementId(selectedTab);
        var tabItem = document.getElementById(tabElementId);
        tabItem.addEventListener('contextmenu', onTabRightClick);

        lastTabId = tabElementId;
        lastSelectedTabIndex = index;
    }

    if (selectedTab.isAddTab) {
        setVisibility("dataTableContainer", false);
        setVisibility("newTabPage", true);
    } else {
        setVisibility("dataTableContainer", true);
        setVisibility("newTabPage", false);
    }
}

function onTabRightClick(event) {
    var currentId = getTabElementId(headerTabs[lastSelectedTabIndex]);
    var currentTab = document.getElementById(currentId)
    document.querySelector('#menu').show(currentTab);
    event.preventDefault();
}

function setVisibility(id, visible) {
    let element = document.getElementById(id);
    if (visible) {
        element.style.display = "flex";
    } else {
        element.style.display = "none";
    }
}

function newTab(title) {
    if(title.trim() === "") {
        return
    }
    newTabNative(title, (result) => {
        var newTabItem = JSON.parse(result)
        headerTabs.splice(headerTabs.length - 1, 0, newTabItem)

        var tabEle = document.getElementById("headerTabs")
        var addTabEle = document.getElementById(ADD_TAB_ID)
        addTabEle.checked = false

        var newTabEle = newNormalTabEle(newTabItem, true)
        tabEle.insertBefore(newTabEle, addTabEle);

        setTimeout(() => {
            tabEle.options[headerTabs.length - 2].checked = true
        }, 0)
    })
}

function showDelTabDialog() {
    showDialog('Sure to delete?', ()=> {
        deleteTab()
    })
}

function showDialog(text, onClick) {
    var dialog = document.getElementById('dialog') 
    document.getElementById('dialog-text').textContent = text
    document.getElementById('dialog-positive-btn').onclick = onClick
    dialog.show()
}

function deleteTab() {
    var tabItem = headerTabs[lastSelectedTabIndex]
    var tabItemEle = document.getElementById(getTabElementId(tabItem))

    var tab = document.getElementById('headerTabs')
    tab.options.splice(lastSelectedTabIndex, 1)
    tab.removeChild(tabItemEle)
    headerTabs.splice(lastSelectedTabIndex, 1)
    deleteTabNative(tabItem.id)

    var pendingIndex = Math.max(lastSelectedTabIndex - 1, 0);

    setTimeout(()=>{
        tab.options[pendingIndex].checked = true
    }, 50)

}