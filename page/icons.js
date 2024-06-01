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
                    customIconsCache = customIconsCache.filter( item => item.iconId != icon.iconId)
                    showIcons(customIconsCache)
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

    bridge.addEventCallback('onIconsAdd', onNewIcons)
    bridge.getCustomIcons(icons => {
        customIconsCache.push(...icons)
        showIcons(icons)
    })
}