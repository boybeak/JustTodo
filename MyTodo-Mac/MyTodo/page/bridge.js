const callbackMap = new Map();

function handleResult(eventId, result) {
    let callback = callbackMap.get(eventId)
    callback(result)
    callbackMap.delete(eventId)
}

if (window.webkit) {
    console.log = function (...data) {
        window.webkit.messageHandlers.consoleLog.postMessage(data);
    };
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
        callback(JSON.stringify(
            [
                {
                    id: '11111',
                    title: 'ABC'
                },
                {
                    id: '2222',
                    title: 'DEF'
                }
            ]
        ))
        return
    }
    let eventId = newEventId()
    callbackMap.set(eventId, callback)
    window.webkit.messageHandlers.getGroups.postMessage(eventId)
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