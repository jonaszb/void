export default {
    mounted() {
        const expiresAt = this.el.getAttribute('msg-timestamp');
        const expiryTime = new Date(expiresAt);
        const updateCountdown = () => {
            const now = new Date();
            let remainingTime = Math.max(0, expiryTime - now);

            const hours = Math.floor((remainingTime / (1000 * 60 * 60)) % 24);
            const minutes = Math.floor((remainingTime / (1000 * 60)) % 60);

            this.el.textContent = `Time left:\n${String(hours).padStart(2, '0')}h ${String(minutes).padStart(2, '0')}m`;

            if (remainingTime <= 0) {
                clearInterval(timer);
            }
        };

        updateCountdown();
        const timer = setInterval(updateCountdown, 1000);

        this.handleEvent('phx:remove', () => clearInterval(timer));
    },
};
