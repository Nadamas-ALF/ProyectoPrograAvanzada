using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Models
{
    // RF-01 / RF-02: CATÁLOGO Y BÚSQUEDA
       

    public class ProductoCatalogoViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public decimal Precio { get; set; }
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public string NombreEstado { get; set; }
        public string RutaImagen { get; set; }
        public bool EsFavorito { get; set; }
        public int TotalFilas { get; set; }

        public bool Disponible
        {
            get { return NombreEstado == "Disponible"; }
        }
    }

    public class CatalogoViewModel
    {
        public List<ProductoCatalogoViewModel> Productos { get; set; }
        public List<SelectListItem> Categorias { get; set; }

        public string Busqueda { get; set; }
        public int? IdCategoria { get; set; }
        public string Color { get; set; }
        public int PaginaActual { get; set; }
        public int TamanoPagina { get; set; }
        public int TotalFilas { get; set; }

        public int TotalPaginas
        {
            get
            {
                if (TamanoPagina <= 0)
                {
                    return 1;
                }

                return (int)Math.Ceiling((double)TotalFilas / TamanoPagina);
            }
        }

        public CatalogoViewModel()
        {
            Productos = new List<ProductoCatalogoViewModel>();
            Categorias = new List<SelectListItem>();
        }
    }

    // RF-03: DETALLE DE PRODUCTO

    public class CatalogoProductoDetalleResult
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public string Descripcion { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public bool EsPiezaUnica { get; set; }
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public string NombreEstado { get; set; }
        public bool EsFavorito { get; set; }
    }

    public class VarianteProductoViewModel
    {
        public int IdVariante { get; set; }
        public string Color { get; set; }
        public string Talla { get; set; }
        public string Modelo { get; set; }
        public int Stock { get; set; }
    }

    public class ProductoDetalleViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public string Descripcion { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public bool EsPiezaUnica { get; set; }
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public string NombreEstado { get; set; }
        public bool EsFavorito { get; set; }
        public List<ImagenProductoViewModel> Imagenes { get; set; }
        public List<VarianteProductoViewModel> Variantes { get; set; }

        public bool Disponible
        {
            get { return NombreEstado == "Disponible"; }
        }

        public ProductoDetalleViewModel()
        {
            Imagenes = new List<ImagenProductoViewModel>();
            Variantes = new List<VarianteProductoViewModel>();
        }
    }

    // RF-10: FAVORITOS

    public class FavoritoViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public decimal Precio { get; set; }
        public string NombreCategoria { get; set; }
        public string NombreEstado { get; set; }
        public string RutaImagen { get; set; }

        public bool Disponible
        {
            get { return NombreEstado == "Disponible"; }
        }
    }
}
