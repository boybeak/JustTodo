function fillIcons(tableBody, icons, onAddIconClick, onNormalIconClick, onCustomRightClick) {
    var lastRow;
    tableBody.innerHTML = ''
    icons.forEach((icon, index) => {
        if (index % 8 == 0) {
            var row = document.createElement('tr')
            tableBody.appendChild(row)
            lastRow = row
        }
        
        var td = createIconTD(icon)
        
        lastRow.appendChild(td)

        td.onclick = (event) => {
            if (icon.isAdd) {
                if (onAddIconClick) {
                    onAddIconClick()
                }
            } else {
                if (onNormalIconClick) {
                    onNormalIconClick(icon)
                }
            }
        }
        if (icon.isCustom && onCustomRightClick) {
            td.addEventListener('contextmenu', (event) => {
                onCustomRightClick(event, icon)
            })
        }
    })
}

function createIconTD(icon) {
    var td = document.createElement('td')

    var div = document.createElement('div')
    div.style.width = '100%'
    div.style.height = '100%'
    div.style.alignItems = 'center'
    div.style.justifyContent = 'center'
    div.style.display = 'flex'

    var sIcon = document.createElement('s-icon')
    if (icon.isAdd) {
        sIcon.setAttribute('type', 'add')
        sIcon.style.color = 'rgba(127, 127, 127, 0.4)'
    } else {
        sIcon.innerHTML = icon.svg
    }

    div.appendChild(sIcon)
    td.appendChild(div)

    return td
}
