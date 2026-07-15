using System;
using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class PedidoResumenViewModel
    {
        public int IdPedido { get; set; }

        public string NumeroFactura { get; set; }

        public DateTime FechaPedido { get; set; }

        public decimal Total { get; set; }

        public string EstadoVisible { get; set; }

        public int CantidadProductos { get; set; }
    }

    public class HistorialViewModel
    {
        public HistorialViewModel()
        {
            Pedidos = new List<PedidoResumenViewModel>();
        }

        public List<PedidoResumenViewModel> Pedidos { get; set; }

        public int PaginaActual { get; set; }

        public int TamanoPagina { get; set; }

        public int TotalFilas { get; set; }

        public int TotalPaginas
        {
            get
            {
                if (TotalFilas == 0 || TamanoPagina == 0)
                {
                    return 0;
                }

                return (int)Math.Ceiling(
                    (double)TotalFilas / TamanoPagina
                );
            }
        }

        public bool TienePedidos
        {
            get { return Pedidos.Count > 0; }
        }
    }
}
