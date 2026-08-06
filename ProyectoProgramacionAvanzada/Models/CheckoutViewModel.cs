using System.Collections.Generic;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Models
{
    public class CheckoutViewModel
    {
        public CheckoutViewModel()
        {
            Lineas = new List<LineaCarritoViewModel>();
            Direcciones = new List<DireccionModel>();
            MetodosPago = new List<SelectListItem>();
        }

        public List<LineaCarritoViewModel> Lineas { get; set; }

        public List<DireccionModel> Direcciones { get; set; }

        public List<SelectListItem> MetodosPago { get; set; }

        public int IdDireccionSeleccionada { get; set; }

        public int IdMetodoPagoSeleccionado { get; set; }

        public string DatoPagoSimulado { get; set; }

        public decimal Subtotal { get; set; }

        public decimal CostoEnvio { get; set; }

        public decimal Total
        {
            get { return Subtotal + CostoEnvio; }
        }

        public bool TieneDirecciones
        {
            get { return Direcciones.Count > 0; }
        }
    }
}
