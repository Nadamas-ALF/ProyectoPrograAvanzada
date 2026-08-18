

(function () {
    'use strict';

    document.addEventListener('DOMContentLoaded', function () {

        var Contenedor = document.querySelector('.portada-swiper');

        if (!Contenedor || typeof Swiper === 'undefined') {
            return;
        }

        var TotalSlides = Contenedor.querySelectorAll('.swiper-slide').length;

        if (TotalSlides === 0) {
            return;
        }

        var UsarLoop = TotalSlides > 2;

        new Swiper(Contenedor, {
            slidesPerView: 1,
            spaceBetween: 24,
            loop: UsarLoop,
            grabCursor: true,
            watchOverflow: true,
            observer: true,
            observeParents: true,

            autoplay: {
                delay: 5000,
                disableOnInteraction: false,
                pauseOnMouseEnter: true
            },

            keyboard: {
                enabled: true,
                onlyInViewport: true
            },

            pagination: {
                el: '.portada-paginacion',
                clickable: true
            },

            navigation: {
                prevEl: '.portada-flecha-anterior',
                nextEl: '.portada-flecha-siguiente'
            },

            a11y: {
                enabled: true,
                prevSlideMessage: 'Producto anterior',
                nextSlideMessage: 'Producto siguiente',
                paginationBulletMessage: 'Ir al producto {{index}}'
            },

            breakpoints: {
                768: {
                    slidesPerView: 1,
                    spaceBetween: 32
                },
                992: {
                    slidesPerView: 2,
                    spaceBetween: 32
                }
            }
        });
    });
})();
