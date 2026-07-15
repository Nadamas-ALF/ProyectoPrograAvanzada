using System.Collections.Generic;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Models
{
    public class LineaCarritoViewModel
    {
        public int IdProducto { get; set; }

        public string NombreProducto { get; set; }

        public string RutaImagen { get; set; }

        public decimal PrecioUnitario { get; set; }

        public int Cantidad { get; set; }

        public decimal SubtotalLinea { get; set; }

        public int StockDisponible { get; set; }

        public bool EsPiezaUnica { get; set; }

        public bool Disponible { get; set; }
    }

    public class CarritoViewModel
    {
        public CarritoViewModel()
        {
            Lineas = new List<LineaCarritoViewModel>();
        }

        public int IdCarrito { get; set; }

        public List<LineaCarritoViewModel> Lineas { get; set; }

        public decimal Subtotal
        {
            get { return Lineas.Sum(Linea => Linea.SubtotalLinea); }
        }

        public int CantidadItems
        {
            get { return Lineas.Sum(Linea => Linea.Cantidad); }
        }

        public bool EstaVacio
        {
            get { return Lineas.Count == 0; }
        }

        public bool TieneLineasNoDisponibles
        {
            get { return Lineas.Any(Linea => !Linea.Disponible); }
        }
    }
}
