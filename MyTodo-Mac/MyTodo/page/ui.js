function header() {
    // 获取 s-tab 元素
    var tab = document.getElementById("headerTabs");

    let tabs = window.getTabs()

    for (let item of tabs) {
        var tabItem = document.createElement("s-tab-item");
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
        tabItem.setAttribute("checked", item.isChecked)
        tab.appendChild(tabItem);
    }

    return tabs.length
}

function setVisibility(id, visible) {
    let element = document.getElementById(id);
    if (visible) {
        element.style.display = "flex";
    } else {
        element.style.display = "none";
    }
}