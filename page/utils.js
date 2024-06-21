if (window.webkit) {
    console.log = function (...data) {
        let logger = window.webkit.messageHandlers.consoleLog
        if (logger) {
            logger.postMessage(data);
        }
    };
}

function initUtils(callback) {
    var langJS;
    const userLanguage = navigator.language || navigator.userLanguage;
    switch (userLanguage) {
        case 'zh-CN':
            langJS = userLanguage
            break;
        default:
            langJS = "en-US"
            break
    }
    
    if (window.webkit) {
        // Xcode项目中，会把子分组中的文件，都直接放在分组根目录下
        loadScript('./' + langJS + '.js')
        callback(true)
    } else {
        loadScript('./lang/' + langJS + '.js')
        callback(false)
    }
}

function loadScript(url) {
    // 创建一个新的 script 元素
    const script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;

    document.head.appendChild(script);
}

function loadCSS(url) {
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.type = "text/css";
    link.href = url;
    document.head.appendChild(link);
}

function formatString(template, data) {
    return template.replace(/{(\w+)}/g, (match, key) => data[key] || '');
}

function disableContextMenu() {
    document.body.setAttribute('oncontextmenu', 'event.preventDefault();')
}

function showCommonMenu(menuId, anchor, items) {
    var menu = document.getElementById(menuId)
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

function showMask(id, text, onCommit) {
    let mask = document.getElementById(id)
    mask.style.display = 'block';
    mask.onclick = (e) => {
        if (e.target.id === id) {
            hideMask(id)
            onCommit(reeditor.value)
        }
    }
    document.body.style.overflow = 'hidden'; // 禁止底部内容滚动
    let reeditor = document.getElementById('reeditor')
    reeditor.value = text
    reeditor.addEventListener('keypress', (e) => {
        if (e.key == 'Enter') {
            hideMask(id)
            onCommit(reeditor.value)
            e.preventDefault()
        }
    })
}

function hideMask(id) {
    document.getElementById(id).style.display = 'none';
    mask.onclick = null
    document.body.style.overflow = ''; // 恢复底部内容滚动
}