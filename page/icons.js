document.addEventListener('DOMContentLoaded', function() {
    onPageReady()
});

let iconAddBtn = {
    iconId: 'addIconBtn',
    isAdd: true
}
var customIconsCache = []

function onNewIcons(iconsJson) {

    var icons = JSON.parse(iconsJson)
    bridge.manageIcons(icons, true)
    customIconsCache.push(...icons)

    var iconsTBody = document.getElementById('icons-tbody')
    showIcons(iconsTBody, customIconsCache)
}

function showIcons(iconsTBody, icons) {
    var iconsNew = []
    iconsNew.push(...icons)
    iconsNew.push(iconAddBtn)

    fillIcons(iconsTBody, iconsNew, () => {
        bridge.openIconsChooser()
    }, null)
}

function onPageReady() {
    disableContextMenu()
    var app = document.getElementById('app')
    app.setAttribute('theme', 'auto')

    bridge.addEventCallback('onIconsAdd', onNewIcons)
    bridge.getCustomIcons(icons => {
        customIconsCache.push(...icons)
        var iconsTBody = document.getElementById('icons-tbody')
        showIcons(iconsTBody, icons)
    })
}