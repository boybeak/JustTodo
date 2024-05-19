const callbackMap = new Map();

function handleResult(eventId, result) {
    let callback = callbackMap.get(eventId)
    callback(result)
    callbackMap.delete(eventId)
}

var localTabs;
if (window.webkit) {
    console.log = function (...data) {
        window.webkit.messageHandlers.consoleLog.postMessage(data);
    };
} else {
    localTabs = [
        {
            id: '0',
            title: '0000'
        },
        {
            id: '1',
            title: '1111'
        },
        {
            id: '2',
            title: '2222'
        },
        {
            id: '3',
            title: '3333'
        }
    ]
}

window.getTabs = function (callback) {
    getTabsNative((result) => {
        let tabs = JSON.parse(result)

        let addTab = {}
        addTab.isAddTab = true
        tabs.push(addTab)

        if (callback) {
            callback(tabs)
        }
    })
}

function getTabsNative(callback) {
    if (!window.webkit) {
        callback(JSON.stringify(localTabs))
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    window.webkit.messageHandlers.getGroups.postMessage(eventId)
}

function newTabNative(title, callback) {
    if (!window.webkit) {
        var newTab = { id: Date.now().toString(), title: title}
        localTabs.splice(localTabs.length - 1, 0, newTab)
        callback(JSON.stringify(newTab))
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    var params = [
        eventId, title
    ]
    window.webkit.messageHandlers.newGroup.postMessage(params)
}

function deleteTabNative(id) {
    if (!window.webkit) {
        localTabs = localTabs.filter(function(tab) {
            return tab.id == id
        })
        return
    }
    window.webkit.messageHandlers.deleteGroup.postMessage(id)
}

function getTodoItemsNative(groupId, callback) {
    if (!window.webkit) {
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    var params = [
        eventId, groupId
    ]
    window.webkit.messageHandlers.getTodoItems.postMessage(params)
}

function newTodoItemNative(groupId, text, callback) {
    if (!window.webkit) {
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    var params = [
        eventId, groupId, text
    ]
    window.webkit.messageHandlers.newTodoItem.postMessage(params)
}

function checkTodoItemNative(todoId, checked, callback) {
    if (!window.webkit) {
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    var params = [
        eventId, todoId, checked
    ]
    window.webkit.messageHandlers.checkTodoItem.postMessage(params)
}

function newEventId() {
    return generateRandomString(8)
}

function generateRandomString(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}