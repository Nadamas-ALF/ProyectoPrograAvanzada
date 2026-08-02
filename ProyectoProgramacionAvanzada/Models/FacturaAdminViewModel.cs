using System;
using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{

    public class FacturaAdminViewModel
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

        public string MetodoPago { get; set; }

        public string Comprobante { get; set; }

        public int TotalFilas { get; set; }
    }


    public class ListadoFacturasViewModel
    {
        public ListadoFacturasViewModel()
        {
            Facturas = new List<FacturaAdminViewModel>();
        }

        public List<FacturaAdminViewModel> Facturas { get; set; }

        public string Busqueda { get; set; }

        public DateTime? FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        public int PaginaActual { get; set; }

        public int TamanoPagina { get; set; }

        public int TotalFilas { get; set; }

        public int TotalPaginas
        {
            get
            {
                if (TamanoPagina <= 0 || TotalFilas <= 0)
                {
                    return 1;
                }

                return (int)Math.Ceiling(
                    (double)TotalFilas / TamanoPagina
                );
            }
        }
    }


    public class LineaFacturaViewModel
    {
        public string NombreProducto { get; set; }

        public int Cantidad { get; set; }

        public decimal PrecioUnitario { get; set; }

        public decimal SubtotalLinea { get; set; }
    }


    public class EncabezadoFacturaViewModel
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
    }


    public class DetalleFacturaViewModel
    {
        public DetalleFacturaViewModel()
        {
            Lineas = new List<LineaFacturaViewModel>();
        }

        public EncabezadoFacturaViewModel Encabezado { get; set; }

        public List<LineaFacturaViewModel> Lineas { get; set; }
    }
}
