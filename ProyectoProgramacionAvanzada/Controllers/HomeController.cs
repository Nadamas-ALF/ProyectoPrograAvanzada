using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }


        [HttpGet]
        public ActionResult Login()
        {
            if (Session["IdUsuario"] != null)
            {
                return RedirectToAction("Principal", "Home");
            }

            return View(new InicioSesionModel());
        }



        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(InicioSesionModel Modelo)
        {
            if (!ModelState.IsValid)
            {
                return View(Modelo);
            }

            try
            {
                using (var Servicio = new UsuarioService())
                {
                    SP_ConsultarUsuarioInicioSesion_Result Usuario =
                        Servicio.ValidarCredenciales(Modelo);

                    if (Usuario == null)
                    {
                        ModelState.AddModelError(
                            string.Empty,
                            "El correo o la contraseña son incorrectos, o el usuario no está activo."
                        );

                        return View(Modelo);
                    }

                    Session["IdUsuario"] = Usuario.IdUsuario;
                    Session["NombreUsuario"] =
                        Usuario.Nombre + " " + Usuario.Apellido;
                    Session["IdRol"] = Usuario.IdRol;
                    Session["NombreRol"] = Usuario.NombreRol;
                    Session["IdEstado"] = Usuario.IdEstado;
                    Session["NombreEstado"] = Usuario.NombreEstado;

                    return RedirectToAction("Principal", "Home");
                }
            }
            catch (Exception Excepcion)
            {
                RegistrarError(
                    "HomeController",
                    "Login",
                    Excepcion,
                    Modelo.Email
                );

                ModelState.AddModelError(
                    string.Empty,
                    "Ocurrió un error al procesar el inicio de sesión. Intente nuevamente."
                );

                return View(Modelo);
            }
        }



        [HttpGet]
        public ActionResult Principal()
        {
            if (Session["IdUsuario"] == null)
            {
                return RedirectToAction("Login", "Home");
            }

            return View();
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CerrarSesion()
        {
            Session.Clear();
            Session.Abandon();

            return RedirectToAction("Login", "Home");
        }



        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }



        [HttpGet]
        public ActionResult ForgotPassword()
        {
            ViewBag.Message = "Recuperar acceso a la cuenta.";

            return View();
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