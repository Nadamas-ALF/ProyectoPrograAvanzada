using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{

    public class FacturaAdminService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public FacturaAdminService()
        {
            Contexto = new BD_LENEntities();
        }

        private static object ValorONulo(object Valor)
        {
            return Valor ?? DBNull.Value;
        }

        private class DetalleFacturaFila
        {
            public int IdFactura { get; set; }
            public int IdPedido { get; set; }
            public string NumeroFactura { get; set; }
            public DateTime FechaFactura { get; set; }
            public decimal Subtotal { get; set; }
            public decimal CostoEnvio { get; set; }
            public decimal Total { get; set; }
            public string NombreEstado { get; set; }
            public string NombreCliente { get; set; }
            public string EmailCliente { get; set; }
            public string TelefonoCliente { get; set; }
            public string DireccionExacta { get; set; }
            public string Provincia { get; set; }
            public string Canton { get; set; }
            public string Distrito { get; set; }
            public string MetodoPago { get; set; }
            public string Comprobante { get; set; }
            public DateTime? FechaPago { get; set; }
            public string NombreProducto { get; set; }
            public int Cantidad { get; set; }
            public decimal PrecioUnitario { get; set; }
            public decimal SubtotalLinea { get; set; }
        }

        public ListadoFacturasViewModel ConsultarFacturas(
            string Busqueda,
            DateTime? FechaInicio,
            DateTime? FechaFin,
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

            List<FacturaAdminViewModel> Facturas = Contexto.Database
                .SqlQuery<FacturaAdminViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarFacturas @Busqueda, @FechaInicio, @FechaFin, @Pagina, @TamanoPagina",
                    new SqlParameter("@Busqueda", ValorONulo(Busqueda)),
                    new SqlParameter("@FechaInicio", ValorONulo(FechaInicio)),
                    new SqlParameter("@FechaFin", ValorONulo(FechaFin)),
                    new SqlParameter("@Pagina", Pagina),
                    new SqlParameter("@TamanoPagina", TamanoPagina)
                )
                .ToList();

            return new ListadoFacturasViewModel
            {
                Facturas = Facturas,
                Busqueda = Busqueda,
                FechaInicio = FechaInicio,
                FechaFin = FechaFin,
                PaginaActual = Pagina,
                TamanoPagina = TamanoPagina,
                TotalFilas = Facturas.Count > 0
                    ? Facturas[0].TotalFilas
                    : 0
            };
        }

        public DetalleFacturaViewModel ConsultarDetalle(int IdFactura)
        {
            List<DetalleFacturaFila> Filas = Contexto.Database
                .SqlQuery<DetalleFacturaFila>(
                    "EXEC dbo.SP_Admin_ConsultarDetalleFactura @IdFactura",
                    new SqlParameter("@IdFactura", IdFactura)
                )
                .ToList();

            if (Filas.Count == 0)
            {
                return null;
            }

            DetalleFacturaFila Encabezado = Filas[0];

            return new DetalleFacturaViewModel
            {
                Encabezado = new EncabezadoFacturaViewModel
                {
                    IdFactura = Encabezado.IdFactura,
                    IdPedido = Encabezado.IdPedido,
                    NumeroFactura = Encabezado.NumeroFactura,
                    FechaFactura = Encabezado.FechaFactura,
                    Subtotal = Encabezado.Subtotal,
                    CostoEnvio = Encabezado.CostoEnvio,
                    Total = Encabezado.Total,
                    NombreEstado = Encabezado.NombreEstado,
                    NombreCliente = Encabezado.NombreCliente,
                    EmailCliente = Encabezado.EmailCliente,
                    TelefonoCliente = Encabezado.TelefonoCliente,
                    DireccionExacta = Encabezado.DireccionExacta,
                    Provincia = Encabezado.Provincia,
                    Canton = Encabezado.Canton,
                    Distrito = Encabezado.Distrito,
                    MetodoPago = Encabezado.MetodoPago,
                    Comprobante = Encabezado.Comprobante,
                    FechaPago = Encabezado.FechaPago
                },
                Lineas = Filas
                    .Select(Fila => new LineaFacturaViewModel
                    {
                        NombreProducto = Fila.NombreProducto,
                        Cantidad = Fila.Cantidad,
                        PrecioUnitario = Fila.PrecioUnitario,
                        SubtotalLinea = Fila.SubtotalLinea
                    })
                    .ToList()
            };
        }

        public void Dispose()
        {
            if (Contexto != null)
            {
                Contexto.Dispose();
            }
        }
    }
}
