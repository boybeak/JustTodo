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