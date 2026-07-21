using ProyectoProgramacionAvanzada.Filtros;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Configuration;
using System.Linq;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    [SesionRequerida]
    public class CheckoutController : Controller
    {
        /*
         * El costo de envío se define manualmente. Se puede ajustar
         * con la clave "CostoEnvio" en appSettings del Web.config;
         * si no existe, se usa este valor por defecto.
         */
        private const decimal CostoEnvioPredeterminado = 2500;

        [HttpGet]
        public ActionResult Index()
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                CarritoViewModel Carrito;

                using (var ServicioCarrito = new CarritoService())
                {
                    Carrito = ServicioCarrito.ConsultarCarrito(IdUsuario);
                }

                if (Carrito.EstaVacio)
                {
                    TempData["MensajeError"] =
                        "El carrito está vacío. Agregue productos antes de pagar.";

                    return RedirectToAction("Index", "Carrito");
                }

                if (Carrito.TieneLineasNoDisponibles)
                {
                    TempData["MensajeError"] =
                        "Algunos productos ya no cuentan con stock suficiente. Por favor revise su carrito.";

                    return RedirectToAction("Index", "Carrito");
                }

                var Modelo = new CheckoutViewModel
                {
                    Lineas = Carrito.Lineas,
                    Subtotal = Carrito.Subtotal,
                    CostoEnvio = ObtenerCostoEnvio()
                };

                using (var ServicioUsuario = new UsuarioService())
                {
                    Modelo.Direcciones = ServicioUsuario
                        .ConsultarDirecciones(IdUsuario)
                        .Where(Direccion => string.Equals(
                            Direccion.NombreEstado,
                            "Activo",
                            StringComparison.OrdinalIgnoreCase))
                        .ToList();
                }

                using (var ServicioPedido = new PedidoService())
                {
                    Modelo.MetodosPago =
                        ServicioPedido.ConsultarMetodosPago();
                }

                DireccionModel Principal = Modelo.Direcciones
                    .FirstOrDefault(Direccion => Direccion.EsPrincipal);

                if (Principal != null)
                {
                    Modelo.IdDireccionSeleccionada =
                        Principal.IdDireccion;
                }

                return View(Modelo);
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CheckoutController",
                    "Index",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar el checkout. Intente nuevamente.";

                return RedirectToAction("Index", "Carrito");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Confirmar(CheckoutViewModel Modelo)
        {
            int IdUsuario = (int)Session["IdUsuario"];

            if (Modelo.IdDireccionSeleccionada <= 0)
            {
                TempData["MensajeError"] =
                    "Seleccione una dirección de envío.";

                return RedirectToAction("Index");
            }

            if (Modelo.IdMetodoPagoSeleccionado <= 0)
            {
                TempData["MensajeError"] =
                    "Seleccione un método de pago.";

                return RedirectToAction("Index");
            }

            try
            {
                using (var Servicio = new PedidoService())
                {
                    /*
                     * El costo de envío se recalcula en el servidor:
                     * no se confía en el valor enviado por el navegador.
                     */
                    var Resultado = Servicio.ConfirmarCompra(
                        IdUsuario,
                        Modelo.IdDireccionSeleccionada,
                        Modelo.IdMetodoPagoSeleccionado,
                        ObtenerCostoEnvio()
                    );

                    if (Resultado.Exitoso != true ||
                        !Resultado.IdPedido.HasValue)
                    {
                        TempData["MensajeError"] = Resultado.Mensaje;

                        return RedirectToAction("Index");
                    }

                    return RedirectToAction(
                        "Confirmacion",
                        new { id = Resultado.IdPedido.Value }
                    );
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CheckoutController",
                    "Confirmar",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible completar la compra. Por favor intente de nuevo.";

                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        public ActionResult Confirmacion(int id)
        {
            int IdUsuario = (int)Session["IdUsuario"];

            try
            {
                using (var Servicio = new PedidoService())
                {
                    ConfirmacionViewModel Modelo =
                        Servicio.ConsultarConfirmacion(id, IdUsuario);

                    if (Modelo == null)
                    {
                        return RedirectToAction(
                            "Historial",
                            "Pedido"
                        );
                    }

                    return View(Modelo);
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "CheckoutController",
                    "Confirmacion",
                    Excepcion,
                    Session["NombreUsuario"] as string
                );

                TempData["MensajeError"] =
                    "No fue posible cargar la confirmación.";

                return RedirectToAction("Historial", "Pedido");
            }
        }

        private static decimal ObtenerCostoEnvio()
        {
            string Valor =
                ConfigurationManager.AppSettings["CostoEnvio"];

            decimal CostoEnvio;

            if (!string.IsNullOrWhiteSpace(Valor) &&
                decimal.TryParse(Valor, out CostoEnvio) &&
                CostoEnvio >= 0)
            {
                return CostoEnvio;
            }

            return CostoEnvioPredeterminado;
        }

        private void RegistrarError(
            string Origen,
            string Metodo,
            Exception Excepcion,
            string UsuarioSistema)
        {
            try
            {
                string Url = Request.Url != null
                    ? Request.Url.ToString()
                    : null;

                using (var ServicioError = new ErrorService())
                {
                    ServicioError.RegistrarError(
                        Origen,
                        Metodo,
                        Excepcion,
                        UsuarioSistema,
                        Url
                    );
                }
            }
            catch
            {

            }
        }
    }
}
