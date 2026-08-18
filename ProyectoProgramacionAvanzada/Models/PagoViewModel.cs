using System;
using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class PagoViewModel
    {
        public int TotalPagos { get; set; }

        public decimal TotalRecaudado { get; set; }

        public int PagosHoy { get; set; }

        public decimal RecaudadoHoy { get; set; }

        public List<PagoDetalleModel> Pagos { get; set; }

        public PagoViewModel()
        {
            Pagos = new List<PagoDetalleModel>();
        }
    }

    public class PagoDetalleModel
    {
        public int IdPago { get; set; }

        public int IdPedido { get; set; }

        public string NombreCliente { get; set; }

        public string EmailCliente { get; set; }

        public string NombreMetodoPago { get; set; }

        public decimal Monto { get; set; }

        public DateTime FechaPago { get; set; }

        public string Comprobante { get; set; }

        public string NombreEstado { get; set; }
    }
}