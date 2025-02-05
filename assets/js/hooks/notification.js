export default {
    mounted() {
        const msgHeight = this.el.getBoundingClientRect().height + 8;
        const container = document.querySelector('#notifications-container');
        container.classList.add('transition-none');
        container.style.transform = `translateY(${msgHeight}px)`;
        setTimeout(() => {
            this.el.classList.remove('opacity-0', 'translate-y-full');
            this.el.classList.add('opacity-100', 'translate-y-0');
            container.classList.add('transition-all');
            container.classList.remove('transition-none');
            container.style.transform = `translateY(0px)`;
        }, 100);

        setTimeout(() => {
            this.pushEvent('remove_notification', { id: this.el.id });
        }, 5500);
    },
};
