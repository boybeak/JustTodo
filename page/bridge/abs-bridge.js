class AbsBridge {

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
    newTabNative(title, icon, callback) {}
    deleteTabNative(id) {}
    getTodoItemsNative(groupId, callback) {}
    newTodoItemNative(groupId, text, callback) {}
    checkTodoItemNative(todoId, checked, callback) {}
    deleteTodoItemNative(todoId, callback) {}
    copyTextNative(text) {}
    readClipboard(callback) {}
    getBuildInIcons(callback) {}
    addCustomIcons(callback) {}
    getCustomIcons(callback) {}
}