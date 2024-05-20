class NativeBridge extends AbsBridge {
    getTabsNative(callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        window.webkit.messageHandlers.getGroups.postMessage(eventId)
    }
    newTabNative(title, callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        var params = [
            eventId, title
        ]
        window.webkit.messageHandlers.newGroup.postMessage(params)
    }
    deleteTabNative(id) {
        window.webkit.messageHandlers.deleteGroup.postMessage(id)
    }
    getTodoItemsNative(groupId, callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        var params = [
            eventId, groupId
        ]
        window.webkit.messageHandlers.getTodoItems.postMessage(params)
    }
    newTodoItemNative(groupId, text, callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        var params = [
            eventId, groupId, text
        ]
        window.webkit.messageHandlers.newTodoItem.postMessage(params)
    }
    checkTodoItemNative(todoId, checked, callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        var params = [
            eventId, todoId, checked
        ]
        window.webkit.messageHandlers.checkTodoItem.postMessage(params)
    }
    deleteTodoItemNative(todoId, callback) {
        let eventId = newEventId()
        callbackMap.set(eventId, callback)
        var params = [
            eventId, todoId
        ]
        window.webkit.messageHandlers.deleteTodoItem.postMessage(params)
    }
}

const bridge = new NativeBridge()