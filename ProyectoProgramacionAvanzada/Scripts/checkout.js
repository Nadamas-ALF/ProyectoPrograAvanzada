/*
 * checkout.js — Módulo Checkout (RF-05 / RF-08)
 * Valida los campos obligatorios del checkout y evita el doble
 * envío del formulario de confirmación de compra.
 */

(function ($) {
    'use strict';

    $(function () {
        var $formulario = $('#form-checkout');

        if ($formulario.length === 0) {
            return;
        }

        function mostrarAlerta(texto) {
            $('#alerta-checkout')
                .removeClass('d-none')
                .text(texto);

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        $formulario.on('submit', function (evento) {
            var direccionSeleccionada =
                $formulario.find('input[name="IdDireccionSeleccionada"]:checked').length > 0;

            var metodoSeleccionado = $('#metodo-pago').val();

            if (!direccionSeleccionada) {
                evento.preventDefault();
                mostrarAlerta('Seleccione una dirección de envío para continuar.');
                return;
            }

            if (!metodoSeleccionado) {
                evento.preventDefault();
                mostrarAlerta('Seleccione un método de pago para continuar.');
                return;
            }

            /* Evita compras dobles por doble clic. */
            $('#btn-confirmar')
                .prop('disabled', true)
                .text('Procesando compra...');
        });
    });

})(jQuery);
