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

        var $metodoPago = $('#metodo-pago');
        var $datoPagoSimulado = $('#dato-pago-simulado');

        var bloquesPorMetodo = {
            'Tarjeta': '#pago-tarjeta',
            'Transferencia bancaria': '#pago-transferencia',
            'SINPE Móvil': '#pago-sinpe',
            'Efectivo contra entrega': '#pago-efectivo'
        };

        function mostrarAlerta(texto) {
            $('#alerta-checkout')
                .removeClass('d-none')
                .text(texto);

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function nombreMetodoSeleccionado() {
            return $metodoPago.find('option:selected').data('nombre') || '';
        }

        function actualizarBloqueVisible() {
            var nombre = nombreMetodoSeleccionado();

            $.each(bloquesPorMetodo, function (_, selector) {
                $(selector).addClass('d-none');
            });

            if (bloquesPorMetodo[nombre]) {
                $(bloquesPorMetodo[nombre]).removeClass('d-none');
            }
        }

        $metodoPago.on('change', actualizarBloqueVisible);
        actualizarBloqueVisible();

        /*
         * Construye el dato de pago simulado que se envía al servidor
         * según el método elegido; no se transmiten datos completos
         * de tarjeta (ni vencimiento ni CVV), solo un comprobante
         * simulado para mostrar en la confirmación.
         */
        function construirDatoPagoSimulado() {
            var nombre = nombreMetodoSeleccionado();

            if (nombre === 'Tarjeta') {
                var numero = $('#tarjeta-numero').val().replace(/\s+/g, '');

                if (numero.length < 4) {
                    return { valido: false, mensaje: 'Ingrese el número de la tarjeta.' };
                }

                if (!$('#tarjeta-vencimiento').val() || !$('#tarjeta-cvv').val()) {
                    return { valido: false, mensaje: 'Ingrese el vencimiento y el CVV de la tarjeta.' };
                }

                return {
                    valido: true,
                    dato: 'Tarjeta terminada en ' + numero.slice(-4)
                };
            }

            if (nombre === 'Transferencia bancaria') {
                var referencia = $('#transferencia-referencia').val().trim();

                if (!referencia) {
                    return { valido: false, mensaje: 'Ingrese el número de comprobante de la transferencia.' };
                }

                return {
                    valido: true,
                    dato: 'Transferencia bancaria, comprobante ' + referencia
                };
            }

            if (nombre === 'SINPE Móvil') {
                var telefono = $('#sinpe-telefono').val().trim();

                if (!telefono) {
                    return { valido: false, mensaje: 'Ingrese el número desde el que envía el SINPE Móvil.' };
                }

                return {
                    valido: true,
                    dato: 'SINPE Móvil desde ' + telefono
                };
            }

            if (nombre === 'Efectivo contra entrega') {
                return { valido: true, dato: 'Pago en efectivo contra entrega' };
            }

            return { valido: false, mensaje: 'Seleccione un método de pago para continuar.' };
        }

        $formulario.on('submit', function (evento) {
            var direccionSeleccionada =
                $formulario.find('input[name="IdDireccionSeleccionada"]:checked').length > 0;

            var metodoSeleccionado = $metodoPago.val();

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

            var resultadoPago = construirDatoPagoSimulado();

            if (!resultadoPago.valido) {
                evento.preventDefault();
                mostrarAlerta(resultadoPago.mensaje);
                return;
            }

            $datoPagoSimulado.val(resultadoPago.dato);

            /* Evita compras dobles por doble clic. */
            $('#btn-confirmar')
                .prop('disabled', true)
                .text('Procesando compra...');
        });
    });

})(jQuery);
