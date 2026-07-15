using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Services
{
    public class PedidoService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public PedidoService()
        {
            Contexto = new BD_LENEntities();
        }

        public List<LineaCarritoViewModel> ConsultarResumenCheckout(
            int IdUsuario,
            int IdDireccion)
        {
            return Contexto
                .SP_ConsultarResumenCheckout(
                    IdUsuario,
                    IdDireccion
                )
                .Select(Linea => new LineaCarritoViewModel
                {
                    IdProducto = Linea.IdProducto,
                    NombreProducto = Linea.NombreProducto,
                    RutaImagen = Linea.RutaImagen,
                    PrecioUnitario = Linea.PrecioUnitario,
                    Cantidad = Linea.Cantidad,
                    SubtotalLinea = Linea.SubtotalLinea ?? 0,
                    StockDisponible = Linea.StockDisponible,
                    Disponible = Linea.Disponible ?? false
                })
                .ToList();
        }

        public List<SelectListItem> ConsultarMetodosPago()
        {
            return Contexto
                .SP_ConsultarMetodosPago()
                .Select(Metodo => new SelectListItem
                {
                    Value = Metodo.IdMetodoPago.ToString(),
                    Text = Metodo.NombreMetodo
                })
                .ToList();
        }

        public SP_ConfirmarCompra_Result ConfirmarCompra(
            int IdUsuario,
            int IdDireccion,
            int IdMetodoPago,
            decimal CostoEnvio)
        {
            SP_ConfirmarCompra_Result Resultado = Contexto
                .SP_ConfirmarCompra(
                    IdUsuario,
                    IdDireccion,
                    IdMetodoPago,
                    CostoEnvio
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return new SP_ConfirmarCompra_Result
                {
                    Exitoso = false,
                    Mensaje = "No fue posible completar la compra. Por favor intente de nuevo."
                };
            }

            return Resultado;
        }

        public ConfirmacionViewModel ConsultarConfirmacion(
            int IdPedido,
            int IdUsuario)
        {
            List<SP_ConsultarConfirmacionPedido_Result> Filas = Contexto
                .SP_ConsultarConfirmacionPedido(
                    IdPedido,
                    IdUsuario
                )
                .ToList();

            if (Filas.Count == 0)
            {
                return null;
            }

            SP_ConsultarConfirmacionPedido_Result Encabezado = Filas[0];

            return new ConfirmacionViewModel
            {
                IdPedido = Encabezado.IdPedido,
                NumeroFactura = Encabezado.NumeroFactura,
                FechaPedido = Encabezado.FechaPedido,
                Subtotal = Encabezado.Subtotal,
                CostoEnvio = Encabezado.CostoEnvio,
                Total = Encabezado.Total,
                EstadoVisible = Encabezado.EstadoVisible,
                NombreMetodoPago = Encabezado.NombreMetodoPago,
                NombreDestinatario = Encabezado.NombreDestinatario,
                DireccionExacta = Encabezado.DireccionExacta,
                NombreDistrito = Encabezado.NombreDistrito,
                NombreCanton = Encabezado.NombreCanton,
                NombreProvincia = Encabezado.NombreProvincia,
                Lineas = Filas
                    .Select(Fila => new LineaPedidoViewModel
                    {
                        IdProducto = Fila.IdProducto,
                        NombreProducto = Fila.NombreProducto,
                        RutaImagen = Fila.RutaImagen,
                        Cantidad = Fila.Cantidad,
                        PrecioUnitario = Fila.PrecioUnitario,
                        SubtotalLinea = Fila.SubtotalLinea
                    })
                    .ToList()
            };
        }

        public HistorialViewModel ConsultarHistorial(
            int IdUsuario,
            int Pagina,
            int TamanoPagina)
        {
            if (Pagina < 1)
            {
                Pagina = 1;
            }

            if (TamanoPagina < 1)
            {
                TamanoPagina = 10;
            }

            List<SP_ConsultarHistorialPedidos_Result> Filas = Contexto
                .SP_ConsultarHistorialPedidos(
                    IdUsuario,
                    Pagina,
                    TamanoPagina
                )
                .ToList();

            return new HistorialViewModel
            {
                PaginaActual = Pagina,
                TamanoPagina = TamanoPagina,
                TotalFilas = Filas.Count > 0
                    ? (Filas[0].TotalFilas ?? 0)
                    : 0,
                Pedidos = Filas
                    .Select(Fila => new PedidoResumenViewModel
                    {
                        IdPedido = Fila.IdPedido,
                        NumeroFactura = Fila.NumeroFactura,
                        FechaPedido = Fila.FechaPedido,
                        Total = Fila.Total,
                        EstadoVisible = Fila.EstadoVisible,
                        CantidadProductos = Fila.CantidadProductos ?? 0
                    })
                    .ToList()
            };
        }

        public DetallePedidoViewModel ConsultarDetalle(
            int IdPedido,
            int IdUsuario)
        {
            List<SP_ConsultarDetallePedido_Result> Filas = Contexto
                .SP_ConsultarDetallePedido(
                    IdPedido,
                    IdUsuario
                )
                .ToList();

            if (Filas.Count == 0)
            {
                return null;
            }

            SP_ConsultarDetallePedido_Result Encabezado = Filas[0];

            return new DetallePedidoViewModel
            {
                IdPedido = Encabezado.IdPedido,
                NumeroFactura = Encabezado.NumeroFactura,
                FechaPedido = Encabezado.FechaPedido,
                Subtotal = Encabezado.Subtotal,
                CostoEnvio = Encabezado.CostoEnvio,
                Total = Encabezado.Total,
                EstadoVisible = Encabezado.EstadoVisible,
                FechaPago = Encabezado.FechaPago,
                NombreMetodoPago = Encabezado.NombreMetodoPago,
                EstadoPago = Encabezado.EstadoPago,
                NombreDestinatario = Encabezado.NombreDestinatario,
                TelefonoContacto = Encabezado.TelefonoContacto,
                DireccionExacta = Encabezado.DireccionExacta,
                Referencia = Encabezado.Referencia,
                NombreDistrito = Encabezado.NombreDistrito,
                NombreCanton = Encabezado.NombreCanton,
                NombreProvincia = Encabezado.NombreProvincia,
                Lineas = Filas
                    .Select(Fila => new LineaPedidoViewModel
                    {
                        IdProducto = Fila.IdProducto,
                        NombreProducto = Fila.NombreProducto,
                        RutaImagen = Fila.RutaImagen,
                        Cantidad = Fila.Cantidad,
                        PrecioUnitario = Fila.PrecioUnitario,
                        SubtotalLinea = Fila.SubtotalLinea
                    })
                    .ToList()
            };
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
