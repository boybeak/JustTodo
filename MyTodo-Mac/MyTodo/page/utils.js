function formatString(template, data) {
    return template.replace(/{(\w+)}/g, (match, key) => data[key] || '');
}
