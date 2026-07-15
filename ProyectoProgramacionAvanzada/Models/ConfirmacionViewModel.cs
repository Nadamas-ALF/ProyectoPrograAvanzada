using System;
using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class LineaPedidoViewModel
    {
        public int IdProducto { get; set; }

        public string NombreProducto { get; set; }

        public string RutaImagen { get; set; }

        public int Cantidad { get; set; }

        public decimal PrecioUnitario { get; set; }

        public decimal SubtotalLinea { get; set; }
    }

    public class ConfirmacionViewModel
    {
        public ConfirmacionViewModel()
        {
            Lineas = new List<LineaPedidoViewModel>();
        }

        public int IdPedido { get; set; }

        public string NumeroFactura { get; set; }

        public DateTime FechaPedido { get; set; }

        public decimal Subtotal { get; set; }

        public decimal CostoEnvio { get; set; }

        public decimal Total { get; set; }

        public string EstadoVisible { get; set; }

        public string NombreMetodoPago { get; set; }

        public string NombreDestinatario { get; set; }

        public string DireccionExacta { get; set; }

        public string NombreDistrito { get; set; }

        public string NombreCanton { get; set; }

        public string NombreProvincia { get; set; }

        public List<LineaPedidoViewModel> Lineas { get; set; }
    }
}
