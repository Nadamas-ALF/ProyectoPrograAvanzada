using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Services
{
    /// <summary>
    /// Servicio del módulo administrativo para la gestión de
    /// pedidos (RF-13) y los reportes de ventas (RF-14).
    /// </summary>
    public class PedidoAdminService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public PedidoAdminService()
        {
            Contexto = new BD_LENEntities();
        }

        private static object ValorONulo(object Valor)
        {
            return Valor ?? DBNull.Value;
        }

        /* ================= RF-13: PEDIDOS ================= */

        public ListadoPedidosAdminViewModel ConsultarPedidos(
            string Busqueda,
            int? IdEstado,
            DateTime? FechaInicio,
            DateTime? FechaFin,
            int Pagina,
            int TamanoPagina)
        {
            if (Pagina < 1)
            {
                Pagina = 1;
            }

            List<PedidoAdminViewModel> Pedidos = Contexto.Database
                .SqlQuery<PedidoAdminViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarPedidos @Busqueda, @IdEstado, @FechaInicio, @FechaFin, @Pagina, @TamanoPagina",
                    new SqlParameter("@Busqueda", ValorONulo(Busqueda)),
                    new SqlParameter("@IdEstado", ValorONulo(IdEstado)),
                    new SqlParameter("@FechaInicio", ValorONulo(FechaInicio)),
                    new SqlParameter("@FechaFin", ValorONulo(FechaFin)),
                    new SqlParameter("@Pagina", Pagina),
                    new SqlParameter("@TamanoPagina", TamanoPagina)
                )
                .ToList();

            return new ListadoPedidosAdminViewModel
            {
                Pedidos = Pedidos,
                Busqueda = Busqueda,
                IdEstado = IdEstado,
                FechaInicio = FechaInicio,
                FechaFin = FechaFin,
                PaginaActual = Pagina,
                TamanoPagina = TamanoPagina,
                TotalFilas = Pedidos.Count > 0
                    ? Pedidos[0].TotalFilas
                    : 0,
                Estados = ConsultarEstadosPedido()
            };
        }

        public List<SelectListItem> ConsultarEstadosPedido()
        {
            return Contexto.Database
                .SqlQuery<EstadoPedidoViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarEstadosPedido"
                )
                .Select(Estado => new SelectListItem
                {
                    Value = Estado.IdEstado.ToString(),
                    Text = Estado.NombreEstado
                })
                .ToList();
        }

        public DetallePedidoAdminViewModel ConsultarDetalle(int IdPedido)
        {
            List<DetallePedidoAdminFila> Filas = Contexto.Database
                .SqlQuery<DetallePedidoAdminFila>(
                    "EXEC dbo.SP_Admin_ConsultarDetallePedido @IdPedido",
                    new SqlParameter("@IdPedido", IdPedido)
                )
                .ToList();

            if (Filas.Count == 0)
            {
                return null;
            }

            DetallePedidoAdminFila Encabezado = Filas[0];

            DetallePedidoAdminViewModel Modelo = new DetallePedidoAdminViewModel
            {
                IdPedido = Encabezado.IdPedido,
                NumeroFactura = Encabezado.NumeroFactura,
                FechaPedido = Encabezado.FechaPedido,
                Subtotal = Encabezado.Subtotal,
                CostoEnvio = Encabezado.CostoEnvio,
                Total = Encabezado.Total,
                IdEstado = Encabezado.IdEstado,
                NombreEstado = Encabezado.NombreEstado,
                MotivoCancelacion = Encabezado.MotivoCancelacion,
                NombreCliente = Encabezado.NombreCliente,
                EmailCliente = Encabezado.EmailCliente,
                NombreDestinatario = Encabezado.NombreDestinatario,
                TelefonoContacto = Encabezado.TelefonoContacto,
                DireccionExacta = Encabezado.DireccionExacta,
                NombreDistrito = Encabezado.NombreDistrito,
                NombreCanton = Encabezado.NombreCanton,
                NombreProvincia = Encabezado.NombreProvincia,
                NombreMetodoPago = Encabezado.NombreMetodoPago,
                Lineas = Filas
                    .Select(Fila => new LineaPedidoViewModel
                    {
                        IdProducto = Fila.IdProducto,
                        NombreProducto = Fila.NombreProducto,
                        Cantidad = Fila.Cantidad,
                        PrecioUnitario = Fila.PrecioUnitario,
                        SubtotalLinea = Fila.SubtotalLinea
                    })
                    .ToList()
            };

            Modelo.EstadosSiguientes = ConsultarEstadosSiguientes(Modelo.NombreEstado);

            return Modelo;
        }

        /// <summary>
        /// Devuelve solo los estados a los que se puede avanzar
        /// desde el estado actual del pedido:
        /// Pagado -> En preparación / Cancelado
        /// En preparación -> Entregado / Cancelado
        /// </summary>
        private List<SelectListItem> ConsultarEstadosSiguientes(string NombreEstadoActual)
        {
            List<string> Permitidos = new List<string>();

            if (NombreEstadoActual == "Pagado")
            {
                Permitidos.Add("En preparación");
                Permitidos.Add("Cancelado");
            }
            else if (NombreEstadoActual == "En preparación")
            {
                Permitidos.Add("Entregado");
                Permitidos.Add("Cancelado");
            }

            return ConsultarEstadosPedido()
                .Where(Estado => Permitidos.Contains(Estado.Text))
                .ToList();
        }

        public OperacionAdminResult ActualizarEstadoPedido(
            int IdPedido,
            int IdEstadoNuevo,
            string MotivoCancelacion)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_ActualizarEstadoPedido @IdPedido, @IdEstadoNuevo, @MotivoCancelacion",
                    new SqlParameter("@IdPedido", IdPedido),
                    new SqlParameter("@IdEstadoNuevo", IdEstadoNuevo),
                    new SqlParameter("@MotivoCancelacion", ValorONulo(MotivoCancelacion))
                )
                .FirstOrDefault() ?? new OperacionAdminResult
                {
                    Exitoso = false,
                    Mensaje = "No fue posible actualizar el estado del pedido."
                };
        }

        /* ================= RF-14: REPORTES ================= */

        public ReporteVentasViewModel ConsultarReporteVentas(
            DateTime FechaInicio,
            DateTime FechaFin)
        {
            ReporteVentasViewModel Modelo = new ReporteVentasViewModel
            {
                FechaInicio = FechaInicio,
                FechaFin = FechaFin
            };

            Modelo.Resumen = Contexto.Database
                .SqlQuery<ResumenVentasViewModel>(
                    "EXEC dbo.SP_Admin_ReporteResumenVentas @FechaInicio, @FechaFin",
                    new SqlParameter("@FechaInicio", FechaInicio),
                    new SqlParameter("@FechaFin", FechaFin)
                )
                .FirstOrDefault() ?? new ResumenVentasViewModel();

            Modelo.VentasPorDia = Contexto.Database
                .SqlQuery<VentaPorDiaViewModel>(
                    "EXEC dbo.SP_Admin_ReporteVentasPorDia @FechaInicio, @FechaFin",
                    new SqlParameter("@FechaInicio", FechaInicio),
                    new SqlParameter("@FechaFin", FechaFin)
                )
                .ToList();

            Modelo.ProductosMasVendidos = Contexto.Database
                .SqlQuery<ProductoMasVendidoViewModel>(
                    "EXEC dbo.SP_Admin_ReporteProductosMasVendidos @FechaInicio, @FechaFin, @Top",
                    new SqlParameter("@FechaInicio", FechaInicio),
                    new SqlParameter("@FechaFin", FechaFin),
                    new SqlParameter("@Top", 10)
                )
                .ToList();

            return Modelo;
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
