using System.Collections.Generic;

namespace ProyectoProgramacionAvanzada.Models
{
    public class ProductoDestacadoViewModel
    {
        public int IdProducto { get; set; }

        public string NombreProducto { get; set; }

        public decimal Precio { get; set; }

        public string RutaImagen { get; set; }

        public string NombreCategoria { get; set; }
    }

    public class PortadaViewModel
    {
        public PortadaViewModel()
        {
            Destacados = new List<ProductoDestacadoViewModel>();
            Catalogo = new CatalogoViewModel();
        }

        public List<ProductoDestacadoViewModel> Destacados { get; set; }

        public CatalogoViewModel Catalogo { get; set; }
    }
}
