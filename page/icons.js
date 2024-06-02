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

    showIcons(customIconsCache)
}

function onIconRemoved(iconId) {
    customIconsCache = customIconsCache.filter( item => item.iconId != iconId)
    showIcons(customIconsCache)
}

function showIcons(icons) {
    var iconsNew = []
    iconsNew.push(...icons)
    iconsNew.push(iconAddBtn)

    var iconsTBody = document.getElementById('icons-tbody')
    fillIcons(iconsTBody, iconsNew, () => {
        bridge.openIconsChooser()
    }, null, (event, icon) => {
        showCommonMenu('common_menu', event, [
            {
                title: lang.text_delete,
                onClick: (event) => {
                    bridge.deleteCustomIcon(icon)
                }
            }
        ])
        event.preventDefault()
    })
}

function onPageReady() {
    disableContextMenu()
    var app = document.getElementById('app')
    app.setAttribute('theme', 'auto')

    document.getElementById('icons_window_tip').textContent = lang.text_icons_window_drop

    bridge.addEventCallback('onIconsAdded', onNewIcons)
    bridge.addEventCallback('onIconRemoved', onIconRemoved)

    bridge.getCustomIcons(icons => {
        customIconsCache.push(...icons)
        showIcons(icons)
    })
}