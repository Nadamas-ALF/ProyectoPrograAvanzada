using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Models
{
    /// <summary>
    /// Resultado genérico de los procedimientos almacenados
    /// del módulo de administración (Exitoso / Mensaje / IdGenerado).
    /// </summary>
    public class OperacionAdminResult
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; }
        public int? IdGenerado { get; set; }
    }

    /* ============================================================
       RF-11: PRODUCTOS
       ============================================================ */

    public class ProductoAdminViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public bool EsPiezaUnica { get; set; }
        public bool Destacado { get; set; }
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
        public DateTime FechaCreacion { get; set; }
        public string RutaImagen { get; set; }
        public int TotalFilas { get; set; }
    }

    public class ProductoFormViewModel
    {
        public int IdProducto { get; set; }

        [Required(ErrorMessage = "El nombre del producto es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre no puede superar los 150 caracteres.")]
        [Display(Name = "Nombre del producto")]
        public string NombreProducto { get; set; }

        [Display(Name = "Descripción")]
        public string Descripcion { get; set; }

        [Required(ErrorMessage = "El precio es obligatorio.")]
        [Range(500, 99999999.99, ErrorMessage = "El precio mínimo es de ₡500.")]
        [Display(Name = "Precio")]
        public decimal? Precio { get; set; }

        [Required(ErrorMessage = "El stock es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El stock mínimo es 1.")]
        [Display(Name = "Stock")]
        public int? Stock { get; set; }

        [Display(Name = "Pieza única")]
        public bool EsPiezaUnica { get; set; }

        [Display(Name = "Producto destacado")]
        public bool Destacado { get; set; }

        [Required(ErrorMessage = "Debe seleccionar una categoría.")]
        [Display(Name = "Categoría")]
        public int? IdCategoria { get; set; }

        public string NombreEstado { get; set; }

        public List<SelectListItem> Categorias { get; set; }

        public ProductoFormViewModel()
        {
            Categorias = new List<SelectListItem>();
        }
    }

    /// <summary>
    /// Resultado directo de SP_Admin_ConsultarProductoPorId.
    /// </summary>
    public class ProductoDetalleResult
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public string Descripcion { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public bool EsPiezaUnica { get; set; }
        public bool Destacado { get; set; }
        public int IdCategoria { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
    }

    /// <summary>
    /// Resultado directo de SP_Admin_ConsultarCategoriasActivas.
    /// </summary>
    public class CategoriaActivaResult
    {
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
    }

    public class ListadoProductosViewModel
    {
        public List<ProductoAdminViewModel> Productos { get; set; }
        public List<SelectListItem> Categorias { get; set; }
        public List<ProductoBajoStockViewModel> AlertasBajoStock { get; set; }

        public string Busqueda { get; set; }
        public int? IdCategoria { get; set; }
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

        public ListadoProductosViewModel()
        {
            Productos = new List<ProductoAdminViewModel>();
            Categorias = new List<SelectListItem>();
            AlertasBajoStock = new List<ProductoBajoStockViewModel>();
        }
    }

    /* ============================================================
       RF-12: INVENTARIO
       ============================================================ */

    public class ProductoBajoStockViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public int Stock { get; set; }
        public string NombreCategoria { get; set; }
        public string NombreEstado { get; set; }
    }

    /* ============================================================
       RF-11: IMÁGENES DE PRODUCTO
       ============================================================ */

    public class ImagenProductoViewModel
    {
        public int IdImagen { get; set; }
        public int IdProducto { get; set; }
        public string RutaImagen { get; set; }
        public bool EsPrincipal { get; set; }
    }

    public class ImagenesProductoViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public List<ImagenProductoViewModel> Imagenes { get; set; }

        public ImagenesProductoViewModel()
        {
            Imagenes = new List<ImagenProductoViewModel>();
        }
    }

    /* ============================================================
       CATEGORÍAS
       ============================================================ */

    public class CategoriaAdminViewModel
    {
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; }
        public string Descripcion { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
        public int CantidadProductos { get; set; }
    }

    public class CategoriaFormViewModel
    {
        public int IdCategoria { get; set; }

        [Required(ErrorMessage = "El nombre de la categoría es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar los 100 caracteres.")]
        [Display(Name = "Nombre de la categoría")]
        public string NombreCategoria { get; set; }

        [StringLength(255, ErrorMessage = "La descripción no puede superar los 255 caracteres.")]
        [Display(Name = "Descripción")]
        public string Descripcion { get; set; }
    }

    /* ============================================================
       RF-13: PEDIDOS ADMINISTRATIVOS
       ============================================================ */

    public class EstadoPedidoViewModel
    {
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
    }

    public class PedidoAdminViewModel
    {
        public int IdPedido { get; set; }
        public string NumeroFactura { get; set; }
        public DateTime FechaPedido { get; set; }
        public decimal Total { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
        public string NombreCliente { get; set; }
        public string EmailCliente { get; set; }
        public int CantidadProductos { get; set; }
        public int TotalFilas { get; set; }
    }

    public class ListadoPedidosAdminViewModel
    {
        public List<PedidoAdminViewModel> Pedidos { get; set; }
        public List<SelectListItem> Estados { get; set; }

        public string Busqueda { get; set; }
        public int? IdEstado { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
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

        public ListadoPedidosAdminViewModel()
        {
            Pedidos = new List<PedidoAdminViewModel>();
            Estados = new List<SelectListItem>();
        }
    }

    public class DetallePedidoAdminFila
    {
        public int IdPedido { get; set; }
        public string NumeroFactura { get; set; }
        public DateTime FechaPedido { get; set; }
        public decimal Subtotal { get; set; }
        public decimal CostoEnvio { get; set; }
        public decimal Total { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
        public string MotivoCancelacion { get; set; }
        public string NombreCliente { get; set; }
        public string EmailCliente { get; set; }
        public string NombreDestinatario { get; set; }
        public string TelefonoContacto { get; set; }
        public string DireccionExacta { get; set; }
        public string NombreDistrito { get; set; }
        public string NombreCanton { get; set; }
        public string NombreProvincia { get; set; }
        public string NombreMetodoPago { get; set; }
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal SubtotalLinea { get; set; }
    }

    public class DetallePedidoAdminViewModel
    {
        public int IdPedido { get; set; }
        public string NumeroFactura { get; set; }
        public DateTime FechaPedido { get; set; }
        public decimal Subtotal { get; set; }
        public decimal CostoEnvio { get; set; }
        public decimal Total { get; set; }
        public int IdEstado { get; set; }
        public string NombreEstado { get; set; }
        public string MotivoCancelacion { get; set; }
        public string NombreCliente { get; set; }
        public string EmailCliente { get; set; }
        public string NombreDestinatario { get; set; }
        public string TelefonoContacto { get; set; }
        public string DireccionExacta { get; set; }
        public string NombreDistrito { get; set; }
        public string NombreCanton { get; set; }
        public string NombreProvincia { get; set; }
        public string NombreMetodoPago { get; set; }
        public List<LineaPedidoViewModel> Lineas { get; set; }
        public List<SelectListItem> EstadosSiguientes { get; set; }

        public bool PuedeCambiarEstado
        {
            get
            {
                return NombreEstado != "Entregado"
                    && NombreEstado != "Cancelado";
            }
        }

        public DetallePedidoAdminViewModel()
        {
            Lineas = new List<LineaPedidoViewModel>();
            EstadosSiguientes = new List<SelectListItem>();
        }
    }

    /* ============================================================
       RF-14: REPORTES DE VENTAS
       ============================================================ */

    public class ResumenVentasViewModel
    {
        public decimal TotalVentas { get; set; }
        public int CantidadPedidos { get; set; }
        public int ProductosVendidos { get; set; }
    }

    public class VentaPorDiaViewModel
    {
        public DateTime Fecha { get; set; }
        public int CantidadPedidos { get; set; }
        public decimal TotalVentas { get; set; }
    }

    public class ProductoMasVendidoViewModel
    {
        public int IdProducto { get; set; }
        public string NombreProducto { get; set; }
        public string NombreCategoria { get; set; }
        public int UnidadesVendidas { get; set; }
        public decimal TotalVendido { get; set; }
    }

    public class ReporteVentasViewModel
    {
        [Display(Name = "Fecha de inicio")]
        public DateTime FechaInicio { get; set; }

        [Display(Name = "Fecha de fin")]
        public DateTime FechaFin { get; set; }

        public ResumenVentasViewModel Resumen { get; set; }
        public List<VentaPorDiaViewModel> VentasPorDia { get; set; }
        public List<ProductoMasVendidoViewModel> ProductosMasVendidos { get; set; }

        public ReporteVentasViewModel()
        {
            Resumen = new ResumenVentasViewModel();
            VentasPorDia = new List<VentaPorDiaViewModel>();
            ProductosMasVendidos = new List<ProductoMasVendidoViewModel>();
        }
    }
}
