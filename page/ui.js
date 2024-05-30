var tabCount = 0
var headerTabs = []
var lastSelectedTabIndex = 0
var lastTabId = ""
var lastTabEleId = ""
const ADD_TAB_ID = "tab_add"

let tip = new Tip()
var selectedIconEle
var currentIconSvg = ''
var svgEmpty = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -960 960 960">
    <path
        d="M120-120v-200h80v120h120v80H120Zm520 0v-80h120v-120h80v200H640ZM120-640v-200h200v80H200v120h-80Zm640 0v-120H640v-80h200v200h-80Z">
    </path>
</svg>
`
var customIconsCache = []
let iconAddBtn = {
    iconId: 'addIconBtn',
    isAdd: true
}

onPageReady()

function onPageReady() {
    var app = document.getElementById('app')
    app.setAttribute('theme', 'auto')
    // 获取输入框元素
    var newTabInput = document.getElementById("newTabInput")

    function checkTabName(text) {
        
        if (text.length > 24) {
            return lang.text_error_tab_name_too_long
        }
        
        if (text.includes('\n') || text.includes('\r')) {
            return lang.text_error_tab_name_invalid_chars
        }
        
        return ''
    }

    function isTabNameValid(text) {
        return checkTabName(text).length == 0
    }

    function createTab() {
        var textContent = newTabInput.value
        if (textContent.length <= 0) {
            return
        }
        if (!isTabNameValid(textContent)) {
            return
        }
        newTab(textContent, currentIconSvg)
        newTabInput.value = ''
        clearSelectedIcon()
    }

    newTabInput.setAttribute('placeholder', lang.text_new_tab_placeholder)

    // 绑定 keydown 事件监听器
    newTabInput.addEventListener("keydown", (event) => {
        // 如果按下的是回车键
        if (event.keyCode === 13) {
            createTab()
        }
    })

    newTabInput.addEventListener("input", (event) => {
        var textContent = newTabInput.value
        var error = checkTabName(textContent)
        if (error.length > 0) {
            tip.showError(newTabInput, error)
            return
        }
        tip.hide()
    })

    var newTabCommitBtn = document.getElementById("newTabCommitBtn")
    newTabCommitBtn.addEventListener("click", (event) => {
        createTab()
    })

    var newTodoInput = document.getElementById("newTodoInput")

    function createTodo() {
        var textContent = newTodoInput.value
        if (textContent.length <= 0) {
            return
        }
        newTodoItem(textContent)

        newTodoInput.value = ''

        refreshTodoItems()
    }

    newTodoInput.setAttribute('placeholder', lang.text_new_todo_placeholder)
    // 绑定 keydown 事件监听器
    newTodoInput.addEventListener("keydown", (event) => {
        // 如果按下的是回车键
        if (event.keyCode === 13) {
            createTodo()
        }
    })

    var newTodoCommitBtn = document.getElementById("newTodoCommitBtn")
    newTodoCommitBtn.addEventListener("click", (event) => {
        createTodo()
    })
    showHeaders()
    showIcons()
}

function showHeaders() {
    // 获取 s-tab 元素
    var tab = document.getElementById("headerTabs")
    tab.setAttribute("onchange", "onTabSelected()")

    bridge.getTabs((tabs) => {
        headerTabs = tabs
        tabCount = tabs.length
        tabs.forEach(function (item, index) {
            if (item.isAddTab) {
                var tabItem = document.createElement("s-tab-item")
                tabItem.setAttribute("id", getTabElementId(item))
                var sIcon = document.createElement("s-icon")
                sIcon.setAttribute("slot", "icon")
                sIcon.setAttribute("type", "add")

                tabItem.setAttribute("selected", index == 0)

                tabItem.appendChild(sIcon)
                tab.appendChild(tabItem)
            } else {
                // 创建 div 元素，并设置 slot 属性和内容
                var tabItem = newNormalTabEle(item, index == 0)

                tab.appendChild(tabItem)
            }
        })
        onTabSelectedAsync()
    })
}

function showIcons() {
    var newTabIcon = document.getElementById('newTabIcon')
    function refreshCustomIcons(customIcons) {
        var icons = []
        icons.push(...customIcons)
        icons.push(iconAddBtn)
        var iconCustomTableBody = document.getElementById('iconsCustomTableBody')
        fillIcons(iconCustomTableBody, icons)
    }
    function addCustomIcons() {
        bridge.addCustomIcons((icons) => {
            customIconsCache.push(...icons)
            refreshCustomIcons(customIconsCache)
        })
    }
    function fillIcons(tableBody, icons) {
        var lastRow;
        tableBody.innerHTML = ''
        icons.forEach((icon, index) => {
            if (index % 8 == 0) {
                var row = document.createElement('tr')
                tableBody.appendChild(row)
                lastRow = row
            }
            
            var td = createIconTD(icon)
            
            lastRow.appendChild(td)

            td.onclick = (event) => {
                if (icon.isAdd) {
                    addCustomIcons()
                } else {
                    if (selectedIconEle) {
                        selectedIconEle.setAttribute('selected', false)
                    }
                    newTabIcon.innerHTML = icon.svg
                    newTabIcon.style.color = 'var(--s-color-secondary)'
                    selectedIconEle = td
                    currentIconSvg = icon.svg
                    
                    selectedIconEle.setAttribute('selected', true)
                }
            }
            if (icon.isCustom) {
                td.addEventListener('contextmenu', (event) => {
                    showCommonMenu(event, [
                        {
                            title: lang.text_delete,
                            onClick: (event) => {
                                bridge.deleteCustomIcon(icon)
                                customIconsCache = customIconsCache.filter( item => item.iconId != icon.iconId)
                                refreshCustomIcons(customIconsCache)
                            }
                        }
                    ])
                    event.preventDefault()
                })
            }
        })
    }

    bridge.getBuildInIcons((icons) => {
        var iconBuildInTableBody = document.getElementById('iconsBuildInTableBody')
        fillIcons(iconBuildInTableBody, icons)
    })
    bridge.getCustomIcons((icons) => {
        customIconsCache = []
        customIconsCache.push(...icons)
        refreshCustomIcons(customIconsCache)
    })
    document.getElementById('newTabIconBtn').onclick = (event) => {
        clearSelectedIcon()
    }
}

function createIconTD(icon) {
    var td = document.createElement('td')

    var div = document.createElement('div')
    div.style.width = '100%'
    div.style.height = '100%'
    div.style.alignItems = 'center'
    div.style.justifyContent = 'center'
    div.style.display = 'flex'

    var sIcon = document.createElement('s-icon')
    if (icon.isAdd) {
        sIcon.setAttribute('type', 'add')
        sIcon.style.color = 'darkgray'
    } else {
        sIcon.innerHTML = icon.svg
    }

    div.appendChild(sIcon)
    td.appendChild(div)

    return td
}

function clearSelectedIcon() {
    if (selectedIconEle) {
        selectedIconEle.setAttribute('selected', false)
        selectedIconEle = undefined
        currentIconSvg = ''
    }
    newTabIcon.innerHTML = svgEmpty
    newTabIcon.style.color = 'darkgray'
}

function newNormalTabEle(tabItem, checked) {
    var tabItemEle = document.createElement("s-tab-item")
    tabItemEle.setAttribute("selected", checked)
    tabItemEle.setAttribute("id", getTabElementId(tabItem))

    var divEle = document.createElement("div")
    divEle.setAttribute("slot", "text")

    if (tabItem.icon.length == 0) {
        divEle.textContent = tabItem.title
    } else {
        divEle.style.display = 'flex'
        divEle.style.alignItems = 'center'
        divEle.style.justifyContent = 'center'
        var iconEle = document.createElement('s-icon')
        iconEle.className = 'tab-icon'
        iconEle.style.width = '24px'
        iconEle.style.height = '24px'
        iconEle.style.marginRight = '4px'
        iconEle.innerHTML = atob(tabItem.icon) // svg code

        var text = document.createTextNode(tabItem.title)

        divEle.appendChild(iconEle)
        divEle.appendChild(text)
    }

    tabItemEle.appendChild(divEle)

    return tabItemEle
}

function getTabElementId(tab) {
    if (tab.isAddTab) {
        return ADD_TAB_ID
    }
    return "tab_" + tab.id
}

// 通过tab.options[n].selected = true的形式触发，需要主动调用这个
function onTabSelectedAsync() {
    setTimeout(() => {
        onTabSelected()
    }, 0)
}

function onTabSelected() {
    const index = document.getElementById('headerTabs').selectedIndex

    if (index < 0) {
        return
    }
    if (lastTabEleId.length > 0) {
        var lastTabEle = document.getElementById(lastTabEleId)
        var iconEle = document.querySelector('#' + lastTabEleId + ' .tab-icon')
        if (lastTabEle) {
            // 检查合法性在执行，不然在删除时，会有错误出现
            lastTabEle.removeEventListener("contextmenu", onTabRightClick)
        }
        if (iconEle) {
            iconEle.setAttribute('selected', false)
        }
    }

    let selectedTab = headerTabs[index]
    if (!selectedTab.isAddTab) {
        var tabElementId = getTabElementId(selectedTab)
        var tabItem = document.getElementById(tabElementId)
        tabItem.addEventListener('contextmenu', onTabRightClick.bind(null, selectedTab))

        var iconEle = document.querySelector('#' + tabElementId + ' .tab-icon')
        if (iconEle) {
            iconEle.setAttribute('selected', true)
        }

        lastTabId = selectedTab.id
        lastTabEleId = tabElementId
        lastSelectedTabIndex = index
    }

    if (selectedTab.isAddTab) {
        setVisibility("dataTableContainer", false)
        setVisibility("newTabPage", true)
        document.getElementById('newTabInput').focus()
    } else {
        setVisibility("dataTableContainer", true)
        setVisibility("newTabPage", false)
        document.getElementById('newTodoInput').focus()

        refreshTodoItems()
    }
}

function refreshTodoItems() {
    bridge.getTodoItemsNative(lastTabId, (result) => {
        var todoItems = JSON.parse(result)
        fillTodoItems(todoItems)
    })
}

function fillTodoItems(todoItems) {
    var todoList = document.getElementById('todoList')
    var emptyView = document.getElementById('emptyView')
    todoList.innerHTML = ''
    if (todoItems.length == 0) {
        emptyView.style.display = 'flex'
        setVisibility('todoList', false)
        return
    }
    emptyView.style.display = 'none'
    setVisibility('todoList', true)

    todoItems.forEach(function (item, index) {
        todoList.appendChild(createTodoItemEle(item, index == todoItems.length - 1))
    })
}

function onTabRightClick(tabItem, event) {
    var currentId = getTabElementId(tabItem)
    var currentTab = document.getElementById(currentId)
    var menu = document.querySelector('#tabContextMenu')
    var deleteItem = document.getElementById('tab_menu_item_delete')
    deleteItem.onclick = showDelTabDialog.bind(null, tabItem)
    menu.show(currentTab)
    event.preventDefault()
}

function setVisibility(id, visible) {
    let element = document.getElementById(id)
    if (visible) {
        element.style.display = "block"
    } else {
        element.style.display = "none"
    }
}

function newTab(title, icon) {
    if (title.trim() === "") {
        return
    }
    bridge.newTabNative(title, icon, (result) => {
        var newTabItem = JSON.parse(result)
        headerTabs.splice(headerTabs.length - 1, 0, newTabItem)

        var tabEle = document.getElementById("headerTabs")
        var addTabEle = document.getElementById(ADD_TAB_ID)
        addTabEle.selected = false

        var newTabEle = newNormalTabEle(newTabItem, true)
        tabEle.insertBefore(newTabEle, addTabEle)

        setTimeout(() => {
            tabEle.options[headerTabs.length - 2].selected = true
            onTabSelectedAsync()
        }, 0)
    })
}

function showDelTabDialog(tabItem, _) {
    var params = {
        group_name: tabItem.title,
        item_count: getTodoItemsCountUnderCurrentTab().toString()
    }
    var text = formatString(lang.text_dialog_delete_group, params)
    showDialog(text, () => {
        deleteTab(tabItem)
    })
}

function newTodoItem(text) {
    if (lastTabId.length == 0) {
        return
    }
    if (text.length == 0) {
        return
    }
    bridge.newTodoItemNative(lastTabId, text, (_) => { })
}

function showDialog(text, onClick) {
    var dialog = document.getElementById('dialog')
    document.getElementById('dialog-text').textContent = text
    var positiveBtn = document.getElementById('dialog-positive-btn')
    positiveBtn.textContent = lang.text_dialog_button_positive
    positiveBtn.onclick = onClick

    var negativeBtn = document.getElementById('dialog-negative-btn')
    negativeBtn.textContent = lang.text_dialog_button_negative

    dialog.show()
}

function deleteTab(tabItem) {
    var tabItemEle = document.getElementById(getTabElementId(tabItem))

    var tab = document.getElementById('headerTabs')
    tab.options.splice(lastSelectedTabIndex, 1)
    tab.removeChild(tabItemEle)
    headerTabs.splice(lastSelectedTabIndex, 1)
    bridge.deleteTabNative(tabItem.id)

    var pendingIndex = Math.max(lastSelectedTabIndex - 1, 0)

    setTimeout(() => {
        tab.options[pendingIndex].selected = true
        onTabSelectedAsync()
    }, 1)

}

function createTodoItemEle(todoItem, isLastOne) {
    var li = document.createElement('li')
    li.style.display = 'flex' // 设置为水平布局
    li.style.width = '100%'
    if (isLastOne) {
        li.style.borderBottom = 'none'
    } else {
        li.style.borderBottom = '1px solid var(--s-color-outline-variant)'
    }

    var checkbox = document.createElement('s-checkbox')
    checkbox.style.width = '40px' // 设置复选框大小固定
    checkbox.style.height = '40px'
    checkbox.style.minWidth = '40px' // 设置复选框大小固定
    checkbox.style.minHeight = '40px'
    checkbox.checked = todoItem.finished
    checkbox.onchange = function () {
        onTodoItemChecked(todoItem.id, checkbox.checked)
    }

    var textContainer = document.createElement('div')
    textContainer.style.flex = '1' // 填充剩余空间
    textContainer.style.width = '200px'
    textContainer.style.minWidth = '160px'
    textContainer.style.marginRight = '8px' // 设置与图标按钮之间的间距
    textContainer.style.display = 'flex' // 设置为弹性布局
    textContainer.style.flexDirection = 'column' // 设置为垂直布局

    var text = document.createElement('div')
    text.textContent = todoItem.text
    text.style.paddingTop = '10px'
    text.style.paddingBottom = '10px'
    text.style.fontSize = '14px' // 设置文本尺寸

    if (todoItem.finished) {
        text.style.color = 'darkgray'
        text.style.textDecoration = 'line-through'
        text.style.whiteSpace = 'nowrap' // 单行显示
        text.style.overflow = 'hidden' // 隐藏超出部分
        text.style.textOverflow = 'ellipsis' // 超出部分用省略号表示
    } else {
        text.style.wordWrap = 'break-word' // 文本换行
    }
    textContainer.appendChild(text)

    var iconButton = document.createElement('s-icon-button')
    iconButton.style.minWidth = '40px' // 设置复选框大小固定
    iconButton.style.minHeight = '40px'
    var icon = document.createElement('s-icon')
    icon.innerHTML =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -960 960 960">' +
        '<path d="M280-120q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520ZM360-280h80v-360h-80v360Zm160 0h80v-360h-80v360ZM280-720v520-520Z"></path>' +
        '</svg>'

    iconButton.onclick = function () {
        deleteTodoItem(todoItem.id)
    }
    iconButton.appendChild(icon)

    // 根据不同状态隐藏图标按钮
    if (todoItem.finished) {
        iconButton.style.display = 'flex'
    } else {
        iconButton.style.display = 'none'
    }

    // 将子元素添加到 li 元素中
    li.appendChild(checkbox)
    li.appendChild(textContainer)
    li.appendChild(iconButton)

    return li
}

function onTodoItemChecked(todoItemId, checked) {
    bridge.checkTodoItemNative(todoItemId, checked, (result) => {
        refreshTodoItems()
    })
}

function deleteTodoItem(todoItemId) {
    bridge.deleteTodoItemNative(todoItemId, (result) => {
        refreshTodoItems()
    })
}

function getTodoItemsCountUnderCurrentTab() {
    return document.getElementById('todoList').children.length
}

function showCommonMenu(anchor, items) {
    var menu = document.getElementById('common_menu')
    menu.innerHTML = ''
    items.forEach( item => {
        var itemEle = document.createElement('s-menu-item')
        itemEle.textContent = item.title
        if (item.onClick) {
            itemEle.onclick = item.onClick
        }
        
        menu.appendChild(itemEle)
    })
    menu.show(anchor)
}