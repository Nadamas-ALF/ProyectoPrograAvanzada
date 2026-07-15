/*
 * carrito.js — Módulo Carrito (RF-04)
 * Maneja las acciones AJAX del carrito: agregar, actualizar
 * cantidades y eliminar productos.
 *
 * Integración para el módulo de catálogo (otros compañeros):
 * llamar LEN_AgregarAlCarrito(idProducto, cantidad) desde el
 * botón "Agregar al carrito". Requiere que la página incluya
 * @Html.AntiForgeryToken() y este archivo.
 */

(function ($) {
    'use strict';

    function obtenerToken() {
        return $('input[name="__RequestVerificationToken"]')
            .first()
            .val();
    }

    function mostrarMensaje(tipo, texto) {
        var $alerta = $('#alerta-carrito');

        if ($alerta.length === 0) {
            window.alert(texto);
            return;
        }

        $alerta
            .removeClass('d-none alert-success alert-warning alert-danger')
            .addClass('alert-' + tipo)
            .text(texto);

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function manejarRespuesta(respuesta, alExito) {
        if (respuesta && respuesta.requiereLogin) {
            window.location.href = respuesta.urlLogin;
            return;
        }

        if (respuesta && respuesta.exitoso) {
            alExito(respuesta);
            return;
        }

        mostrarMensaje(
            'warning',
            (respuesta && respuesta.mensaje) ||
            'No fue posible completar la acción. Intente nuevamente.'
        );
    }

    function errorComunicacion() {
        mostrarMensaje(
            'danger',
            'No fue posible comunicarse con el servidor. Intente nuevamente.'
        );
    }

    /* Función global para agregar productos desde el catálogo. */
    window.LEN_AgregarAlCarrito = function (idProducto, cantidad) {
        $.post(
            window.LEN_URL_AGREGAR_CARRITO || '/Carrito/Agregar',
            {
                __RequestVerificationToken: obtenerToken(),
                IdProducto: idProducto,
                Cantidad: cantidad || 1
            }
        )
            .done(function (respuesta) {
                manejarRespuesta(respuesta, function (datos) {
                    mostrarMensaje('success', datos.mensaje);
                });
            })
            .fail(errorComunicacion);
    };

    $(function () {
        var $contenedor = $('#carrito-contenedor');

        if ($contenedor.length === 0) {
            return;
        }

        var urlActualizar = $contenedor.data('url-actualizar');
        var urlEliminar = $contenedor.data('url-eliminar');

        /* Cambio de cantidad: valida contra el stock y actualiza. */
        $contenedor.on('change', '.js-cantidad', function () {
            var $campo = $(this);
            var cantidad = parseInt($campo.val(), 10);
            var maximo = parseInt($campo.attr('max'), 10);

            if (isNaN(cantidad) || cantidad < 0) {
                $campo.val($campo.data('cantidadoriginal'));
                mostrarMensaje('warning', 'Ingrese una cantidad válida.');
                return;
            }

            if (cantidad > maximo) {
                $campo.val($campo.data('cantidadoriginal'));
                mostrarMensaje(
                    'warning',
                    'Solo hay ' + maximo + ' unidad(es) disponibles.'
                );
                return;
            }

            $campo.prop('disabled', true);

            $.post(
                urlActualizar,
                {
                    __RequestVerificationToken: obtenerToken(),
                    IdProducto: $campo.data('idproducto'),
                    Cantidad: cantidad
                }
            )
                .done(function (respuesta) {
                    manejarRespuesta(respuesta, function () {
                        window.location.reload();
                    });

                    if (!respuesta || !respuesta.exitoso) {
                        $campo
                            .prop('disabled', false)
                            .val($campo.data('cantidadoriginal'));
                    }
                })
                .fail(function () {
                    $campo
                        .prop('disabled', false)
                        .val($campo.data('cantidadoriginal'));

                    errorComunicacion();
                });
        });

        /* Eliminar una línea del carrito. */
        $contenedor.on('click', '.js-eliminar', function () {
            var $boton = $(this);
            var nombre = $boton.data('nombre');

            if (!window.confirm('¿Desea eliminar "' + nombre + '" del carrito?')) {
                return;
            }

            $boton.prop('disabled', true);

            $.post(
                urlEliminar,
                {
                    __RequestVerificationToken: obtenerToken(),
                    IdProducto: $boton.data('idproducto')
                }
            )
                .done(function (respuesta) {
                    manejarRespuesta(respuesta, function () {
                        window.location.reload();
                    });

                    if (!respuesta || !respuesta.exitoso) {
                        $boton.prop('disabled', false);
                    }
                })
                .fail(function () {
                    $boton.prop('disabled', false);
                    errorComunicacion();
                });
        });
    });

})(jQuery);
