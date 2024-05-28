class Tip {
    constructor() {
        this.tipElement = document.createElement('div');
        this.tipElement.className = 'tip';
        document.body.appendChild(this.tipElement);
    }

    show(anchor, text, backgroundColor = '#333', textColor = 'white') {
        this.tipElement.style.setProperty('--background-color', backgroundColor)
        this.tipElement.style.setProperty('--text-color', textColor)
        this.tipElement.innerText = text; // Set the tip text

        // Temporarily display the element to get its dimensions
        this.tipElement.style.display = 'block';
        const rect = anchor.getBoundingClientRect();
        const tipHeight = this.tipElement.offsetHeight;

        // Adjust position to be above the anchor element
        this.tipElement.style.left = `${rect.left + window.pageXOffset + (rect.width / 2)}px`;
        this.tipElement.style.top = `${rect.top + window.pageYOffset - tipHeight - 10}px`; // Adjust 10px above the anchor to account for the arrow
    }

    showError(anchor, error) {
        // this.show(anchor, error, 'var(--s-color-error)', 'var(--s-color-on-error)')
        // this.show(anchor, error)
        this.show(anchor, error, 'red', 'white')
    }

    hide() {
        this.tipElement.style.display = 'none';
    }
}