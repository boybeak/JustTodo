if (window.webkit) {
    console.log = function (...data) {
        window.webkit.messageHandlers.consoleLog.postMessage(data);
    };
}

function loadScript(url) {
    // 创建一个新的 script 元素
    const script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;

    document.head.appendChild(script);
}
function formatString(template, data) {
    return template.replace(/{(\w+)}/g, (match, key) => data[key] || '');
}