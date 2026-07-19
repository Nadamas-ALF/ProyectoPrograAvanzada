using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Services
{
    public class CatalogoService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public CatalogoService()
        {
            Contexto = new BD_LENEntities();
        }

        private static object ValorONulo(object Valor)
        {
            return Valor ?? DBNull.Value;
        }

        public List<SelectListItem> ConsultarCategorias()
        {
            return Contexto.Database
                .SqlQuery<CategoriaActivaResult>(
                    "EXEC dbo.SP_ConsultarCategoriasCatalogo"
                )
                .Select(Categoria => new SelectListItem
                {
                    Value = Categoria.IdCategoria.ToString(),
                    Text = Categoria.NombreCategoria
                })
                .ToList();
        }

        public CatalogoViewModel ConsultarCatalogo(
            string Busqueda,
            int? IdCategoria,
            string Color,
            int? IdUsuarioActual,
            int Pagina,
            int TamanoPagina)
        {
            if (Pagina < 1)
            {
                Pagina = 1;
            }

            List<ProductoCatalogoViewModel> Productos = Contexto.Database
                .SqlQuery<ProductoCatalogoViewModel>(
                    "EXEC dbo.SP_ConsultarCatalogo @Busqueda, @IdCategoria, @Color, @IdUsuarioActual, @Pagina, @TamanoPagina",
                    new SqlParameter("@Busqueda", ValorONulo(Busqueda)),
                    new SqlParameter("@IdCategoria", ValorONulo(IdCategoria)),
                    new SqlParameter("@Color", ValorONulo(Color)),
                    new SqlParameter("@IdUsuarioActual", ValorONulo(IdUsuarioActual)),
                    new SqlParameter("@Pagina", Pagina),
                    new SqlParameter("@TamanoPagina", TamanoPagina)
                )
                .ToList();

            return new CatalogoViewModel
            {
                Productos = Productos,
                Busqueda = Busqueda,
                IdCategoria = IdCategoria,
                Color = Color,
                PaginaActual = Pagina,
                TamanoPagina = TamanoPagina,
                TotalFilas = Productos.Count > 0 ? Productos[0].TotalFilas : 0,
                Categorias = ConsultarCategorias()
            };
        }

        public ProductoDetalleViewModel ConsultarProductoPorId(
            int IdProducto,
            int? IdUsuarioActual)
        {
            CatalogoProductoDetalleResult Resultado = Contexto.Database
                .SqlQuery<CatalogoProductoDetalleResult>(
                    "EXEC dbo.SP_ConsultarProductoDetalle @IdProducto, @IdUsuarioActual",
                    new SqlParameter("@IdProducto", IdProducto),
                    new SqlParameter("@IdUsuarioActual", ValorONulo(IdUsuarioActual))
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return null;
            }

            return new ProductoDetalleViewModel
            {
                IdProducto = Resultado.IdProducto,
                NombreProducto = Resultado.NombreProducto,
                Descripcion = Resultado.Descripcion,
                Precio = Resultado.Precio,
                Stock = Resultado.Stock,
                EsPiezaUnica = Resultado.EsPiezaUnica,
                IdCategoria = Resultado.IdCategoria,
                NombreCategoria = Resultado.NombreCategoria,
                NombreEstado = Resultado.NombreEstado,
                EsFavorito = Resultado.EsFavorito,
                Imagenes = Contexto.Database
                    .SqlQuery<ImagenProductoViewModel>(
                        "EXEC dbo.SP_ConsultarImagenesCatalogo @IdProducto",
                        new SqlParameter("@IdProducto", IdProducto)
                    )
                    .ToList(),
                Variantes = Contexto.Database
                    .SqlQuery<VarianteProductoViewModel>(
                        "EXEC dbo.SP_ConsultarVariantesProducto @IdProducto",
                        new SqlParameter("@IdProducto", IdProducto)
                    )
                    .ToList()
            };
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
