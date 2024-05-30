class NativeBridge extends AbsBridge {

    constructor() {
        super()
        this.callbackMap = new Map();
        this.iconsBuildInCache = null; // 用于缓存图标结果
    }

    handleResult(eventId, result) {
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
    newTabNative(title, icon, callback) {
        let eventId = this.newEventId()
        this.callbackMap.set(eventId, callback)
        var params = [
            eventId, title, btoa(icon)
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
        this.callbackMap.set(eventId, callback)
        window.webkit.messageHandlers.readClipboard.postMessage(eventId)
    }

    getBuildInIcons(callback) {
        if (this.iconsBuildInCache) {
            // 如果有缓存，直接调用回调并返回
            callback(this.iconsBuildInCache);
            return;
        }
        let eventId = this.newEventId()
        let nativeCallback = (iconsJson) => {
            var icons = JSON.parse(iconsJson)
            icons.forEach( icon => {
                icon.svg = atob(icon.svgBase64)
                icon.svgBase64 = ''
            });
            callback(icons)
        }
        this.callbackMap.set(eventId, nativeCallback)
        window.webkit.messageHandlers.getBuildInIcons.postMessage(eventId)
    }
    addCustomIcons(callback) {
        let eventId = this.newEventId()
        let nativeCallback = (iconsJson) => {
            var icons = JSON.parse(iconsJson)
            icons.forEach( icon => {
                icon.svg = atob(icon.svgBase64)
                icon.svgBase64 = ''
            });
            callback(icons)
        }
        this.callbackMap.set(eventId, nativeCallback)
        window.webkit.messageHandlers.addCustomIcons.postMessage(eventId)
    }
    getCustomIcons(callback) {
        let eventId = this.newEventId()
        let nativeCallback = (iconsJson) => {
            var icons = JSON.parse(iconsJson)
            icons.forEach( icon => {
                icon.svg = atob(icon.svgBase64)
                icon.svgBase64 = ''
            });
            callback(icons)
        }
        this.callbackMap.set(eventId, nativeCallback)
        window.webkit.messageHandlers.getCustomIcons.postMessage(eventId)
    }
}

const bridge = new NativeBridge()