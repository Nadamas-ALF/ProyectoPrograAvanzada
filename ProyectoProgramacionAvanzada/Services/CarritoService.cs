using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Linq;

namespace ProyectoProgramacionAvanzada.Services
{
    public class CarritoService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public CarritoService()
        {
            Contexto = new BD_LENEntities();
        }

        public CarritoViewModel ConsultarCarrito(int IdUsuario)
        {
            var Carrito = new CarritoViewModel();

            int? IdCarrito = Contexto
                .SP_ObtenerOCrearCarritoActivo(IdUsuario)
                .FirstOrDefault();

            Carrito.IdCarrito = IdCarrito ?? 0;

            Carrito.Lineas = Contexto
                .SP_ConsultarCarrito(IdUsuario)
                .Select(Linea => new LineaCarritoViewModel
                {
                    IdProducto = Linea.IdProducto,
                    NombreProducto = Linea.NombreProducto,
                    RutaImagen = Linea.RutaImagen,
                    PrecioUnitario = Linea.PrecioUnitario,
                    Cantidad = Linea.Cantidad,
                    SubtotalLinea = Linea.SubtotalLinea ?? 0,
                    StockDisponible = Linea.StockDisponible,
                    EsPiezaUnica = Linea.EsPiezaUnica,
                    Disponible = Linea.Disponible ?? false
                })
                .ToList();

            return Carrito;
        }

        public SP_AgregarProductoCarrito_Result AgregarProducto(
            int IdUsuario,
            int IdProducto,
            int Cantidad)
        {
            SP_AgregarProductoCarrito_Result Resultado = Contexto
                .SP_AgregarProductoCarrito(
                    IdUsuario,
                    IdProducto,
                    Cantidad
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return new SP_AgregarProductoCarrito_Result
                {
                    Exitoso = false,
                    Mensaje = "No fue posible agregar el producto al carrito."
                };
            }

            return Resultado;
        }

        public SP_ActualizarCantidadCarrito_Result ActualizarCantidad(
            int IdUsuario,
            int IdProducto,
            int Cantidad)
        {
            SP_ActualizarCantidadCarrito_Result Resultado = Contexto
                .SP_ActualizarCantidadCarrito(
                    IdUsuario,
                    IdProducto,
                    Cantidad
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return new SP_ActualizarCantidadCarrito_Result
                {
                    Exitoso = false,
                    Mensaje = "No fue posible actualizar la cantidad."
                };
            }

            return Resultado;
        }

        public SP_EliminarProductoCarrito_Result EliminarProducto(
            int IdUsuario,
            int IdProducto)
        {
            SP_EliminarProductoCarrito_Result Resultado = Contexto
                .SP_EliminarProductoCarrito(
                    IdUsuario,
                    IdProducto
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return new SP_EliminarProductoCarrito_Result
                {
                    Exitoso = false,
                    Mensaje = "No fue posible eliminar el producto."
                };
            }

            return Resultado;
        }

        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}
