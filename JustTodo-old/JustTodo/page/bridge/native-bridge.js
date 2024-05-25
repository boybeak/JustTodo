class NativeBridge extends AbsBridge {

    constructor() {
        super()
        this.callbackMap = new Map();
    }

    handleResult(eventId, result) {
        console.log('handleResult eventId=', eventId)
        let callback = this.callbackMap.get(eventId)
        callback(result)
        this.callbackMap.delete(eventId)
    }

    newEventId() {
        return this.generateRandomString(8)
    }
    
    generateRandomString(length) {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
    }

    getTabsNative(callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        window.webkit.messageHandlers.getGroups.postMessage(eventId)
    }
    newTabNative(title, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, title
        ]
        window.webkit.messageHandlers.newGroup.postMessage(params)
    }
    deleteTabNative(id) {
        window.webkit.messageHandlers.deleteGroup.postMessage(id)
    }
    getTodoItemsNative(groupId, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, groupId
        ]
        window.webkit.messageHandlers.getTodoItems.postMessage(params)
    }
    newTodoItemNative(groupId, text, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, groupId, text
        ]
        window.webkit.messageHandlers.newTodoItem.postMessage(params)
    }
    checkTodoItemNative(todoId, checked, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, todoId, checked
        ]
        window.webkit.messageHandlers.checkTodoItem.postMessage(params)
    }
    deleteTodoItemNative(todoId, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, todoId
        ]
        window.webkit.messageHandlers.deleteTodoItem.postMessage(params)
    }
    copyTextNative(text) {
        window.webkit.messageHandlers.copyText.postMessage(text)
    }
    readClipboard(callback) {
        let eventId = this.newEventId()
        console.log('readClipboard eventId=', eventId)
        this.callbackMap.set(eventId, callback)
        window.webkit.messageHandlers.readClipboard.postMessage(eventId)
    }
}

const bridge = new NativeBridge()