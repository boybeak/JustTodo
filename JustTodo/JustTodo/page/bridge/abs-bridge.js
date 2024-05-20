class AbsBridge {

    constructor() {
        this.callbackMap = new Map();
    }

    handleResult(eventId, result) {
        let callback = this.callbackMap.get(eventId)
        callback(result)
        this.callbackMap.delete(eventId)
    }

    newEventId() {
        return generateRandomString(8)
    }
    
    generateRandomString(length) {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
    }

    getTabs(callback) {
        this.getTabsNative((result) => {
            let tabs = JSON.parse(result)
    
            let addTab = {}
            addTab.isAddTab = true
            tabs.push(addTab)
    
            if (callback) {
                callback(tabs)
            }
        })
    }

    getTabsNative(callback) {}
    newTabNative(title, callback) {}
    deleteTabNative(id) {}
    getTodoItemsNative(groupId, callback) {}
    newTodoItemNative(groupId, text, callback) {}
    checkTodoItemNative(todoId, checked, callback) {}
    deleteTodoItemNative(todoId, callback) {}

}