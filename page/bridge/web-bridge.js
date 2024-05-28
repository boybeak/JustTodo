class WebBridge extends AbsBridge {

    static TABLE_NAME_GROUP = 'groups'
    static TABLE_NAME_ITEM = 'items'

    constructor() {
        super()
        // this.iconsCache = null; // 用于缓存图标结果
    }

    obtainDB(callback) {
        if (this.db) {
            callback(this.db)
        } else {
            const openDbReq = window.indexedDB.open('just-todo-db', 1)
            openDbReq.onerror = (event) => {
                console.log('Database error:', event.target.errorCode)
            }
            openDbReq.onupgradeneeded = (event) => {
                const db = event.target.result

                const groupStore = db.createObjectStore(WebBridge.TABLE_NAME_GROUP, { keyPath: 'id', autoIncrement: true })

                groupStore.createIndex('title', 'title')
                groupStore.createIndex('icon', 'icon')
                groupStore.createIndex('keep_front', 'keep_front')
                groupStore.createIndex('create_at', 'create_at')

                const itemStore = db.createObjectStore(WebBridge.TABLE_NAME_ITEM, { keyPath: 'id', autoIncrement: true })
                itemStore.createIndex('text', 'text')
                itemStore.createIndex('finished', 'finished')
                itemStore.createIndex('create_at', 'create_at')
                itemStore.createIndex('group_id', 'group_id')

                itemStore.createIndex('group_id_and_create_at', ['group_id', 'create_at'], { unique: false })

                this.db = db
            }
            openDbReq.onsuccess = (event) => {
                this.db = event.target.result
                
                callback(this.db)
            }
        }
    }

    storeOf(tableName, mode, action, onsuccess, onerror) {
        this.obtainDB((db) => {
            const transaction = db.transaction([tableName], mode)
            const objStore = transaction.objectStore(tableName)
            
            const request = action(objStore)
            if (!request) {
                return
            }
            if (onsuccess) {
                request.onsuccess = (event) => {
                    onsuccess(objStore, event.target.result)
                }
            }
            if (onerror) {
                request.onerror = (event) => {
                    if (onerror) {
                        onerror(event.target.errorCode)
                    }
                }
            }
        })
    }

    storeReadOf(tableName, action, onsuccess, onerror) {
        this.storeOf(tableName, 'readonly', action, onsuccess, onerror)
    }

    storeWriteOf(tableName, action, onsuccess, onerror) {
        this.storeOf(tableName, 'readwrite', action, onsuccess, onerror)
    }

    onSuccessWithJSON(callback) {
        return (store, result) => {
            callback(JSON.stringify(result))
        }
    }
    onErrorWithLog(name) {
        return (errorCode) => {
            console.error(name, ' - ', errorCode)
        }
    }

    getTabsNative(callback) {
        this.storeReadOf(WebBridge.TABLE_NAME_GROUP, (store) => {
            return store.getAll()
        }, this.onSuccessWithJSON(callback), this.onErrorWithLog('getTabsNative'))
    }

    newTabNative(title, icon, callback) {
        this.storeWriteOf(WebBridge.TABLE_NAME_GROUP, (store) => {
            var group = {
                title: title,
                icon: icon,
                keep_front: false,
                create_at: Date()
            }
            return store.add(group)
        }, (store, id) => {
            const getReq = store.get(id)
            getReq.onsuccess = (event) => {
                callback(JSON.stringify(event.target.result))
            }
            getReq.onerror = this.onErrorWithLog('newTabNative get')
        }, this.onErrorWithLog('newTabNative'))
    }

    deleteTabNative(groupId) {
        this.storeWriteOf(WebBridge.TABLE_NAME_ITEM, (store) => {
            const groupIdIndex = store.index('group_id')
            const cursor = groupIdIndex.openCursor(IDBKeyRange.only(groupId))
            console.log('deleteTabNative cursor=', cursor)
            return cursor
        }, (_, cursor) => {
            if (cursor) {
                cursor.delete()
                cursor.continue()
                return
            }
            this.storeWriteOf(WebBridge.TABLE_NAME_GROUP, (store) => {
                const delReq = store.delete(groupId)
                delReq.onsuccess = (event) => {
                }
                delReq.onerror = (event) => {
                }
            })
        }, this.onErrorWithLog('deleteTabNative deleteItems first'))
    }

    getTodoItemsNative(groupId, callback) {
        this.storeReadOf(WebBridge.TABLE_NAME_ITEM, (store) => {
            const groupIdIndex = store.index('group_id')

            let range = IDBKeyRange.only(groupId)
            const cursorReq = groupIdIndex.openCursor(range, 'prev')
            var items = []
            cursorReq.onsuccess = (event) => {
                const cursor = event.target.result
                if (cursor) {
                    items.push(cursor.value)
                    cursor.continue()
                    return
                }
                callback(JSON.stringify(items))
            }
            cursorReq.onerror = this.onErrorWithLog('getTodoItemsNative')
        })
    }

    newTodoItemNative(groupId, text, callback) {
        this.storeWriteOf(WebBridge.TABLE_NAME_ITEM, (store) => {
            var item = {
                text: text,
                create_at: Date(),
                finished: false,
                group_id: groupId,
            }
            return store.add(item)
        }, (store, id) => {
            const getReq = store.get(id)
            getReq.onsuccess = this.onSuccessWithJSON(callback)
            getReq.onerror = this.onErrorWithLog('newTodoItemNative get')
        }, this.onErrorWithLog('newTodoItemNative'))
    }

    checkTodoItemNative(todoId, checked, callback) {
        this.storeWriteOf(WebBridge.TABLE_NAME_ITEM, (store) => {
            return store.get(todoId)
        }, (store, todoItem) => {
            todoItem.finished = checked
            const putReq = store.put(todoItem)
            putReq.onsuccess = (event) => {
                const id = event.target.result
                const getReq = store.get(id)
                getReq.onsuccess = this.onSuccessWithJSON(callback)
                getReq.onerror = this.onErrorWithLog('checkTodoItemNative update get')
            },
            putReq.onerror = this.onErrorWithLog('checkTodoItemNative update')
        }, this.onErrorWithLog('checkTodoItemNative'))
    }

    deleteTodoItemNative(todoId, callback) {
        this.storeWriteOf(WebBridge.TABLE_NAME_ITEM, (store) => {
            return store.get(todoId)
        }, (store, todoItem) => {
            const deleteReq = store.delete(todoItem.id)
            deleteReq.onsuccess = (event) => {
                callback(JSON.stringify(todoItem))
            }
            deleteReq.onerror = this.onErrorWithLog('deleteTodoItemNative delete')
        }, this.onErrorWithLog('deleteTodoItemNative'))
    }

    copyTextNative(text) {
        navigator.clipboard.writeText(text)
    }

    readClipboard(callback) {
        navigator.clipboard.readText()
            .then(text => {
                callback(text)
            })
            .catch(err => {
                callback("")
            })
    }

    getIcons(callback) {
        if (this.iconsCache) {
            callback(self.iconsCache)
            return
        }
        let apiUrl = 'https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/metadata/icons.json'
        // fetch('https://cors-anywhere.herokuapp.com/' + apiUrl)
        fetch(apiUrl)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                this.iconsCache = JSON.parse(data)
                callback(this.iconsCache)
                // 处理返回的数据
            })
            .catch(error => {
                console.error('There has been a problem with your fetch operation:', error);
            });
    }
}
const bridge = new WebBridge()