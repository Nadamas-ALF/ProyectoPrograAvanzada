using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Services
{
    /// <summary>
    /// Servicio del módulo administrativo para la gestión de
    /// productos (RF-11), inventario (RF-12) e imágenes.
    /// Los procedimientos almacenados se invocan con
    /// Database.SqlQuery para no depender de la regeneración del EDMX.
    /// </summary>
    public class ProductoAdminService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public ProductoAdminService()
        {
            Contexto = new BD_LENEntities();
        }

        private static object ValorONulo(object Valor)
        {
            return Valor ?? DBNull.Value;
        }

        public ListadoProductosViewModel ConsultarProductos(
            string Busqueda,
            int? IdCategoria,
            int Pagina,
            int TamanoPagina)
        {
            if (Pagina < 1)
            {
                Pagina = 1;
            }

            List<ProductoAdminViewModel> Productos = Contexto.Database
                .SqlQuery<ProductoAdminViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarProductos @Busqueda, @IdCategoria, @Pagina, @TamanoPagina",
                    new SqlParameter("@Busqueda", ValorONulo(Busqueda)),
                    new SqlParameter("@IdCategoria", ValorONulo(IdCategoria)),
                    new SqlParameter("@Pagina", Pagina),
                    new SqlParameter("@TamanoPagina", TamanoPagina)
                )
                .ToList();

            return new ListadoProductosViewModel
            {
                Productos = Productos,
                Busqueda = Busqueda,
                IdCategoria = IdCategoria,
                PaginaActual = Pagina,
                TamanoPagina = TamanoPagina,
                TotalFilas = Productos.Count > 0
                    ? Productos[0].TotalFilas
                    : 0,
                Categorias = ConsultarCategoriasActivas(),
                AlertasBajoStock = ConsultarBajoStock(3)
            };
        }

        public ProductoFormViewModel ConsultarProductoPorId(int IdProducto)
        {
            ProductoDetalleResult Producto = Contexto.Database
                .SqlQuery<ProductoDetalleResult>(
                    "EXEC dbo.SP_Admin_ConsultarProductoPorId @IdProducto",
                    new SqlParameter("@IdProducto", IdProducto)
                )
                .FirstOrDefault();

            if (Producto == null)
            {
                return null;
            }

            return new ProductoFormViewModel
            {
                IdProducto = Producto.IdProducto,
                NombreProducto = Producto.NombreProducto,
                Descripcion = Producto.Descripcion,
                Precio = Producto.Precio,
                Stock = Producto.Stock,
                EsPiezaUnica = Producto.EsPiezaUnica,
                Destacado = Producto.Destacado,
                IdCategoria = Producto.IdCategoria,
                NombreEstado = Producto.NombreEstado,
                Categorias = ConsultarCategoriasActivas()
            };
        }

        public List<SelectListItem> ConsultarCategoriasActivas()
        {
            return Contexto.Database
                .SqlQuery<CategoriaActivaResult>(
                    "EXEC dbo.SP_Admin_ConsultarCategoriasActivas"
                )
                .Select(Categoria => new SelectListItem
                {
                    Value = Categoria.IdCategoria.ToString(),
                    Text = Categoria.NombreCategoria
                })
                .ToList();
        }

        public OperacionAdminResult InsertarProducto(ProductoFormViewModel Producto)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_InsertarProducto @NombreProducto, @Descripcion, @Precio, @Stock, @EsPiezaUnica, @Destacado, @IdCategoria",
                    new SqlParameter("@NombreProducto", Producto.NombreProducto),
                    new SqlParameter("@Descripcion", ValorONulo(Producto.Descripcion)),
                    new SqlParameter("@Precio", Producto.Precio ?? 0),
                    new SqlParameter("@Stock", Producto.Stock ?? 0),
                    new SqlParameter("@EsPiezaUnica", Producto.EsPiezaUnica),
                    new SqlParameter("@Destacado", Producto.Destacado),
                    new SqlParameter("@IdCategoria", Producto.IdCategoria ?? 0)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult ActualizarProducto(ProductoFormViewModel Producto)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_ActualizarProducto @IdProducto, @NombreProducto, @Descripcion, @Precio, @Stock, @EsPiezaUnica, @Destacado, @IdCategoria",
                    new SqlParameter("@IdProducto", Producto.IdProducto),
                    new SqlParameter("@NombreProducto", Producto.NombreProducto),
                    new SqlParameter("@Descripcion", ValorONulo(Producto.Descripcion)),
                    new SqlParameter("@Precio", Producto.Precio ?? 0),
                    new SqlParameter("@Stock", Producto.Stock ?? 0),
                    new SqlParameter("@EsPiezaUnica", Producto.EsPiezaUnica),
                    new SqlParameter("@Destacado", Producto.Destacado),
                    new SqlParameter("@IdCategoria", Producto.IdCategoria ?? 0)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult CambiarEstadoProducto(int IdProducto)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_CambiarEstadoProducto @IdProducto",
                    new SqlParameter("@IdProducto", IdProducto)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        /* ================= RF-12: INVENTARIO ================= */

        public OperacionAdminResult ActualizarStock(int IdProducto, int Stock)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_ActualizarStock @IdProducto, @Stock",
                    new SqlParameter("@IdProducto", IdProducto),
                    new SqlParameter("@Stock", Stock)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public List<ProductoBajoStockViewModel> ConsultarBajoStock(int StockMinimo)
        {
            return Contexto.Database
                .SqlQuery<ProductoBajoStockViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarBajoStock @StockMinimo",
                    new SqlParameter("@StockMinimo", StockMinimo)
                )
                .ToList();
        }

        /* ================= IMÁGENES (RF-11) ================= */

        public List<ImagenProductoViewModel> ConsultarImagenes(int IdProducto)
        {
            return Contexto.Database
                .SqlQuery<ImagenProductoViewModel>(
                    "EXEC dbo.SP_Admin_ConsultarImagenesProducto @IdProducto",
                    new SqlParameter("@IdProducto", IdProducto)
                )
                .ToList();
        }

        public OperacionAdminResult InsertarImagen(int IdProducto, string RutaImagen)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_InsertarImagenProducto @IdProducto, @RutaImagen",
                    new SqlParameter("@IdProducto", IdProducto),
                    new SqlParameter("@RutaImagen", RutaImagen)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult MarcarImagenPrincipal(int IdImagen)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_MarcarImagenPrincipal @IdImagen",
                    new SqlParameter("@IdImagen", IdImagen)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        public OperacionAdminResult EliminarImagen(int IdImagen)
        {
            return Contexto.Database
                .SqlQuery<OperacionAdminResult>(
                    "EXEC dbo.SP_Admin_EliminarImagenProducto @IdImagen",
                    new SqlParameter("@IdImagen", IdImagen)
                )
                .FirstOrDefault() ?? ResultadoNulo();
        }

        private static OperacionAdminResult ResultadoNulo()
        {
            return new OperacionAdminResult
            {
                Exitoso = false,
                Mensaje = "No fue posible completar la operación. Intente de nuevo."
            };
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
