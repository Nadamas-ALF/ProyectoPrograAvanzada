
(function () {
    "use strict";

    var ID_MODAL = "len-visor-imagen";

    function crearModal() {
        if (document.getElementById(ID_MODAL)) {
            return;
        }

        var Modal = document.createElement("div");

        Modal.id = ID_MODAL;
        Modal.className = "len-visor";
        Modal.setAttribute("role", "dialog");
        Modal.setAttribute("aria-modal", "true");
        Modal.setAttribute("aria-label", "Imagen ampliada");
        Modal.setAttribute("hidden", "hidden");

        Modal.innerHTML =
            '<button type="button" class="len-visor-cerrar" aria-label="Cerrar">&times;</button>' +
            '<img class="len-visor-imagen" src="" alt="" />';

        document.body.appendChild(Modal);

        Modal.addEventListener("click", function (Evento) {
            if (Evento.target === Modal
                || Evento.target.classList.contains("len-visor-cerrar")) {
                cerrar();
            }
        });
    }

    function abrir(Origen, TextoAlternativo) {
        crearModal();

        var Modal = document.getElementById(ID_MODAL);
        var Imagen = Modal.querySelector(".len-visor-imagen");

        Imagen.setAttribute("src", Origen);
        Imagen.setAttribute("alt", TextoAlternativo || "Imagen ampliada");

        Modal.removeAttribute("hidden");
        document.body.classList.add("len-visor-abierto");
    }

    function cerrar() {
        var Modal = document.getElementById(ID_MODAL);

        if (!Modal) {
            return;
        }

        Modal.setAttribute("hidden", "hidden");
        document.body.classList.remove("len-visor-abierto");
    }

    document.addEventListener("click", function (Evento) {
        var Objetivo = Evento.target;

        if (!Objetivo || Objetivo.tagName !== "IMG") {
            return;
        }

        if (!Objetivo.classList.contains("js-ver-grande")) {
            return;
        }

        Evento.preventDefault();

        abrir(
            Objetivo.getAttribute("src"),
            Objetivo.getAttribute("alt")
        );
    });

    document.addEventListener("keydown", function (Evento) {
        if (Evento.key === "Escape") {
            cerrar();
        }
    });
})();
