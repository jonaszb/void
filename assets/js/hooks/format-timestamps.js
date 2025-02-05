export default {
    mounted() {
        this.formatTimestamps();
    },
    updated() {
        this.formatTimestamps();
    },
    formatTimestamps() {
        const timeElements = this.el.querySelectorAll('time[msg-timestamp]');

        timeElements.forEach((timeElement) => {
            const timestampIso = timeElement.getAttribute('msg-timestamp');
            const date = new Date(timestampIso);

            const now = new Date();
            let formattedDate;

            if (date.toDateString() === now.toDateString()) {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            } else if (date.getFullYear() === now.getFullYear()) {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            } else {
                formattedDate = new Intl.DateTimeFormat(undefined, {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(date);
            }
            timeElement.textContent = formattedDate;
        });
    },
};
